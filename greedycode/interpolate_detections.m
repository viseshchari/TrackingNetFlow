function dresnew = interpolate_detections( dres )
% function dresnew = interpolate_detections( dres )

dresnew = dres ;
maxfr = length(dres.r) ;
fprintf('New modified\n') ;

for i = 1 : -min(dres.r)
	idx = find( dres.r == -i ) ;
	frs = dres.fr(idx) ;
	emptframes = setdiff( min(frs):max(frs), frs ) ;

	if isempty(emptframes)
		continue ;
	end

	if ~isempty(emptframes)
		fprintf('There is a difference here!\n') ;
	end

	xnew = interp1( frs, dres.x(idx), emptframes', 'linear' ) ;
	ynew = interp1( frs, dres.y(idx), emptframes', 'linear' ) ;
	wnew = interp1( frs, dres.w(idx), emptframes', 'linear' ) ;
	hnew = interp1( frs, dres.h(idx), emptframes', 'linear' ) ;

	dresnew.fr = [dresnew.fr; emptframes'] ;
	dresnew.x = [dresnew.x; xnew] ;
	dresnew.y = [dresnew.y; ynew] ;
	dresnew.w = [dresnew.w; wnew] ;
	dresnew.h = [dresnew.h; hnew] ;
	dresnew.r = [dresnew.r; -i*ones(length(xnew), 1)] ;
	dresnew.id = [dresnew.id; dresnew.id(idx(1))*ones(length(xnew), 1)] ;

	% for j = 1 : length(emptframes)
	% 	idx1 = find( dres.fr(idx) == (emptframes(j)-1) ) ;
	% 	idx2 = find( dres.fr(idx) == (emptframes(j)+1) ) ;
	% 	if isempty(idx1)
	% 		keyboard ;
	% 	end
	% 	if isempty(idx2)
	% 		keyboard ;
	% 	end
	% 	[idx1 idx2]

	% 	dresnew.fr = [dresnew.fr; emptframes(j)] ;
	% 	dresnew.x = [dresnew.x; (dresnew.x(idx(idx1))+dresnew.x(idx(idx2))) / 2] ;
	% 	dresnew.y = [dresnew.y; (dresnew.y(idx(idx1))+dresnew.y(idx(idx2))) / 2] ;
	% 	dresnew.w = [dresnew.w; (dresnew.w(idx(idx1))+dresnew.w(idx(idx2))) / 2] ;
	% 	dresnew.h = [dresnew.h; (dresnew.h(idx(idx1))+dresnew.h(idx(idx2))) / 2] ;
	% 	dresnew.r = [dresnew.r; -i] ;
	% 	dresnew.id = [dresnew.id; dresnew.id(idx(idx1))] ;
	% end
end

% Now for all the indexes, sort by the frame number and then put it into the data.
dresnew2.x = [] ;
dresnew2.y = [] ;
dresnew2.w = [] ;
dresnew2.h = [] ;
dresnew2.r = [] ;
dresnew2.fr = [] ;
dresnew2.id = [] ;

for i = 1 : -min(dres.r)
	idx = find( dresnew.r == -i ) ;
	[~,idxval] = sort( dresnew.fr(idx) ) ;
	dresnew2.x = [dresnew2.x; dresnew.x(idx(idxval))] ;
	dresnew2.y = [dresnew2.y; dresnew.y(idx(idxval))] ;
	dresnew2.w = [dresnew2.w; dresnew.w(idx(idxval))] ;
	dresnew2.h = [dresnew2.h; dresnew.h(idx(idxval))] ;
	dresnew2.r = [dresnew2.r; dresnew.r(idx(idxval))] ;
	dresnew2.fr = [dresnew2.fr; dresnew.fr(idx(idxval))] ;
	dresnew2.id = [dresnew2.id; dresnew.id(idx(idxval))] ;
end

dresnew = dresnew2 ;