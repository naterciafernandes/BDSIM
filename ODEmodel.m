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

% Ordinary Differential Equations of the process model (filter + reactor + heat exchanger + decanter + actuators)


  function dsvdt = ODEmodel (sv, t, p, u)


% Oil filter ------------------------------------------------------------------
% -----------------------------------------------------------------------------
    lifto = sv(20);                                               % valve lift of the oil stream
    r = sv(2*p.nc+7);                                              % radius of filter pores

  % Changes due to filter clogging
    [Qo drdt] = clogging (r, lifto/100, p);
    No = Qo *p.roo/p.Mo;

% Reactor ---------------------------------------------------------------------
% -----------------------------------------------------------------------------
    xR = sv(1:p.nc)';
    TR = sv(p.nc+1);
    Tm = u(2);
    Nm = u(3);
    To = u(4);

  % mixture amount and properties
    aux = sum (p.vmol .* xR);                                      % m³ mol⁻¹
    nR = p.VR / aux;                                               % mol
    cpmolR = cpmx (p.cpmol, xR);                                   % J/(mol K)
    MR = Mmx (p.M, xR);

  % chemical reaction rates
    CR = nR * xR / p.VR;                                           % mol m⁻³, molar concentration in R
    [rx r] = rxrates (p.k0, p.Ea, p.R, CR, TR);

  % mass balances for the nc components
    dxRdt = ( Nm*(p.xm-xR)   +No*(p.xo-xR)  +rx*p.VR ) / nR;

  % energy balance
    dTRdt = ( Nm *p.cpmolm *(Tm-TR)                  ...
             +No *p.cpmolo *(To-TR)                  ...
             +p.VR *sum (-p.dHr.*r) ) / (nR*cpmolR);

  % leaving flow
    NR = ( p.Mo * No                                          ...
          +p.Mm * Nm                                          ...
          -p.VR * sum (p.M.*dxRdt) / sum (p.vmol.*xR) ) / MR  ...
         +p.VR * sum (p.vmol.*dxRdt) / (sum (p.vmol.*xR))^2;


% Heat exchanger --------------------------------------------------------------
% -----------------------------------------------------------------------------
    Qheat = u(5);

    Theat = TR -p.factor * Qheat / (NR * cpmolR);    % K               


% Decanter --------------------------------------------------------------------
% -----------------------------------------------------------------------------
    liftH = sv(21);                       % valve lift of the leaving heavy phase flow
    xL = sv(p.nc+2:2*p.nc+1)';             % all nc components
    xH(1:3) = 0;                           % TG, DG, MG don't go to heavy phase
    xH(4:6) = sv(2*p.nc+2:2*p.nc+4)';      % only 3 components
    hH = sv(2*p.nc+5);
    TD = sv(2*p.nc+6);

  % split fractions
    aux = sum (xR(4:6));                   % feed composition expressed not considering
    x0M = xR(4) / aux;                     % the residual amounts of TG, DG, and MG
    x0G = xR(6) / aux;                     % (w/ which the neural network can't cope)
    eta = split (x0M, x0G, Theat);         % Neural Network: split fractions for E, M, G.  [T] = K
    etaL(1:3) = 1;                         % TG, DG, MG assumed to have eta = 1
    etaL(4) = eta (2);                     % M split fraction
    etaL(5) = eta(1);                      % E split fraction
    etaL(6) = eta(3);                      % G split fraction
    etaH = 1 -etaL;

  % light phase mass balances
    aux = sum (etaL .* xR);
    hL = p.hD -hH;
    nL = p.aD * hL / sum (p.vmol.*xL);
    dxLdt = aux * NR/nL * (etaL/aux .* xR - xL);

  % heavy phase mass balances
    aux = sum (etaH .* xR);
    aux1 = sum (p.vmol.*xH);
    nH = hH * p.aD / aux1;
    NH = liftH/100*p.NHmax;
    dxHdt = aux * NR/nH * (etaH/aux .* xR - xH);
    dhHdt = ( (NR*aux -NH) * aux1 +nH * sum (p.vmol.*dxHdt) ) / p.aD;

  % energy balance
    cpmolL = cpmx (p.cpmol, xL);
    cpmolH = cpmx (p.cpmol, xH);
    dTDdt = NR*cpmolR / ((nL*cpmolL +nH*cpmolH)) * (Theat-TD);


% Valves-----------------------------------------------------------------------
% -----------------------------------------------------------------------------
    vinputo = u(1);
    vinputH = u(6);

    dliftodt = (p.kvo*vinputo - lifto) / p.tauvo;
    dliftHdt = (p.kvH*vinputH - liftH) / p.tauvH;


% Derivatives vector of the state variables -----------------------------------
% -----------------------------------------------------------------------------
    dsvdt(1:p.nc) = dxRdt;
    dsvdt(p.nc+1) = dTRdt;
    dsvdt(p.nc+2:2*p.nc+1) = dxLdt;
    dsvdt(2*p.nc+2:2*p.nc+4) = dxHdt(4:6);
    dsvdt(2*p.nc+5) = dhHdt;
    dsvdt(2*p.nc+6) = dTDdt;
    dsvdt(2*p.nc+7) = drdt;
    dsvdt(2*p.nc+8) = dliftodt;
    dsvdt(2*p.nc+9) = dliftHdt;
    dsvdt = dsvdt';


  end

% eof
