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

% Function to lump some parameters together for posterior numerical calculus


  function [K1F K2F K3F K4F] = clogging_kit (pp, pfaults)


    K1F = 1e12 * pfaults.clog_fraction / (2*pi*pp.zF*pp.np); % factor 1e12 => rp in micrometers
    K2F = 1e24 * 4 * pp.visco * pp.zF/(pp.np*pi) * pp.cv^2;  % factor 1e24 => rp in microm in Qoil
    K3F = pp.Ppump * pp.cv^2;
    K4F = 1e24 * 8*pp.visco * pp.zF / (pp.np *pi);           % factor 1e24 => rp in microm in DPfilter


  end
