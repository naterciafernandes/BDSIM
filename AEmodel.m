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

% Algebraic Equations model of the process model (washer + dryer)


  function [xLend, yLend] = AEmodel (sv, p)


    xL = sv(p.nc+2:2*p.nc+1);
    xH = zeros(size(xL));
    xH(4:6) = sv(2*p.nc+3:2*p.nc+5);

    xLend = xL ./ (sum (xL(1:3)) + xL(5));                 % complete elimination of M, G, & H2O
    xLend(4) = 0;                                          % no M
    xLend(6) = 0;                                          % no G
    yLend = p.M .* xLend(1:6) ./ sum (p.M.*xLend(1:6));    % expressed as mass fraction


  end
