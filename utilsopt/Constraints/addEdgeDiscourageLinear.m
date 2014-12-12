function [A, b, edge_velocity, Q_data, Q] = addEdgeDiscourageLinear( xs, frids, edge_xi, edge_xj, firstdets, firstedgs, nvars, nvarq )
% function [A, b, edge_velocity, Q_data, Q] = addEdgeDiscourageLinear( xs, frids, edge_xi, edge_xj, firstdets, firstedgs, nvars, nvarq )

maxdiff = max( frids( edge_xj ) - frids( edge_xi ) ) ;
maxfr = max( frids ) ;
minfr = min( frids ) ;
nedgs = length(edge_xi) ;

dx = (xs(:,1)+xs(:,3)) / 2 ;
dy = xs(:,2) ;
dy(1:firstdets) = ( dy(1:firstdets) + xs(1:firstdets, 4) ) / 2 ;

edge_pairs = [] ;

%% This code computes all the head detections that "thread through" edges connecting human detections.
midx = ( xs(1:firstdets, 1) + xs(1:firstdets, 3) ) / 2 ;
midy = ( xs(1:firstdets, 2) + xs(1:firstdets, 4) ) / 2 ;

gracethresh = 10 ; % This allows for some leway

ldx = xs((firstdets+1):end, 1) - gracethresh ;
rdx = xs((firstdets+1):end, 3) + gracethresh ;
ldy = xs((firstdets+1):end, 2) - gracethresh ;
rdy = (2*xs((firstdets+1):end, 2) + xs((firstdets+1):end, 4))/3 + gracethresh ;
ovdets = {} ;
xidets = {} ;
xjdets = {} ;
for i = 1 : firstdets
    xidets{i} = [] ; xjdets{i} = [] ;
    idx1 = find( frids( (firstdets+1):end ) == frids(i) ) ; % find all detections in the same frame.
    idxtmp = idx1( find( (midx(i) >= ldx(idx1)) & (midy(i) >= ldy(idx1)) & (midx(i) <= rdx(idx1)) & (midy(i) <= rdy(idx1)) ) ) ;
    ovdets{i} = idxtmp + firstdets ; % store absolute indices of all overlapping detections.
end

% Now pass through all the edges.
% And discourage those that don't have overlapping detections.
edge_pairs = [] ;
tic ;
for i = 1 : firstedgs  
    if toc > 10
        fprintf( 'In Edge number %d/%d\n', i, firstedgs ) ;
        tic ;
    end
    idx1 = ovdets{edge_xi(i)} ;
    idx2 = ovdets{edge_xj(i)} ;
    % If an edge has no overlapping detections on either of its end points.
    % add it to a list
    if isempty(idx1) & isempty(idx2)
        edge_pairs = [edge_pairs; i] ;
        xidets{edge_xi(i)} = [xidets{edge_xi(i)}; i] ;
        xjdets{edge_xj(i)} = [xjdets{edge_xj(i)}; i] ;
    end
end

%% Now collect all edge pairs that are not allowed.
% tic ;
% for i = 1 : firstdets
%     if isempty(xidets{i})
%         continue ;
%     else
%         idx1 = xidets{i} ;
%     end
%     if isempty(xjdets{i})
%         continue ;
%     else
%         idx2 = xjdets{i} ;
%     end
%     if toc > 10
%         fprintf( 'Detection number %d/%d\n', i, firstdets ) ;
%         tic ;
%     end
%     for j = 1:length(idx1)
%         edge_pairs = [edge_pairs; idx1(j)*ones(length(idx2),1) idx2] ;
%     end
% end

edge_pairs = unique([edge_pairs edge_pairs], 'rows') ;
edge_velocity = 10 * ones(size(edge_pairs, 1),1) ;

[A, b, edge_npairs,~] = composeRelaxationConstraints( edge_pairs, nvars ) ;

Q_data = zeros( edge_npairs, 3 ) ;
Q_data(:, 1) = edge_pairs(:,1) ;
Q_data(:, 2) = edge_pairs(:,2) ;
Q_data(:, 3) = edge_velocity ;

Q = sparse( Q_data(:, 1), Q_data(:, 2), Q_data(:, 3), nvarq, nvarq ) ;