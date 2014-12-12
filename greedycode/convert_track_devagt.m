function gt = convert_track_devagt( trackfilename )
% function gt = convert_track_devagt( trackfilename )

gt.x = [] ;
gt.y = [] ;
gt.h = [] ;
gt.w = [] ;
gt.fr = [] ;
gt.vid = [] ;
gt.r = [] ;

load( trackfilename ) ; % contains only the variable 'tracks'

for i = 1 : length(tracks)
	nstops = size( tracks{i}, 1 ) ;
	% [i, nstops]
	for j = 2 : nstops
		b1 = tracks{i}(j-1, :) ;
		b2 = tracks{i}(j, :) ;
		gt.fr = [gt.fr; [b1(5):(b2(5)-1)]'] ;
		alphas = [1 : -1/(b2(5)-b1(5)) : 1/(b2(5)-b1(5))]' ; % linear division
		[length(alphas) length(b1(5):(b2(5)-1))]
		gt.x = [gt.x; b1(1) * alphas + b2(1) * (1-alphas)] ;
		gt.y = [gt.y; b1(2) * alphas + b2(2) * (1-alphas)] ;
		gt.w = [gt.w; b1(3) * alphas + b2(3) * (1-alphas)] ;
		gt.h = [gt.h; b1(4) * alphas + b2(4) * (1-alphas)] ;
		gt.r = [gt.r; i * ones(length(alphas), 1)] ;
	end
end

gt.vid = 3 * ones(length(gt.x), 1) ;
