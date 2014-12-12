function [dres bboxes] = detect_objects_weighted(xs, frids, weights)
% vid_path = 'data/seq03-img-left/';

if nargin < 3
	weights = [1;0] ;
end

dres.x = xs(:,1) ;
dres.y = xs(:,2) ;
dres.w = xs(:,3)-xs(:,1) ;
dres.h = xs(:,4)-xs(:,2) ;
dres.r = weights(1) * xs(:,5) + weights(2) ;
dres.fr = frids ;

bboxes = [] ;
