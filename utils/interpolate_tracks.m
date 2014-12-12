function dresdp = interpolate_tracks( dresdp )
% function dresdp = interpolate_tracks( dresdp )

maxfr = max( dresdp.id ) ;

for i = 1 : maxfr
   idx = find( dresdp.id == i ) ;
   for j = 2 : length(idx)
       if (dresdp.fr(idx(j)) - dresdp.fr(idx(j-1))) > 1
           alpha = dresdp.fr(idx(j)) - dresdp.fr(idx(j-1)) ;
           ratios = [0:1/alpha:1] ;
           ratios = ratios(2:end-1)' ;
           dresdp.x = [dresdp.x; dresdp.x(idx(j-1)) * ratios + dresdp.x(idx(j)) * (1-ratios)] ;
           dresdp.y = [dresdp.y; dresdp.y(idx(j-1)) * ratios + dresdp.y(idx(j)) * (1-ratios)] ;
           dresdp.w = [dresdp.w; dresdp.w(idx(j-1)) * ratios + dresdp.w(idx(j)) * (1-ratios)] ;
           dresdp.h = [dresdp.h; dresdp.h(idx(j-1)) * ratios + dresdp.h(idx(j)) * (1-ratios)] ;
           dresdp.fr = [dresdp.fr; [(dresdp.fr(idx(j-1))+1):(dresdp.fr(idx(j))-1)]'] ;  
           dresdp.id = [dresdp.id; i*ones(length(ratios),1)] ;
           dresdp.r = [dresdp.r; -i*ones(length(ratios),1)] ;
           dresdp.hogconf = [dresdp.hogconf; -1*ones(length(ratios),1)] ;
           if isfield( dresdp, 'ednum' ) 
            dresdp.ednum = [dresdp.ednum; -1*ones(length(ratios),1)] ;
            dresdp.edgeconf = [dresdp.edgeconf; 0*ones(length(ratios),1)] ;
            dresdp.xi = [dresdp.xi; -1*ones(length(ratios),1)] ;
            dresdp.xj = [dresdp.xj; -1*ones(length(ratios),1)] ;
           end
       end
   end
end

[~,srtidx] = sort( dresdp.fr ) ;
dresdp.x = dresdp.x(srtidx) ;
dresdp.y = dresdp.y(srtidx) ;
dresdp.h = dresdp.h(srtidx) ;
dresdp.w = dresdp.w(srtidx) ;
dresdp.fr = dresdp.fr(srtidx) ;
dresdp.id = dresdp.id(srtidx) ;
dresdp.r = dresdp.r(srtidx) ;
if isfield( dresdp, 'ednum' )
    dresdp.ednum = dresdp.ednum(srtidx) ;
end
if isfield( dresdp, 'edgeconf' )
    dresdp.edgeconf = dresdp.edgeconf(srtidx) ;
end
if isfield( dresdp, 'hogconf' )
    dresdp.hogconf = dresdp.hogconf(srtidx) ;
end

% for i = 1 : maxfr
%     idx = find( dresdp.id == i ) ;
%     allfrs = dresdp.fr(idx)' ;
%     x = interp1( dresdp.x(idx)', allfrs, setdiff( min(dresdp.fr(idx)):max(dresdp.fr(idx)), allfrs ) ) ;
%     y = interp1( dresdp.y(idx)', allfrs, setdiff( min(dresdp.fr(idx)):max(dresdp.fr(idx)), allfrs ) ) ;
%     id = i * ones(length(x),1) ;
%     w = mean(dresdp.w(idx)) * ones(length(x), 1) ;
%     h = mean(dresdp.h(idx)) * ones(length(x), 1) ;
%     fr = setdiff( min(dresdp.fr(idx)):max(dresdp.fr(idx)), allfrs )' ;
%     dresdp.x = [dresdp.x; x] ;
%     dresdp.y = [dresdp.y; y] ;
%     dresdp.w = [dresdp.w; w] ;
%     dresdp.h = [dresdp.h; h] ;
%     dresdp.id = [dresdp.id; id] ;
%     dresdp.fr = [dresdp.fr; fr] ;
%     dresdp.r = [dresdp.r; -id] ;
%     dresdp.ednum = [dresdp.ednum; -1 * ones(length(x),1)] ;
%     dresdp.edgeconf = [dresdp.edgeconf; 0 * ones(length(x),1)] ;
%     dresdp.hogconf = [dresdp.hogconf; -1 * ones(length(x),1)] ;
% end
