function compile(opt, verb, mex_file)
% Build MEX source code.
%   All compiled binaries are placed in the bin/ directory.
%
%   Windows users: Windows is not yet supported. You can likely 
%   get the code to compile with some modifications, but please 
%   do not email to ask for support.
%
% Arguments
%   opt   Compile with optimizations (default: on)
%   verb  Verbose output (default: off)

if ispc
  error('This code is not supported on Windows.');
end

if nargin < 1
  opt = true;
end

if nargin < 2
  verb = false;
end

% Start building the mex command
mexcmd = 'mex -outdir ubDetection';

% Add verbosity if requested
if verb
  mexcmd = [mexcmd ' -v'];
end

% Add optimizations if requested
if opt
  mexcmd = [mexcmd ' -O'];
  mexcmd = [mexcmd ' CXXOPTIMFLAGS="-O3 -DNDEBUG"'];
  mexcmd = [mexcmd ' LDOPTIMFLAGS="-O3"'];
else
  mexcmd = [mexcmd ' -g'];
end

% Turn all warnings on
mexcmd = [mexcmd ' CXXFLAGS="\$CXXFLAGS -Wall"'];
mexcmd = [mexcmd ' LDFLAGS="\$LDFLAGS -Wall"'];

if nargin < 3
  eval([mexcmd ' ubDetection/resize.cc']);
  eval([mexcmd ' ubDetection/features.cc']);
  eval([mexcmd ' ubDetection/dt.cc']);

  % Convolution routine
  %   Use one of the following depending on your setup
  %   (0) is fastest, (2) is slowest 

  % -1) multithreaded convolution using SSE
  eval([mexcmd ' ubDetection/fconvsse.cc -o fconv']);
  % 0) multithreaded convolution using blas
  %eval([mexcmd ' ubDetection/fconvblas.cc -lmwblas -o fconv']);
  % 1) multithreaded convolution
  %eval([mexcmd ' ubDetection/fconvMT.cc -o fconv']);
  % 2) basic convolution, very compatible
  %eval([mexcmd ' ubDetection/fconv.cc -o fconv']);
else
  eval([mexcmd ' ' mex_file]);
end
