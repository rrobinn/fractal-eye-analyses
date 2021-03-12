This directory or zip-file contains programs to make surrogate cloud fields using the Iterative 
Amplitude Adapted Fourier Transform (IAAFT) method. For more information see:
http://www.meteo.uni-bonn.de/victor/themes/surrogates/

Installation
1) Put all files into one (new) directory.
2) Start Matlab.
3) Add the new directory to you path or change into this directory.
4) Run surrogate_1d_1d and see what happens.

Note
1. The names of all main programs start with surrogate*, the other files are help files.
2. In the m-files surrogate*, there is a function call: load_?d_data(1). By increasing this 
number you can get more examples. See the load_?d_data files to see which numbers make 
sense.
3. Best try the programs in ascending order of dimension: surrogate_1d_1d, surrogate_1d_2d, 
surrogate_2d_2d_horizontal, surrogate_2d_2d_vertical, surrogate_2d_3d, surrogate_3d_3d, or 
in order of increasing complexity: surrogate_1d_1d, surrogate_2d_2d_horizontal, 
surrogate_2d_2d_vertical, surrogate_3d_3d, surrogate_1d_2d, surrogate_2d_3d.

