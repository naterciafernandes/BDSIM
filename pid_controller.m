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

% PID controller


  function output = pid_controller (setpoint, measure, pid)

  persistent error1 error2 outputOLD                % keep these vrs in memory until next call


  % Initialization in the first time this function is called
    if isempty (error1)
      error1 = pid.ierror1;
      error2 = pid.ierror2;
      outputOLD = pid.ioutput;
    end

  % New order
    erro = setpoint -measure;
    output = outputOLD +pid.kc .* ( erro -error1 +pid.dt./pid.taui.*erro        ...
                                    +(erro-2*error1+error2).*pid.taud/pid.dt );

  % Bounds checks
    output (output < pid.lower_bound) = pid.lower_bound (output < pid.lower_bound);
    output (output > pid.upper_bound) = pid.upper_bound (output > pid.upper_bound);

  % Save vrs for next time instant
    error2 = error1;
    error1 = erro;
    outputOLD = output;


  end
