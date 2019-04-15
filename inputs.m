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

% Function to generate the input variables.  It includes the loads and the manipulated variables.


  function u = inputs (i, u, uindexAUTO, armax, d, nic, pidAUTO, spAUTO, measAUTO)

  persistent unoiseOLD                                % keep this vr in memory until next call


  % Initialization in the first time this function is called
    if isempty (unoiseOLD)
      unoiseOLD = armax.unoise;
    end

  % disturbances (ARMAX (1, 1, 1)):
    unoise = armax.unoise_std .* randn(1,length(u));
    u = armax.phi.*u +armax.theta.*unoiseOLD +unoise +armax.eta.*d(i-1,:);
    unoiseOLD = unoise;

  % manipulated vrs
    if (~mod (i-1, nic))  % time to update control actions for controllers in AUTO mode
      u(uindexAUTO) = pid_controller (spAUTO, measAUTO, pidAUTO);
    end


  end
