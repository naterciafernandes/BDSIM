% BDsim - version 1.0
% 2019 Written by Natércia C. P. Fernandes
%                 natercia@eq.uc.pt
%
%    This file is part of BDsim.
%
%    BDsim is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    BDsim is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with BDsim.  If not, see <https://www.gnu.org/licenses/>.

%------------------------------------------------------------------------------

%
% Biodiesel simulator (filter + reactor + heat exchanger + decanter + washer +
%                      + dryer + sensors + controllers + actuators)
%


% Preliminaries ---------------------------------------------------------------
% -----------------------------------------------------------------------------
    tic;
    clear all;     % making sure that persistent variables of possible previous runs are emptied 
    if (~isOctave)
      rng ('shuffle');   % different initial seed for random numbers generation
    end                  % (only for Matlab; it's already Octave's default behavior)


% Data ------------------------------------------------------------------------
% -----------------------------------------------------------------------------
  % System parameters
    system_parameters

  % User settings
    user_settings

  % Unit conversions
    % molar flowrate from massic flowrate
    d(:,3) = d(:,3)/p.Mm/3600;                                % kg/h -> mol/s
    u0 = d(1,:);
    % time unit of flowrates
    sp(:,4) = sp(:,4)/3600;                                   % kg/h -> kg/s
    pid.kc(:,4) = pid.kc(:,4)*3600;                           % %/(kg/h) -> %/(kg/s)
    sfaults.b(:,4) = sfaults.b(:,4)/3600;                     % kg/h -> kg/s
    sfaults.noise_std(4) = sfaults.noise_std(4)/3600;         % kg/h -> kg/s
    % for pores radius: meters --> micrometers
    % (to prevent possible numerical problems due to too small values)
    pp.rclean = pp.rclean * 1e6;                              % m -> microm
    sv0(19) = sv0(19) * 1e6;                                  % m -> microm
    
  % Imposing ARMAX parameters
  % (so that the last issued controller order is preserved
  % at time instants when the controller isn't supposed to
  % issue any order (ie, when t isn't multiple of nic))
    mode = logical (mode);                                    % control loop mode: 0-MANUAL
                                                              %                    1-AUTO  
    luAUTO = nnz (mode);                                      % # of input vrs from loops in AUTO mode
    uindexAUTO = uindex( mode == 1);                          % indices of input vrs from loops in AUTO
    armax.phi( uindexAUTO ) = 1;                              % sets    phi = 1 for manipulated in AUTO
    armax.theta( uindexAUTO ) = 0;                            % sets  theta = 0 for manipulated in AUTO
    armax.eta( uindexAUTO ) = 0;                              % sets    eta = 0 for manipulated in AUTO
    armax.unoise_std( uindexAUTO ) = 0;                       % sets noise to 0 for manipulated in AUTO
    d(:, uindexAUTO ) =  zeros (lt, luAUTO);                  % sets disturbanc for manipulated in AUTO

  % Initialization of ARMAX noise
    armax.unoise = armax.unoise_std .* randn (1, lu);

  % Selecting just controllers in AUTO mode
    pidAUTO.kc = pid.kc (mode==1);
    pidAUTO.taui = pid.taui (mode==1);
    pidAUTO.taud = pid.taud (mode==1);
    pidAUTO.lower_bound = pid.lower_bound (mode==1);
    pidAUTO.upper_bound = pid.upper_bound (mode==1);
    spAUTO = sp(:,mode==1);

  % Initialization of the controllers in AUTO mode
    pidAUTO.ioutput = u0 (uindexAUTO);
    pidAUTO.ierror1 = zeros (1, luAUTO);
    pidAUTO.ierror2 = zeros (1, luAUTO);
    pidAUTO.dt = dt*nic;

  % Signal from sensors
    sfaults.signal = logical (sfaults.signal);                  % true: "alive"; false: "dead"

  % Identification of valves
    valv = vfaults.uindex;                                      % u index pointing to valves

% Closed loop process ---------------------------------------------------------
% -----------------------------------------------------------------------------
  % Taking into account faults set by the user
    [sfaults.a, sfaults.b, sfaults.signal] = intermittence (t, sfaults);% intermittences
    [p.K1F p.K2F p.K3F p.K4F] = clogging_kit (pp, pfaults);             % clogging
    p.k0 = side_reactions (p.k0, pfaults.ratio_robs_r);                 % side reactions
    factor = fouling (t, pfaults.fouling, pfaults.foulingpar);          % fouling of the heat exchanger

  % Initialization of variables
    u = u0;                                                    % inputs initialization
    vpos(1,:) = u0(valv);                                      % valve(s) position
    vpos(2:lt,:) = zeros (lt -1, nvalves);                     % memory allocation
    sv(1,:) = sv0;                                             % state variable initialization
    sv(2:lt,:) = zeros (lt -1, lsv);                           % memory allocation
    [xLend(1,:) yLend(1,:)] = AEmodel (sv(1,:), p);            % initializat. of biodiesel composition
    uv(1,:) = u0;                                              % initialization of input vrs
    uv(2:lt,:) = zeros (lt -1, lu);                            % memory allocation
    pv(1,:) = measurements (1, sv(1,:), uv(1,:), p, sfaults);  % measurements initialization (t=ti)
    pv(2:lt,:) = zeros (lt -1, nsensors);                      % memory allocation
    pvAUTO = pv(1, pvindex (mode==1));                         % initial. of measured vrs of AUTO loops
    tclean = [];                                               % times of filter cleanings

  % Computing profiles along time
    for i = 2:lt
      % inputs update
      u = inputs (i, u, uindexAUTO, armax, d, nic, pidAUTO, spAUTO(i,:), pvAUTO);
      uv(i,:) = u(:);
      % process update
      vpos(i,:) = valves (nvalves, uv(i,valv), uv(i-1,valv), vpos(i-1,:), vfaults, dt); % valves positions
      uu = u;
      uu(valv) = vpos(i,:);
      p.factor = factor(i);
      time = [t(i-1) t(i)];

      if (isOctave)                                                     % the environment is Octave
        fun = @(svt, time) ODEmodel (svt, time, p, uu);
        [svt istate msg]  = lsode (fun, sv0, time);
      else                                                              % the environment is Matlab
        fun = @(time, svt) ODEmodel_matlab (time, svt, p, uu);
        [tt svt]  = ode45 (fun, time, sv0);
      end
      sv(i,:) = svt(end,:);
      [xLend(i,:) yLend(i,:)] = AEmodel (sv(i,:), p);
      if (pv(i-1,5) >= pfaults.DPclean)
        [sv(i,19) p.K2F p.K4F tclean(end+1)] = clog_cleaning (t(i), p, pp, pfaults);
        disp ('Filter cleaning performed at t = '), disp (tclean(end))
      end 
      sv0 = sv(i,:);
      % measurements update
      pv(i,:) = measurements (i, sv(i,:), uu, p, sfaults);
      pvAUTO = pv(i, pvindex( mode==1) );
    end


% Results ---------------------------------------------------------------------
% -----------------------------------------------------------------------------
 %  Data preparation
    % shifting uv 1 interval to the past for correct graphical representation with steps
    uv(1,:) = [];
    % deleting last point without correspondence for other outputs
    t(end) = [];
    sv(end,:) = [];
    pv(end,:) = [];
    sp(end,:) = [];
    xLend(end,:) = [];
    yLend(end,:) = [];
    % change of units for all temperatures: K -> ºC
    uv(:, 2) = uv(:, 2)-273.15;
    uv(:, 4) = uv(:, 4)-273.15;
    sv(:, 7) = sv(:, 7)-273.15;
    sv(:,18) = sv(:,18)-273.15;
    pv(:, 1) = pv(:, 1)-273.15;
    pv(:, 2) = pv(:, 2)-273.15;
    sp(:, 1) = sp(:, 1)-273.15;
    sp(:, 2) = sp(:, 2)-273.15;
    % change of units for mass flow-rates: kg/s -> kg/h
    pv(:, 4) = pv(:, 4)*3600;
    sp(:, 4) = sp(:, 4)*3600;
    % change of units molar flow-rates: mol/s -> kg/h
    uv(:, 3) = uv(:, 3)*p.Mm*3600;
    
  % Preparing 'results' folder for writing
    if exist('results', 'dir') == 0
      mkdir('results');
    end
    display('Saving Results:')

  % Saving input variables (disturbances & manipulated) profiles
    display('saving input variables profiles in file results/inputs')
    fid = fopen ('results/inputs', 'w');
    fprintf (fid, '%1s %12s %14s %14s %14s %14s %14s %14s\r\n', '%', 't/s', 'order_lift_oil/%', 'Tmet/C', 'Fmet/(kg/h)', 'Toil/C', 'Qheat/W', 'order_lift_H/%');
    fclose (fid);
    matrix = [t uv];
    save -append -ascii results/inputs matrix

  % Saving state variables profiles
    display('saving state variables profiles in file results/states')
    fid = fopen ('results/states', 'w');
    fprintf (fid, '%1s %1s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s %14s\r\n', '%', 't/s', 'xR_TG/-', 'xR_DG/-', 'xR_MG/-', 'xR_M/-', 'xR_E/-', 'xR_G/-', 'TR/C', 'xL_TG/-', 'xL_DG/-', 'xL_MG/-', 'xL_M/-', 'xL_E/-', 'xL_G/-', 'xH_M/-', 'xH_E/-', 'xH_G/-', 'hH/m', 'TD/C', 'rpores/m', 'lifto/%', 'liftH/%', 'xDRY_TG/-', 'xDRY_DG/-', 'xDRY_MG/-', 'xDRY_M/-', 'xDRY_E/-', 'xDRY_G/-', 'yDRY_TG/%', 'yDRY_DG/%', 'yDRY_MG/%', 'yDRY_M/%', 'yDRY_E/%', 'yDRY_G/%');
    fclose (fid);
    matrix = [t sv xLend yLend];
    save -append -ascii results/states matrix

  % Saving measured variables profiles
    display('saving measured variables profiles in file results/measurements')
    fid = fopen ('results/measurements', 'w');
    fprintf (fid, '%1s %9s %14s %14s %14s %14s %14s\r\n', '%', 't/s', 'TR/C', 'TD/C', 'hH/m', 'Foil/(kg/h)', 'DPfilter/Pa');
    fclose (fid);
    matrix = [t pv];
    save -append -ascii results/measurements matrix

  % Saving setpoints profiles
    display('saving setpoint variables profiles in file results/setpoints')
    fid = fopen ('results/setpoints', 'w');
    fprintf (fid, '%1s %12s %14s %14s %14s %14s\r\n', '%', 't/s', 'sp1/C', 'sp2/C', 'sp3/m', 'sp4/(kg/h)');
    fclose (fid);
    matrix = [t sp];
    save -append -ascii results/setpoints matrix


% Computing performance (CPU time) --------------------------------------------
% -----------------------------------------------------------------------------
    display ('Computing performance:')
    totCPUtime = cputime
    runtime = toc


% Graphical representation ----------------------------------------------------
% -----------------------------------------------------------------------------
    t = t/3600;                                                               % s -> h

    figure (1)
    h1 = plot (t, sv(:,7),'-r','LineWidth', 1,'DisplayName','TR');
    hold on
    h2 = plot (t, sv(:,18),'-m','LineWidth', 1,'DisplayName','TD');
    [ax, h3, h4] = plotyy (t, uv(:,4), t, uv(:,5));
    legend ([h1, h2, h3, h4], 'TR', 'TD', 'Toil', 'Qheat', 'location', 'southwest')
    hold off
    ylabel (ax(1), 'T / C')
    ylabel (ax(2), 'Qheat / W')
    xlabel ('t / h')
    set (ax(1), 'YLim', [45, 63])
    set (ax(2), 'YLim', [10000, 30000])
    set (h3, 'LineWidth', 1, 'color', 'b', 'LineStyle', '-');
    set (h4, 'LineWidth', 1, 'LineStyle', '-');
    grid on
    title ('2 input variables & 2 state variables')

    figure (2)
    [ax, h1, h2] = plotyy (t, sv(:,17), t, yLend(:,5));
    ylabel (ax(1), 'hH / m')
    ylabel (ax(2), 'yDRY / -')
    xlabel ('t / h')
    set (ax(1), 'YLim', [0.4, 0.6])
    set (ax(2), 'YLim', [0.95, 1.00])
    set (h1, 'LineWidth', 1, 'LineStyle', '-');
    set (h2, 'LineWidth', 1, 'LineStyle', '-');
    grid on
    title ('2 state variables')

    figure (3)
    [ax, h1, h2] = plotyy (t, uv(:,2), t, uv(:,1));
    ylabel (ax(1), 'Tmet / C')
    ylabel (ax(2), 'controller order for oil valve lift / %')
    xlabel ('t / h')
    set (ax(1), 'YLim', [30, 55])
    set (ax(2), 'YLim', [0, 100])
    set (h1, 'LineWidth', 1, 'LineStyle', '-');
    set (h2, 'LineWidth', 1, 'LineStyle', '-');
    grid on
    title ('2 input variables')

    figure (4)
    [ax, h1, h2] = plotyy (t, uv(:,6), t, uv(:,3));
    ylabel (ax(1), 'controller order for H valve lift / %')
    ylabel (ax(2), 'Fmet / (kg/h)')
    xlabel ('t / h')
    set (ax(1), 'YLim', [-1, 101])
    set (ax(2), 'YLim', [500, 700])
    set (h1, 'LineWidth', 1, 'LineStyle', '-');
    set (h2, 'LineWidth', 1, 'LineStyle', '-');
    grid on
    title ('2 input variables')

    figure (5)
    plot (t, sp(:,1), 'DisplayName', 'setpoint', 'LineWidth', 2, 'LineStyle', '--');
    hold on
    plot (t, pv(:,1), 'DisplayName', 'measurement','LineWidth', 1, 'LineStyle', '-', 'Color', 'b');
    plot (t, sv(:,7), 'DisplayName', 'state', 'LineWidth', 1, 'LineStyle', '-', 'Color', 'r');
    hold off
    ylabel ('TR / C')
    xlabel ('t / h')
    legend ('show', 'location', 'northwest')
    ylim ([55 65])
    grid on
    title ('state & measurement & setpoint')

    figure (6)
    plot (t, sp(:,2), 'DisplayName', 'setpoint', 'LineWidth', 2, 'LineStyle', '--');
    hold on
    plot (t, pv(:,2), 'DisplayName', 'measurement', 'LineWidth', 1, 'LineStyle', '-', 'Color', 'b');
    plot (t, sv(:,18), 'DisplayName', 'state', 'LineWidth', 1, 'LineStyle', '-', 'Color', 'r');
    hold off
    ylabel ('TD / C')
    xlabel ('t / h')
    legend ('show', 'location', 'northwest')
    ylim ([45 55])
    grid on
    title ('state & measurement & setpoint')

    figure (7)
    plot (t, sp(:,3), 'DisplayName', 'setpoint', 'LineWidth', 2, 'LineStyle', '--');
    hold on
    plot (t, pv(:,3), 'DisplayName', 'measurement', 'LineWidth', 1, 'LineStyle', '-', 'Color', 'b');
    plot (t, sv(:,17), 'DisplayName', 'state', 'LineWidth', 1, 'LineStyle', '-', 'Color', 'r');
    hold off
    ylabel ('hH / m')
    xlabel ('t / h')
    legend ('show', 'location', 'northwest')
    ylim ([-0.01 1.0])
    grid on
    title ('state & measurement & setpoint')

    figure (8)
    plot (t, sp(:,4), 'DisplayName', 'setpoint', 'LineWidth', 2, 'LineStyle', '--');
    hold on
    plot (t, pv(:,4), 'DisplayName', 'measurement', 'LineWidth', 1, 'LineStyle', '-', 'Color', 'b');
    hold off
    ylabel ('Foil / (kg/h)')
    xlabel ('t / h')
    legend ('show', 'location', 'northwest')
    ylim ([2000 4000.0])
    grid on
    title ('measurement & setpoint')

    figure (9)
    plot (t, pv(:,5), 'DisplayName', 'measurement', 'LineWidth', 1, 'LineStyle', '-', 'Color', 'b');
    ylabel ('DP filter / Pa')
    xlabel ('t / h')
    legend ('show', 'location', 'northwest')
    ylim ([0 1.1e5])
    grid on
    title ('measurement')

    pause

% eof
