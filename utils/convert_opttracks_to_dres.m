function dres = convert_opttracks_to_dres( opttracks, detections )
% function dres = convert_opttracks_to_dres( opttracks, detections )
% Modified on 28th February 2014 to return hgconf as well as relationship
% to opttracks. (backward mapping from dres to opttracks)

% optfrms = [opttracks.frame] ;
% optrcs = [opttracks.track] ;
% optcnfs = detections(:, 5) ;
% opttrcnfs = [opttracks.trackconf] ;
% optrclen = [opttracks.tracklength] ;


% idx = find( optrcs > -1 ) ;
% maxt = max( optrcs(idx) ) ;

% tcs = [] ;
% for i = 1 : maxt
% 	idx2 = find( optrcs == i ) ;
% 	tcs = [tcs sum(abs(optcnfs(idx2)))+sum(abs(opttrcnfs(idx2)))] ;
% end
% [srtval, srtidx] = sort( tcs, 'descend' ) ;

% newcnfs = zeros(length(idx), 1) ;
% for i = 1 : maxt
% 	newcnfs( find( optrcs(idx) == srtidx(i) ) ) = -i ;
% end

% optrcts = cat(1, opttracks(idx).rect ) ;
% dres.x = optrcts(:, 1) ;
% dres.y = optrcts(:, 2) ;
% dres.w = optrcts(:, 3) - optrcts(:, 1) ;
% dres.h = optrcts(:, 4) - optrcts(:, 2) ;
% dres.fr = optfrms( idx )' ;
% trlen( optrcs(idx) ) = optrclen(idx) ; % every track has a length.
% dres.r = newcnfs ;
% dres.id = optrcs(idx)' ;

% return ;

optrcts = cat(1, opttracks.rect ) ;
optfrms = [opttracks.frame] ;
optrcs = [opttracks.track] ;
optcnfs = [opttracks.hogconf] ;
opttrcnfs = [opttracks.trackconf] ;
optedcnf = [opttracks.edgeconf] ;
optednum = [opttracks.ednum] ;

optrclen = [opttracks.tracklength] ;

dres.x = optrcts(:, 1) ;
dres.y = optrcts(:, 2) ;
dres.w = optrcts(:, 3) - optrcts(:, 1) ;
dres.h = optrcts(:, 4) - optrcts(:, 2) ;
dres.fr = optfrms' ;
dres.xi = [opttracks.xi]' ;
dres.xj = [opttracks.xj]' ;
dres.ednum = [opttracks.ednum]' ;
dres.edgeconf = [opttracks.edgeconf]' ;
dres.hogconf = [opttracks.hogconf]' ;
dres.id = [opttracks.track]' ;
dres.r = -dres.id ;

% dres.x = opttrcks