# GFM-IAIF

Glottal Flow Model-based Iterative Adaptive Inverse Filtering


## Description

This function estimates the linear prediction coefficients of both vocal tract
and glottis filters from a speech signal frame with the GFM-IAIF method [1].

The latter is an extension of IAIF [2], with an improved pre-emphasis step, that
allows to extract a wide-band glottis response, incorporating both glottal
formant and spectral tilt characteristics.

This function is based on the iaif.m implementation from the COVAREP toolbox
[3].


#### References
[1] O. Perrotin and I. V. McLoughlin (2019)
     "A spectral glottal flow model for source-filter separation of
     speech", in IEEE International Conference on Acoustics, Speech, and
     Signal Processing (ICASSP), Brighton, UK, May 12-17, pp. 7160-7164.

 [2] P. Alku (1992)
     "Glottal wave analysis with pitch synchronous iterative adaptive
     inverse filtering", Speech Communication, 11(2-3), pp. 109-118.

 [3] G. Degottex, J. Kane, T. Drugman, T. Raitio and S. Scherer (2014)
     "COVAREP - A collaborative voice analysis repository for speech
     technologies", in IEEE International Conference on Acoustics, Speech
     and Signal Processing (ICASSP), Florence, Italy, May 4-9, pp.
     960-964.


## Use    

#### Inputs
- x 	:  [Nx1]	Speech signal frame
- (nv)	:  [1x1]	Order of LP analysis for vocal tract (def. 48)
- (ng)	:  [1x1]	Order of LP analysis for glottal source (def. 3)
- (d)  	:  [1x1]	Leaky integration coefficient (def. 0.99)
- (win)	:  [Nx1]	Window used before LPC (def. Hanning)

#### Outputs
-  av  	:  [1xnv]	LP coefficients of vocal tract contribution
-  ag 	:  [1xng]	LP coefficients of glottis contribution

#### Examples
- [av,ag] = gfmiaif(x) provides the LP coefficients of vocal tract and glottis with default parameters
- [av,ag] = gfmiaif(x,nv,ng,d,win) allows to choose parameters

GFM-IAIF has been designed on the assumption that a third order filter allows to
describe most of the glottis-related timbre variations (e.g., tenseness, effort)
with a compact set of parameters. Thus, the use of ng = 3 is highly encouraged.


## How to cite

Cite reference [1] above


## License

 __Copyright (c) 2019 Univ. Grenoble Alpes, CNRS, Grenoble INP, GIPSA-lab__

This file is free software; you can redistribute it and/or modify it under the
terms of the GNU Lesser General Public License as published by the Free Software
Foundation; either version 3 of the License, or (at your option) any later
version.

This file is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.


## Author

 Olivier Perrotin olivier.perrotin@gipsa-lab.grenoble-inp.fr
