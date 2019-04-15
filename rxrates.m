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

% transesterification reaction rates


  function [rx r] = rxrates (k0, Ea, R, C, T)


    kr = k0 .* exp (-Ea / (R*T));                          % [m³ mol⁻¹ s⁻¹], reactions constants
    r(1) = kr(1) * C(1) * C(4) -kr(2) * C(2) * C(5);
    r(2) = kr(3) * C(2) * C(4) -kr(4) * C(3) * C(5);
    r(3) = kr(5) * C(3) * C(4) -kr(6) * C(6) * C(5);

    rx(1) = -r(1);                                         % TG
    rx(2) =  r(1) -r(2);                                   % DG
    rx(3) =        r(2) -r(3);                             % MG
    rx(4) = -r(1) -r(2) -r(3);                             % M
    rx(5) =  r(1) +r(2) +r(3);                             % E
    rx(6) =              r(3);                             % G


  end
