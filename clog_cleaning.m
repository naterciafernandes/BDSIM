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

% Function to simulate the cleaning of the oil filter


  function [r K2F K4F tclean] = clog_cleaning (t, p, pp, pfaults)


  % Time instant when the cleaning was performed
    tclean = t;

  % Update of the radius of the filter pores
    r = pp.rclean;

  % Adding consistent variability to the filter constants (new filter)
    aux1 = 4 * pp.visco / pi;
    aux2 = aux1 * pp.cv^2;
    aux1 = 2 * aux1;

    var = pfaults.filter_std * randn(1);

    K2F = p.K2F +aux2*var;
    K4F = p.K4F +aux1*var;


  end
