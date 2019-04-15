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

% Function to simulate the measurements from the state variable vector sv and the input variable vector uu, possibly affected by diverse faults


  function pv = measurements (i, sv, uu, p, sfaults)


  % Measures
    % reactor temperature
    pv(1) = sv(7);                                             % K

    % decanter temperature
    pv(2) = sv(18);                                            % K

    % interface level in the decanter
    pv(3) = sv(17);                                            % m

    % mass flow rate of oil
    Qo = Qoil (sv(19), uu(1)/100, p);                          % m^3/s
    pv(4) = Qo * p.roo;                                        % kg/s

    % pressure drop across the filter
    pv(5) = p.K4F * Qo ./ sv(19).^4;                            % Pa


  % Possible faults affecting the measure(s)
    pv = sfaults.signal(i,:) .* ( sfaults.a(i,:).*pv                            ...
                                 +sfaults.b(i,:)                                ...
                                 +sfaults.noise_std .* randn (1, length(pv)) );


  end
