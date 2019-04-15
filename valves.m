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


  % For each valve, update the signal taking stiction into account
    for k = 1 : nvalves
      S = vfaults.S(k);
      J = vfaults.J(k);
      position(k) = stiction (order(k), orderOLD(k), positionOLD(k), S, J);
    end


  end
