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

% Definition of the system parameters.
% The user is advised to NOT MODIFY THIS FILE if s/he does not have a good knowledge of the process to warranty that the changes are consistent and realistic.


  % number of chemical species considered
    p.nc = 6;

  % kinetic parameters
    p.k0 = [ 1.3613e-01  4.6645e+01 3.8708e-01 1.4710e+07 4.5477e+04 0 ];          % m3/(mol s)
    p.Ea = [ 3.0225e+04  4.4646e+04 2.8941e+04 7.2779e+04 5.6093e+04 0 ];          % J/mol
    p.dHr = [ 15699.0  36899.0  -58906.0];                                         % J/mol

  % physical properties & constants
              %    TG      DG      MG       M       E      G
    p.ro    = [  954.0   983.0  1030.0   757.0   844.0  1340.0 ];                  % kg/m3 (at 60C)
    p.M     = [  0.854   0.600   0.346   0.032   0.286   0.092 ];                  % kg/mol
    cp      = [ 2110.0  2188.0  2381.0  2785.0  2146.0  2556.0 ];                  % J/(kg K)
    p.cpmol = cp .* p.M;                                                           % J/(mol K)
    p.vmol = Vmolar (p.M, p.ro);                                                   % m3/mol
    p.R = 8.314472;                                                                % J/(mol K)

  % oil stream
    p.xo = [1 0 0 0 0 0];
    p.Mo = p.M(1);                                                                 % kg/mol
    p.roo = p.ro(1);                                                               % kg/m3
    p.vmolo = p.vmol(1);                                                           % m3/mol
    p.cpmolo = p.cpmol(1);                                                         % J/(mol K)
    pp.visco=20.8e-3;                                                              % Pa s
    
  % methanol+catalyst stream
    p.xm = [0 0 0 1 0 0];
    p.Mm = p.M(4);                                                                 % kg/mol
    p.rom = p.ro(4);                                                               % kg/m3
    p.vmolm = p.vmol(4);                                                           % m3/mol
    p.cpmolm = p.cpmol(4);                                                         % J/(mol K)

  % geometric parameters
    p.VR = 20;                                                                     % m3
    p.aD = 6;                                                                      % m2
    p.hD = 1.5;                                                                    % m
    pp.zF = 1e-3;                                                                  % m

  % equipment parameters
    % heavy phase valve
    p.kvH = 1;                                        % valve gain                 % %/%
    p.tauvH = 15;                                     % valve time constant        % s
    p.NHmax = 10;                                     % valve maximum flow         % mol/s

    % oil valve
    p.kvo = 1;                                        % valve gain                 % %/%
    p.tauvo = 15;                                     % valve time constant        % s
    pp.cv = 4.86e-6;                                  % valve constant             % m^3/(s Pa^(1/2))

    % pump
    pp.Ppump = 2.07e5;                                                             % Pa

    % oil filter
    pp.rclean = 15e-6;                                % clean pores                % m
    pp.np = 1.7e8;                                    % number of pores            % -
