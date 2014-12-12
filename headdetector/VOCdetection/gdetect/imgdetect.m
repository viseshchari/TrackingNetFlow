function [ds, bs, trees, score_export] = imgdetect(im, model, thresh, justscore)
% Wrapper around gdetect.m that computes detections in an image.
%   [ds, bs, trees] = imgdetect(im, model, thresh)
%
% Return values (see gdetect.m)
%
% Arguments
%   im        Input image
%   model     Model to use for detection
%   thresh    Detection threshold (scores must be > thresh)

if nargin < 4
	justscore = 0 ;
end

im = color(im);
pyra = featpyramid(im, model);
disp('Now gdetect') ; 
[ds, bs, trees, score_export] = gdetect(pyra, model, thresh, justscore);
