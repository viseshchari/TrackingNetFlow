function [A, b, edge_velocity, Q_data, Q] = addCooccurrenceConstraints( xs, frids, edge_xi, edge_xj, distthresh, firstdets, firstedgs, nvars, nvarq )
% function [A, b, edge_velocity, Q_data, Q] = addCooccurrenceConstraints( xs, frids, edge_xi, edge_xj, distthresh, firstdets, firstedgs, nvars, nvarq )

maxdiff = max( frids( edge_xj ) - frids( edge_xi ) ) ;
maxfr = max( frids ) ;
minfr = min( frids ) ;
nedgs = length(edge_xi) ;

dx = (xs(:,1)+xs(:,3)) / 2 ;
dy = xs(:,2) ;
dy(1:firstdets) = ( dy(1:firstdets) + xs(1:firstdets, 4) ) / 2 ;

edge_pairs = [] ;

% % headBox = {} ;
% % edstart = {} ;
% % edge_pairs = [] ;
% % for i = (firstdets+1):length(dx)
% %     headBox{i-firstdets} = [] ;
% % end
% % for i = 1:firstdets
% %     edstart{i} = [] ;
% % end
% % 
% % for i = 1:firstedgs
% %     edstart{edge_xi(i)} = [edstart{edge_xi(i)} i] ;
% %     edstart{edge_xj(i)} = [edstart{edge_xj(i)} i] ;
% % end
% % 
% % tic ;
% % for i = minfr : maxfr
% %     if toc > 1
% %         fprintf( 'Frame %d/%d in building datastruct\n', i, maxfr ) ;
% %         tic ;
% %     end
% %     idx1 = find( frids(1:firstdets) == i ) ;
% %     idx2 = find( frids((firstdets+1):end) == i ) + firstdets ;
% %     
% %     l1 = length(idx1) ;
% %     l2 = length(idx2) ;
% %     
% %     dist = sqrt( (repmat( dx(idx1), 1, l2 ) - repmat( dx(idx2)', l1, 1 )).^2 + ( repmat( dy(idx1), 1, l2 ) - repmat( dy(idx2)', l1, 1 ) ).^2 ) ;
% %     dist = dist' ;
% %     for j = 1 : length(idx2)
% %         idx3 = find( dist(j, :) < distthresh ) ;
% %         headBox{idx2(j)-firstdets} = [headBox{idx2(j)-firstdets} cat(1,cell2mat(edstart(idx1(idx3))))] ;
% %     end
% % end
% % 
% % tic ;
% % for i = (firstedgs+1):length(edge_xi)
% %     if toc > 10
% %         fprintf( 'Adding edges %d/%d\n', i, length(edge_xi) ) ;
% %         tic ;
% %     end
% %     idx1 = headBox{edge_xi(i)-firstdets} ;
% %     idx2 = headBox{edge_xj(i)-firstdets} ;
% %     idx12 = intersect( idx1, idx2 ) ;
% %     if ~isempty(idx12)
% %         edge_pairs = [edge_pairs; [i*ones(length(idx12),1) idx12']] ;
% %     end
% % end

%% This code just computes the quadratic function for forcing two detections to be selected together.

for i = minfr : maxfr
   idx1 = find( frids(1:firstdets) == i ) ;
   idx2 = find( frids((firstdets+1):end) == i ) + firstdets ;
   
   mx1 = ( xs( idx1, 1 ) + xs( idx1, 3 ) ) / 2 ;
   my1 = ( xs( idx1, 2 ) + xs( idx1, 4 ) ) / 2 ;
   
   mx2 = ( xs( idx2, 1 ) + xs( idx2, 3 ) ) / 2 ;
   my2 = xs( idx2, 2 ) ;
   
   l1 = length(idx1) ;
   l2 = length(idx2) ;
   
   dist = sqrt( ( repmat( mx2', l1, 1 ) - repmat( mx1, 1, l2 ) ).^2 + ( repmat( my2', l1, 1 ) - repmat( my1, 1, l2 ) ).^2 ) ;
   [idx1sel, idx2sel] = ind2sub( size(dist), find( dist(:) < distthresh ) ) ;
   edge_pairs = [edge_pairs; nedgs+[idx1(idx1sel) idx2(idx2sel)]] ;
end
% edge_pairs = [] ;
 
% tic ;
% %% This code computes the quadratic function for selecting two edges together.
% for i = minfr : maxfr
%     for j = 1 : maxdiff
%         if toc > 10
%             fprintf( 'In Frame %d/%d\n', i, i+j ) ;
%             tic ;
%         end
%             
%         idx1 = find( ( frids(edge_xi(1:firstedgs)) == i ) & ( frids(edge_xj(1:firstedgs)) == (i+j) ) ) ;
%         idx2 = find( ( frids(edge_xi((firstedgs+1):end)) == i ) & ( frids(edge_xj((firstedgs+1):end)) == (i+j) ) ) + firstedgs ;
%         
%         l1 = length(idx1) ;
%         l2 = length(idx2) ;
%         
%         dist1 = ( ( repmat( dx(edge_xi(idx1)), 1, l2 ) - repmat( dx(edge_xi(idx2))', l1, 1 ) ).^2 + ...
%                    ( repmat( dy(edge_xi(idx1)), 1, l2 ) - repmat( dy(edge_xi(idx2))', l1, 1 ) ).^2 ) ;
%         dist2 = ( ( repmat( dx(edge_xj(idx1)), 1, l2 ) - repmat( dx(edge_xj(idx2))', l1, 1 ) ).^2 + ...
%                    ( repmat( dy(edge_xj(idx1)), 1, l2 ) - repmat( dy(edge_xj(idx2))', l1, 1 ) ).^2 ) ;
%                
%         distedge = ( sqrt(dist1) < distthresh ) & ( sqrt(dist2) < distthresh ) ;
%         [idx1sel, idx2sel] = ind2sub( size(distedge), find( distedge(:) ) ) ;
%         
%         edge_pairs = [edge_pairs; idx1(idx1sel) idx2(idx2sel)] ;
%     end
% end
% 
% edge_pairs = unique( edge_pairs, 'rows' ) ;

[A, b, edge_npairs,~] = composeRelaxationConstraints( edge_pairs, nvars ) ;

Q_data = zeros( edge_npairs, 3 ) ;
Q_data(:, 1) = edge_pairs(:,1) ;
Q_data(:, 2) = edge_pairs(:,2) ;
Q_data(:, 3) = -1 ;

Q = sparse( Q_data(:, 1), Q_data(:, 2), Q_data(:, 3), nvarq, nvarq ) ;

edge_velocity = -1 * ones(edge_npairs, 1) ;