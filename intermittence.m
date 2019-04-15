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

% Function to simulate intermittent sensor faults (it applies to user defined bias, drift, scaling, stuck sensor, or loss of signal if sfaults.isIntermit is flagged on)


  function [a, b, signal] = intermittence (t, sfaults)


    nsensors = size (sfaults.a,2);
    ti = t(1);
    tf = t(end);
    dt = t(2) -t(1);
    lt = size (t, 2);

    a = sfaults.a;
    b = sfaults.b;
    signal = sfaults.signal;

    for k = 1 : nsensors                                            % for each sensor
       if (sfaults.isIntermit(k))                                   % if intermittence is on

          % generation of random intermittence periods
          tt = ti;
          while (tt < tf)
            tnew = tt +sfaults.tmaxInterm(k)*rand;
            tnew = min (tnew -mod (tnew, dt), tf);
            if (rand < 0.5)                                         % if rand is in the lower half
              %turning off the sensor fault
              ind1 = round ((  tt-ti)/dt +1);
              ind2 = round ((tnew-ti)/dt +1);
              signal(ind1:ind2,k) = ones (ind2-ind1+1, 1);
              a(ind1:ind2,k) = ones (ind2-ind1+1, 1);
              b(ind1:ind2,k) = zeros (ind2-ind1+1, 1);
            end
            tt = tnew;
          end

       end
    end


  end
