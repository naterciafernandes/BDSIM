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

% Function to compute the cp of a mixture, from cp(i) and x(i)
%
%    if molar cp(i) and molar fraction x(i) => molar cp_mx  [J mol⁻¹ K⁻¹]
%    if massic cp(i) and mass fractions x(i) => massic cp_mx [J kg⁻¹ K⁻¹]


  function cp_mx = cpmx (cp, x)


    cp_mx = sum (x.*cp);


  end
