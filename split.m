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

% Neural network to compute the split fractions (eta) that go to the light phase for E, M, and G
% T should enter in K
%
% according to 
%   Brásio, Romanenko, and Fernandes
%   'Development of a Numerically Efficient Biodiesel Decanter Simulator',
%   Operational Research, Springer-Verlag.
%   DOI:10.1007/978-3-319-20328-7_6


  function eta = split (xM, xG, T)


  % constants of the neural network
    mn = [0.4429080932784634  0.1430123456790114  315.4873799725652];
    st = [0.05769114669974407 0.07483374254327435  10.3923004820672];

    pesos_W = [ 0.0001626573488477621, 0.0001762383521689282, 0.008436427201807458, 0.0001270214941574136, 0.004297765775023732;
                0.005798439102391745,  0.007933451534695593,  2.26649586627043,    -0.2986375856202046,    0.7311754343879735;
               -0.001364318678976015,  0.0007368268046611492, 0.3912844089747987,   0.002646628766137311,  0.1563496596243398; ];

    pesos_w = [ -0.2803986419064017,  -0.1333039855614737, -0.4777087005027253;
                -1.089354327582992 ,  -0.569687192601498 ,  0.2811677238454339;
                -0.08556871701830951, -0.9941218009650442,  0.03066753440441023;
                 0.1392959274375281,   0.3224633500842102, -0.06143635056503905;
                 0.07424143386924453,  1.155133146934136,  -0.01735683560849739];

    bias_theta = [0.6227988072448851,
                  1.158840062875017,
                 -2.463591740961228,
                  0.2729954333628518,
                  2.246274101076976];

    bias_gamma = [1.003727297064683,
                  1.891158698301678,
                  0.2350237516771797];

  % input vector:
    X = [xM xG T];
    X = (X-mn)./st;

  % split fractions (1-E, 2-M, 3-G)
    eta = pesos_W * tanh( pesos_w*X' + bias_theta ) + bias_gamma;


  end
