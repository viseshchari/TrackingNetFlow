function edgeGroup = collectEdgesDepthSearch( detstruct, startDet, deplevels )
% function edgeGroup = collectEdgesDepthSearch( detstruct, startDet, deplevels ) 

detGroup = zeros(deplevels+1, length(startDet)) ;
edgeGroup = zeros(deplevels+1, length(startDet)) ;
detGroup(1, :) = startDet ;
edgeGroup(1, :) = 0 ; % root node.

tic ;
for i = 1 : deplevels
    slen = size(detGroup, 2) ;
    
    % First add all the next level children.
    for j  = 1 : slen
        if toc > 10
            fprintf( '     In detection number %d/%d in depth level %d/%d\n', j, slen, i, deplevels ) ;
            tic ;
        end
        sD = detGroup(i, j) ;
        nextdets = detstruct(sD).nextdets ;
        curredgs = detstruct(sD).edgenum ;
        dtAdd = repmat( detGroup(:, j), 1, length(nextdets) ) ;
        edAdd = repmat( edgeGroup(:, j), 1, length(curredgs) ) ;
        edAdd(i+1, :) = curredgs ;
        dtAdd(i+1, :) = nextdets ;
        detGroup = [detGroup dtAdd] ;
        edgeGroup = [edgeGroup edAdd] ;
    end
    
    % Finally remove the parents.
    detGroup = detGroup(:, slen+1:end) ;
    edgeGroup = edgeGroup(:, slen+1:end) ;
end

% cut off root
edgeGroup = edgeGroup(2:end, :) ;

% 
% for i = 1 : length(startDet)
%     sD = startDet(i) ;
%     nD = {} ;
%     for j = 1 : deplevels
%         for k = 1 : length(sD)
%         end
%     end
% end