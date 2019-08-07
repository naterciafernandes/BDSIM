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


% Time ----------------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------
    ti = 0;                                              % initial time, s
    tf = 260000;                                         % final time, s
    dt = 5;                                              % time interval, s

    t = (ti:dt:tf)';                                     % time vector, s
    lt = length (t);                                     % length of the time vector


% Initial state -------------------------------------------------------------------------
% ---------------------------------------------------------------------------------------
    % NOMENCLATURE:
    %    x - molar fraction (-)
    %    T - temperature (K)
    %    h - level (m)
    %    r - radius of pores (m)
    %    lift - valve lift (stem position) (m)
    % 
    %    F - filter
    %    R - reactor
    %    D - decanter
    %    L - light phase (decanter)
    %    H - heavy phase (decanter)
    %    TG - triglycerides
    %    DG - diglycerides
    %    MG - monoglycerides
    %    M  - methanol
    %    E  - ester
    %    G  - glycerol
    %
    % EXAMPLE: xRTG is the molar fraction of TG in the reactor.

                 % Reactor
                 %  1-xRTG   2-xRDG    3-xRMG   4-xRM   5-xRE    6-xRG         7-TR
    sv0( 1: 7) = [0.002455 0.000553 0.0000467 0.42353 0.43022  0.14319  60.4+273.15];

                 % Decanter (light phase)
                 %    8-xLTG     9-xLDG    10-xLMG     11-xLM     12-xLE     13-xLG
    sv0( 8:13) = [4.2864e-03 9.6570e-04 8.1554e-05 2.4287e-01 7.5098e-01 8.1550e-04];
 
                 % Decanter (heavy phase, interface level, and temperature)
                 %    14-xHM     15-xHE     16-xHG  17-hH      18-TD
    sv0(14:18) = [6.6574e-01 1.5852e-04 3.3410e-01    0.5  50+273.15];

                 % Filter
                 % 19-r
    sv0(19)    = [pp.rclean];

                 % Valves
                 % 20-lifto  21-liftH
    sv0(20:21) = [       40      28.5];

    lsv = length (sv0);                                          % # of state vrs


% Initial input variables ---------------------------------------------------------------
% ---------------------------------------------------------------------------------------
    %             1         2     3         4      5       6
    %       vinputo      Tmet  Fmet      Toil  Qheat vinputH
    %             %         K  kg/h         K      W       %
    u0 =      [40.0 50+273.15   657 60+273.15  23615    28.5];   % initial input values

    lu = length (u0);                                            % # of input vrs


% Disturbances (ARMAX settings for: loads + manipulated vrs of loops in MANUAL) ---------
% ---------------------------------------------------------------------------------------
    % NOTE:
    %    For inputs that are manipulated vrs under a control loop in AUTO mode,
    %    the ARMAX model doesn't apply: phi, theta, eta, unoise_std, and d set
    %    by the user won't be taken into consideration.

  % ARMAX (1, 1, 1) parameters
    %                      1     2     3    4     5     6
    %                vinputo  Tmet  Fmet Toil Qheat vinputH
    armax.phi        = [   0   .05   .03    0   .01     0];  % weight for input at t-1
    armax.theta      = [   0   .06   .07    0   .00     0];  % weight for noise at t-1
    armax.eta        = [   0   .95   .97    0   .98     0];  % weight for exogenous input
    armax.unoise_std = [   0   .10  1.15    0   .01     0];  % noise standard deviation
                                                             % [armax.unoise_std] = [u0]
                                                             
  % Exogenous inputs for disturbances along time
    d = u0 .* ones (lt, lu);                                % defaults (constant) from u0
    d(:,2) = d(:,2) +3*sin (pi/(12*3600)*t);                % daily changes for Tmet, K
    d(:,5) = d(:,5) +1000*heaviside (t-100000);             % deliberate step in Qheat, W


% Control settings ----------------------------------------------------------------------
% ---------------------------------------------------------------------------------------

  % Loop mode, setpoint, measured vr, manipulated vr, & controller parameters
  % (as many as control loops)
    sp1 = (60.4+273.15)*ones (lt, 1);               % sp profile for controlled vr TR, K
    sp2 = (50+273.15)*ones (lt, 1);                 % sp profile for controlled vr TD, K
    sp3 = 0.5*ones (lt, 1);                         % sp profile for controlled vr hH, m
    sp4 = 3000*ones (lt, 1) +100*heaviside (t-5000);% sp profile controlled vr Foil, kg/h 

        %  control loop:       1       2       3       4
        %  controlled vr:     TR      TD      hH    Foil
        %                      K       K       m    kg/h
        %  manipulated (u): Toil   Qheat vinputH vinputo
        %                      K       W       %       %
    mode            = [        1       0       1       1];  % loop mode (MANUAL/AUTO)
    sp              = [      sp1     sp2     sp3     sp4];  % loop setpoint profile
    pvindex         = [        1       2       3       4];  % loop measurement (pv index)
    uindex          = [        4       5       6       1];  % loop manipulated (u index)
    pid.kc          = [       12  -10542   -1315  3.4e-3];  % [u]/[pv]
    pid.taui        = [    16960    8350    3600      15];  % s
    pid.taud        = [        0       0       0       0];  % s
    pid.lower_bound = [30+273.15       0       0       0];  % [u]
    pid.upper_bound = [65+273.15   40000     100     100];  % [u]

  % Number of time intervals to get a new control action
    nic = 4;


% Sensors faults activation/deactivation ------------------------------------------------
% ---------------------------------------------------------------------------------------
    % NOTE: Possible faults affecting the sensors and how to set them:
    %                   pv = signal * [ a*v +b +noise_std*randn(1) ]
    %       where pv - a sensor output (measured variable)
    %              v - a sensor input (function of sv and u)
    %
    % For signal = 1 (sensor is "alive"):
    %       scaling:        a = constant!=1 or a(t) &  b = 0           with 0<a<infinity
    %       drift:          a = 1                   &  b = b(t)
    %       bias:           a = 1                   &  b = constant    with b<0 or b>0
    %       stuck sensor:   a = 0                   &  b = constant    min < b < max
    %       pure noise:     a = 0                   &  b = 0
    %
    % For signal = 0 (sensor is "dead"):
    %       loss of signal: a = any                 &  b =  any       (a & b don't apply)


    nsensors = 5;                              % # of sensors
                                               % nsensors has to be >= # of control loops

  % Default faults (none)
    sig = ones (lt, nsensors);
    a = ones (lt, nsensors);
    b = zeros (lt, nsensors);
    sfaults.isIntermit = zeros (1, nsensors);

  % Setting up faults (by overwriting the defaults above)
    b(:,2) = 5e-6*(t-100000).*heaviside (t -100000);                % drift in TD sensor

    b(:,5) = 5e3*( heaviside (t- 60000)     ...                     % a bias in
                  -heaviside (t-80000) );                           % sensor 5 (DPfilter)


                  % sensor       1        2        3        4       5
       % measured vr (pv):      TR       TD       hH     Foil DPfilter
       %                         K        K        m     kg/h       Pa
    sfaults.signal     = [sig(:,1) sig(:,2) sig(:,3) sig(:,4) sig(:,5)];     % -
    sfaults.a          = [  a(:,1)   a(:,2)   a(:,3)   a(:,4)   a(:,5)];     % [pv]/[sv] 
    sfaults.b          = [  b(:,1)   b(:,2)   b(:,3)   b(:,4)   b(:,5)];     % [pv]
    sfaults.isIntermit = [       0        1        0        0        0];     % -
    sfaults.tmaxInterm = [       0     3600        0        0        0];     % s
    sfaults.noise_std  = [     0.1      0.1     5e-3        5      300];     % [pv]


% Process deteriorations/faults activation/deactivation ---------------------------------
% ---------------------------------------------------------------------------------------
  % Default faults (none)
    pfaults.clog_fraction = 0;
    pfaults.DPclean = Inf;
    pfaults.ratio_robs_r = 1;
    pfaults.fouling = 0;
    pfaults.foulingpar = [1];

  % Clogging of the oil filters
    pfaults.DPclean = 1e5;                    % DPfilter at which cleanings are done, Pa
    pfaults.clog_fraction = 5.95e-7;          % fraction adsorbed to pores walls, -
    pfaults.filter_std = 5e-15;               % standard deviation for zF/nF, m

  % Catalyst activity loss by consumption in side reactions
    pfaults.ratio_robs_r = .9;                % robserved/r, dimensionless

  % Fouling in the heat exchanger
    pfaults.fouling = 1;                      % 0: no fouling; 1: linear fouling
    pfaults.foulingpar = [3e-7];              % changing rate of the fouling resistance


% Valves faults activation/deactivation -------------------------------------------------
% ---------------------------------------------------------------------------------------
  % Stiction
    %  S - magnitude of the (deadband)+(slip-jump)
    %  J - magnitude of the slip-jump

    %  J=0 & S=0: no stiction
    %        J=0: pure deadband
    %        J<S: undershoot case with jump
    %        J=S: no offset case (no deadband)                  
    %        J>S: overshoot case

              % valves  1  2
    vfaults.S      = [  0  0 ];                % deadband+jump for each valve, %
    vfaults.J      = [  0  0 ];                % jump for each valve, %
    vfaults.uindex = [  6  1 ];                % index of "u" containing the
                                               % controller order, for each valve
    nvalves = length(vfaults.uindex);

