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

% Stiction model for valves
%      (according to
%      Kano, Maruta, Kugemoto, and Shimizu,
%      'Practical Model and Detection Algorithm for Valve Stiction',
%      IFAC Symposium on Dynamics and Control of Process Systems.

%      S  - magnitude of the deadband plus slip-jump  (it includes J) 
%      J  - magnitude of the slip-jump

%      J=0 & S=0: no stiction
%      J=0: pure deadband
%      J<S: undershoot case with jump
%      J=S: no offset case                   
%      J>S: overshoot case 


  function output = stiction (u, uOLD, yOLD, duOLD, us, stp, d, S, J)


  % Check if lower and upper bounds of the controller output are satisfied
    min = 0;
    max = 100;

    if u >= max                            % upper saturation check
      u = max;
    elseif u <= min                        % lower saturation check
      u = min;
    end

  % Variation of the controller order
    du = u -uOLD;

  % Algorithm
    if du*duOLD <= 0 && stp ==0   % when valve stops or changes its direction
      us = uOLD;                        % update us
      stp = 1;                          % resting state flag
    end

    if stp == 0                    % when valve is in a moving state
      y = u -d/2*(S-J);
      stp = 0;
    elseif -d*(u-us) > S           % when valve changes its direction & overcomes friction
      d = -d;
      y = u -d/2*(S-J);
      stp = 0;
    elseif d*(u-us) > J            % when valve keeps its direction & overcomes friction
      y = u -d/2*(S-J);
      stp = 0;
    else                           % otherwise
      y = yOLD;                    % valve doesn't move
    end

    output = [y du us stp d];


  end
