% GFM-IAIF
% Glottal Flow Model-based Iterative Adaptive Inverse Filtering
%
% Description
%   This function estimates the linear prediction coefficients of both
%   vocal tract and glottis filters from a speech signal frame with the
%   GFM-IAIF method [1].
%   The latter is an extension of IAIF [2], with an improved pre-emphasis
%   step, that allows to extract a wide-band glottis response,
%   incorporating both glottal formant and spectral tilt characteristics.
%   This function is based on the iaif.m implementation from the COVAREP
%   toolbox [3].
%
%
% Inputs
% s_gvl :  [Nx1]	Speech signal frame
% (nv)	:  [1x1]	Order of LP analysis for vocal tract (def. 48)
% (ng)	:  [1x1]	Order of LP analysis for glottal source (def. 3)
% (d)  	:  [1x1]	Leaky integration coefficient (def. 0.99)
% (win)	:  [Nx1]	Window used before LPC (def. Hanning)
%
% Outputs
%  av  	:  [1xnv]	LP coefficients of vocal tract contribution
%  ag 	:  [1xng]	LP coefficients of glottis contribution
%  al 	:  [1x2]	LP coefficients of lip radiation contribution
%
%
% Examples
%  [av,ag,al] = gfmiaif(x) provides the LP coefficients of vocal tract,
%               glottis and lip radiation with default parameters
%  [av,ag,al] = gfmiaif(x,nv,ng,d,win) allows to choose parameters
%
% GFM-IAIF has been designed on the assumption that a third order filter
% allows to describe most of the glottis-related timbre variations (e.g.,
% tenseness, effort) with a compact set of parameters.
% Thus, the use of ng = 3 is highly encouraged.
%
%
% References
%  [1] O. Perrotin and I. V. McLoughlin (2019)
%      "A spectral glottal flow model for source-filter separation of
%      speech", in IEEE International Conference on Acoustics, Speech, and
%      Signal Processing (ICASSP), Brighton, UK, May 12-17, pp. 7160-7164.
%
%  [2] P. Alku (1992)
%      "Glottal wave analysis with pitch synchronous iterative adaptive
%      inverse filtering", Speech Communication, 11(2-3), pp. 109-118.
%
%  [3] G. Degottex, J. Kane, T. Drugman, T. Raitio and S. Scherer (2014)
%      "COVAREP - A collaborative voice analysis repository for speech
%      technologies", in IEEE International Conference on Acoustics,
%      Speech and Signal Processing (ICASSP), Florence, Italy, May 4-9,
%      pp. 960-964.
%
% How to cite
%   Cite reference [1] above
%
%
% Copyright (c) 2019 Univ. Grenoble Alpes, CNRS, Grenoble INP, GIPSA-lab
%
% License
%   This file is free software; you can redistribute it and/or modify it
%   under the terms of the GNU Lesser General Public License as published
%   by the Free Software Foundation; either version 3 of the License, or
%   (at your option) any later version.
%   This file is distributed in the hope that it will be useful, but
%   WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser
%   General Public License for more details. 
%
% Author
%  Olivier Perrotin olivier.perrotin@gipsa-lab.grenoble-inp.fr
%


function [av,ag,al] = gfmiaif(s_gvl,nv,ng,d,win)

% ----- Set default parameters -------------------------------------------

if nargin < 5
    % Window for LPC estimation
    win = hann(length(s_gvl));
    if nargin < 4
        % Lip radiation leaky integration coefficient
        d = 0.99;
        if nargin < 3
            % Glottis LPC order
            ng = 3;
            if nargin < 2
                % Vocal tract LPC order
                nv = 48;
            end
        end
    end
end


% ----- Addition of pre-frame --------------------------------------------

% For the successive removals of the estimated LPC envelopes, a
% mean-normalized pre-frame ramp is added at the beginning of the frame
% in order to diminish ripple. The ramp is removed after each filtering.
Lpf = nv+1;                         % Pre-frame length
x_gvl = [linspace(-s_gvl(1),s_gvl(1),Lpf)' ; s_gvl];    % Prepend
idx_pf = (Lpf+1):length(x_gvl);     % Indexes that exclude the pre-frame


% ----- Cancel lip radiation contribution --------------------------------

% Define lip radiation filter
al = [1 -d];

% Integration of signal using filter 1/[1 -d z^(-1)]
% - Input signal (for LPC estimation)
s_gv = filter(1,al,s_gvl);
% - Pre-framed input signal (for LPC envelope removal)
x_gv = filter(1,al,x_gvl);


% ----- Gross glottis estimation -----------------------------------------

% Iterative estimation of glottis with ng first order filters

ag1 = lpc(s_gv.*win,1);         % First 1st order LPC estimation

for i = 1:ng-1
    % Cancel current estimate of glottis contribution from speech signal
    x_v1x = filter(ag1,1,x_gv);	% Inverse filtering
    s_v1x = x_v1x(idx_pf);      % Remove pre-ramp

    % Next 1st order LPC estimation
    ag1x = lpc(s_v1x.*win,1);   % 1st order LPC

    % Update gross estimate of glottis contribution
    ag1 = conv(ag1,ag1x);	% Combine 1st order estimation with previous
end


% ----- Gross vocal tract estimation -------------------------------------

% Cancel gross estimate of glottis contribution from speech signal
x_v1 = filter(ag1,1,x_gv);      % Inverse filtering
s_v1 = x_v1(idx_pf);            % Remove pre-ramp

% Gross estimate of the vocal tract filter
av1 = lpc(s_v1.*win,nv);        % nv order LPC estimation


% ----- Fine glottis estimation ------------------------------------------

% Cancel gross estimate of vocal tract contribution from speech signal
x_g1 = filter(av1,1,x_gv);      % Inverse filtering
s_g1 = x_g1(idx_pf);            % Remove pre-ramp

% Fine estimate of the glottis filter
ag = lpc(s_g1.*win,ng);         % ng order estimation


% ----- Fine vocal tract estimation --------------------------------------

% Cancel fine estimate of glottis contribution from speech signal
x_v = filter(ag,1,x_gv);        % Inverse filtering
s_v = x_v(idx_pf);              % Remove pre-ramp

% Fine estimate of the vocal tract filter
av = lpc(s_v.*win,nv);          % nv order LPC estimation


end
