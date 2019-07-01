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

% Function to generate modified signals from the controllers orders taking stiction into consideration when applicable


  function [position] = valves (nvalves, order, orderOLD, positionOLD, vfaults, dt)

  persistent duOLD d stp us                       % keep these vrs in memory until next call


  % Initialization (for all valves) at the first time this function is called
    if isempty (d)                                % For each valve:
      duOLD = zeros (1, nvalves);                 % duOLD = u(t-1) - u(t-2)
      stp = zeros (1, nvalves);                   % valve is stopped now
      us = orderOLD +(vfaults.S -vfaults.J)/2;    % order when the valve initially stopped
      d = -ones (1, nvalves);                     % direction of frictional force
    end


  % For each valve, update the signal taking stiction into account
    for k = 1 : nvalves
      ord = order(k);
      ordOLD = orderOLD(k);
      posOLD = positionOLD(k);
      S = vfaults.S(k);
      J = vfaults.J(k);
      output = stiction (ord, ordOLD, posOLD, duOLD(k), us(k), stp(k), d(k), S, J);
      position(k) = output(1);
      duOLD(k) = output(2);
      us(k) = output(3);
      stp(k) = output(4);
      d(k) = output(5);

    end


  end
