function [A, b, edge_velocity, Q_data, Q] = addTemporalConstraintsMatlab( detstruct, edge_xi, edge_xj, xs, frids, tempthresh )
% function [edge_negpairs, edge_nnegpairs, edge_negcost] = addTemporalConstraintsMatlab( detstruct, edge_xi, edge_xj, xs, frids, tempthresh )
% Needs to be better commented




% % Get all the dimensions
% nedgs = length(edge_xi) ; % number of edges.
% ndets = size(xs, 1) ; % number of detections.
% 
% % First compute the centres of all the detections.
% % xscent = [xs(:, 1) + xs(:, 3) xs(:, 2) + xs(:, 4)] / 2 ;
% % Now take the to be the velocity of each detection
% % ofcent = xs(:, 6:7) ;
% xscent = [xs(:, 1)+xs(:,3) xs(:,2)+xs(:,4)]/2 ;
% frdiff = frids( edge_xj ) - frids( edge_xi ) ;
% w = xs(:,3)-xs(:,1) ;
% h = xs(:,4)-xs(:,2) ;
% 
% % Then compute the velocity vector corresponding to each edge.
% vecof = ofcent(edge_xj, :) + ofcent(edge_xi, :) ;
% vecds = xscent(edge_xj, :)./ repmat(frdiff,1,2) - xscent(edge_xi, :)./ repmat(frdiff,1,2) ;
% vecofnrm = sqrt( sum( vecof.^2, 2 ) ) ;
% vec = vecof ./ repmat( vecofnrm+eps, 1, 2 ) ; % if optical flow is 0, people have to be stationary for this ratio to be satisfied.
% % Now no need to nomalize by time since velocity cannot change much
% % vec = vec ./ repmat( frdiff, 1, 2 ) ; % Normalize by time 
% vecnrm = sqrt( sum( vecds.^2, 2 ) ) ;
% vecnz = double( vecnrm < eps ) ; % find all vectors that have 0 norm.
% vecdir = vec .* repmat(max( vecnrm./(vecofnrm+eps), vecofnrm./(vecnrm+eps)), 1, 2 ) ; % Normalize to produce unit vectors.
% % adding vecnz avoids 0 norm scaling, avoiding nan.
% 
% 
% % Now use the detstruct vector carefully.
% % The detstruct array has three elements.
% % detstruct
% %			- detno - the current detection number
% %			- nextdets - all the detections in the next frame(s) that are connected to it
% %			- edgenum - all edges where edge_xi == detno
% 
% edge_negpairs = (zeros(10000000, 2)) ;
% edge_negcost = (zeros(10000000, 4)) ;
% cntr = 1 ;
% 
% tic ;
% 
% % Now for all the edges.
% for i = 1 : nedgs
% 	if toc > 10
% 		fprintf( 'Processing edge number %d/%d\n', i, nedgs ) ;
% 		tic ;
% 	end
% 
% 	% collect all the next edges.
% 	nextid = detstruct( edge_xj(i) ).edgenum ;
% 
% 	% Now collect all the vectors, and compute the distance between them.
% 	try
% 		dist = sqrt( ( vecdir( nextid, 1 ) - vecdir( i, 1 ) ).^2 + ...
% 						( vecdir( nextid, 2 ) - vecdir( i, 2 ) ).^2 ) ;
% 	catch
% 		keyboard ;
%     end
% 
%     % ===========================
% 	idx = find( dist < tempthresh ) ; % SELECTION OF PAIRS
%     % ==========================
% 	edge_negpairs( cntr : (cntr + length(idx) - 1 ), 1 ) = i ;
% 	edge_negpairs( cntr : (cntr + length(idx) - 1 ), 2 ) = nextid(idx) ;
% 	edge_negcost( cntr : (cntr + length(idx) - 1), : ) = [repmat(vec(i, :), length(idx), 1) vec(nextid(idx), :)] ;
% 	cntr = cntr + length(idx) ;
% end
% 
% edge_nnegpairs = cntr - 1 ;
% edge_negpairs = edge_negpairs(1:edge_nnegpairs, :) ;
% edge_negcost = edge_negcost(1:edge_nnegpairs, :) ;
% maxvel = max([sum(edge_negcost(:, 1:2).^2, 2); sum(edge_negcost(:, 3:4).^2, 2)]) ;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Normalization of Velocity Vectors %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % edge_vecnm = [sum(edge_negcost(:,1:2).^2, 2) sum(edge_negcost(:, 3:4).^2, 2)] ;
% % edge_veczero = double( edge_vecnm < 1 ) ; % if norm is 0, then make it 1
% % edge_vecnm = edge_vecnm + edge_veczero ;
% % edge_negcost = [edge_negcost(:, 1)./edge_vecnm(:, 1) edge_negcost(:, 2)./edge_vecnm(:, 1) ...
% % 				   edge_negcost(:, 3)./edge_vecnm(:, 2) edge_negcost(:, 4)./edge_vecnm(:, 2)] ;
% % maxvel = 1 ;
