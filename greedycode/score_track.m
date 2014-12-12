function [recval, precval, apval] = score_track(c, g, n, maxfr)
% function [missr, fppi, finevalpos, ovval] = score_track(c, g, n, maxfr)

if ~isfield(g, 'r')
	fprintf('Need ground truth with tracks!') ;
	recval = [] ;
	precval = [] ;
	apval = [] ;
end

recval = {} ;
precval = {} ;
apval = [] ; 

for i = 0 : maxfr
	[rec, prec, ap] = score_single_delta_ap( c, g, n, i ) ;
	recval{i+1} = rec ;
	precval{i+1} = prec ;
	apval = [apval ap] ;
end