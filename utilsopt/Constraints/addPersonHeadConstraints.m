function [A, b, edge_secvelocity, Q_data, Q] = addPersonHeadConstraints( xs, frids, ndets, nedgs, nvars, nvarq, firstdets ) 
% function [A, b, edge_secvelocity, Q_data, Q] = addPersonHeadConstraints( xs, frids, ndets, nedgs, nvars, nvarq, firstdets ) 


%% Check the fact that every person detection has only 1 (mostly) head detection
bbx1 = xs(1:firstdets, 1:4) ;
bbx2 = xs((firstdets+1):ndets, 1:4) ;
ovlapidxs = [] ;
for i = min( frids) : max( frids )
    idx1 = find( frids(1:firstdets) == i ) ;
    idx2 = find( frids((firstdets+1):ndets) == i ) ;
    ov = bboxoverlapval( bbx1(idx1, 1:4), bbx2(idx2, 1:4), 3 ) ;
    ov = ov > 0.5 ;
    [ei, ej] = ind2sub( size(ov), find(ov(:)) ) ;
    ovlapidxs = [ovlapidxs; [firstdets+idx2(ej) idx1(ei)]] ;
end

tic ;
edge_pairs = [] ;
for i = (firstdets+1):ndets
    if toc > 10
        fprintf( 'In detection %d/%d\n', i, ndets ) ;
        tic ;
    end
    
    idx = ovlapidxs(find( ovlapidxs(:,1) == i ), 2) ;
    for j = 1 : length(idx)
        for k = j+1 : length(idx)
            edge_pairs = [edge_pairs; [idx(j) idx(k)]] ;
        end
    end
end

edge_pairs = unique( edge_pairs, 'rows' ) ;
[A, b, edge_nvelocity] = composeRelaxationConstraints( edge_pairs, nvars ) ;
Q_data(:, 1:2) = edge_pairs+nedgs ;
Q_data(:, 3) = 10 ;
edge_secvelocity = Q_data(:, 3) ;

Q = sparse( Q_data(:, 1), Q_data(:, 2), Q_data(:, 3), nvarq, nvarq ) ;

