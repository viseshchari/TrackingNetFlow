function[box, pose] =  detectFaces(im, thres)
% compile.m should work for Linux and Mac.
% To Windows users:
% If you are using a Windows machine, please use the basic convolution (fconv.cc).
% This can be done by commenting out line 13 and uncommenting line 15 in
% compile.m
%compile;

% load and visualize model
% Pre-trained model with 146 parts. Works best for faces larger than 80*80
face = load('/meleze/data0/tracking/data/face_p146_small.mat');

% % Pre-trained model with 99 parts. Works best for faces larger than 150*150
% load face_p99.mat

% % Pre-trained model with 1050 parts. Give best performance on localization, but very slow
% load multipie_independent.mat

% 5 levels for each octave
face.model.interval = 5;
% set up the threshold

%you could try tuning the threshold saved in model.thresh. You may want to use a higher threshold if 
%you see too many false detections, and a lower threshold ifyou miss a lot of faces. 

face.model.thresh = min(thres, face.model.thresh);

% define the mapping from view-specific mixture id to viewpoint
if length(face.model.components)==13 
    posemap = 90:-15:-90;
elseif length(face.model.components)==18
    posemap = [90:-15:15 0 0 0 0 0 0 -15:-15:-90];
else
    error('Can not recognize this model');
end

bs = detect_f(im, face.model, face.model.thresh);
bs = clipboxes(im, bs);
bs = nms_face(bs, 0.3);
[box, pose] = getBoundingRectangle(bs, posemap);
