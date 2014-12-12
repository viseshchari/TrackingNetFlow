function [A, b, edge_velocity, Q_data, Q] = addTemporalQuadRelaxedConstraints( detstruct, edge_xi, edge_xj, xs, frids, velthresh, nvars, nvarq, negvar, firstedgs )
% [A, b, edge_velocity] = addTemporalRelaxedConstraints( detstruct, edge_xi, edge_xj, xs, velthresh, nvars ) ;

if nargin < 10
    firstedgs = 0 ;
end

if nargin < 9
    negvar = 0 ;
end

if nargin < 8
	nvarq = nvars ;
end

ndets = length(detstruct) ;

% if  exist( 'tmpdata7.mat', 'file' )    
%     load( 'tmpdata7.mat' ) ;
% else
    % first collect all the possible edges.
    allEdges = collectEdgesDepthSearch( detstruct, 1:ndets, 2 ) ;
    allEdges = allEdges' ;

    % Then compute the centres of the detections.
    xscent = [xs(:,1)+xs(:,3) xs(:,2)+xs(:,4)]/2.0 ;
    
    fr = frids(edge_xj) - frids(edge_xi) ;

    % Then compute velocity of each edge.
    xvel = ( xscent(edge_xj, 1) - xscent(edge_xi, 1) ) ./ ( frids(edge_xj) - frids(edge_xi) ) ;
    yvel = ( xscent(edge_xj, 2) - xscent(edge_xi, 2) ) ./ ( frids(edge_xj) - frids(edge_xi) ) ;

    xnrm = sqrt( xvel.^2 + yvel.^2 + eps ) ;
    
    idxzero = find( xnrm < 1e-5 ) ;
    
    % Unit normalizing
     xvelnm = xvel ./ xnrm ;
     yvelnm = yvel ./ xnrm ;
     
%% These are necessary for trilinear constraints which has now been made
%%% a separate function
% 	 xav1 = xvelnm( allEdges(:, 1) ) ;
% 	 xav2 = xvelnm( allEdges(:, 2) ) ;
% 	 xav3 = xvelnm( allEdges(:, 3) ) ;
% 	 yav1 = yvelnm( allEdges(:, 1) ) ;
% 	 yav2 = yvelnm( allEdges(:, 2) ) ;
% 	 yav3 = yvelnm( allEdges(:, 3) ) ;
% 
% 	 idxtmp1 = find( ( xav1 == 0 ) & ( yav1 == 0 ) ) ;
% 	 idxtmp2 = find( ( xav2 == 0 ) & ( yav2 == 0 ) ) ;
% 
% 	 xavg2 = ( xvel( allEdges(:, 1) ) + xvel( allEdges(:, 2) ) ) ./ ( fr(allEdges(:,1)) + fr(allEdges(:,2)) ) ;
% 	 yavg2 = ( yvel( allEdges(:, 1) ) + yvel( allEdges(:, 2) ) ) ./ ( fr(allEdges(:,1)) + fr(allEdges(:,2)) ) ;
% 	 nm2 = sqrt( xavg2.^2 + yavg2.^2 ) + eps ; xavg2 = xavg2 ./ nm2 ; yavg2 = yavg2 ./ nm2 ;
% 	 xavg3 = ( xvel( allEdges(:, 2) ) + xvel( allEdges(:, 3) ) ) ./ ( fr(allEdges(:,2)) + fr(allEdges(:,3)) ) ;
% 	 yavg3 = ( yvel( allEdges(:, 2) ) + yvel( allEdges(:, 3) ) ) ./ ( fr(allEdges(:,2)) + fr(allEdges(:,3)) ) ;
% 	 nm3 = sqrt( xavg3.^2 + yavg3.^2 ) + eps ; xavg3 = xavg3 ./ nm3 ; yavg3 = yavg3 ./ nm3 ;
% 	 
% 	 veldiff = abs( ( real( asin( xav2 .* yav1 - yav2 .* xav1 ) ) + real( asin( xav2 .* yav3 - yav2 .* xav3 ) ) ) / 2 ) ; %+ ...
%     xavg1 = ( xvel( allEdges(:, 1) ) + xvel( allEdges(:, 2) ) + xvel( allEdges(:, 3) ) ) ./ ( fr(allEdges(:,1))+fr(allEdges(:,2))+fr(allEdges(:,3)) ) ;
%     yavg1 = ( yvel( allEdges(:, 1) ) + yvel( allEdges(:, 2) ) + yvel( allEdges(:, 3) ) ) ./ ( fr(allEdges(:,1))+fr(allEdges(:,2))+fr(allEdges(:,3)) ) ;
% %     nm1 = sqrt( xavg1.^2 + yavg1.^2 ) + eps ; xavg1 = xavg1 ./ nm1 ; yavg1 = yavg1 ./ nm1 ;
%     xavg2 = ( xvel( allEdges(:, 1) ) + xvel( allEdges(:, 2) ) ) ./ ( fr(allEdges(:,1)) + fr(allEdges(:,2)) ) ;
%     yavg2 = ( yvel( allEdges(:, 1) ) + yvel( allEdges(:, 2) ) ) ./ ( fr(allEdges(:,1)) + fr(allEdges(:,2)) ) ;
% %     nm2 = sqrt( xavg2.^2 + yavg2.^2 ) + eps ; xavg2 = xavg2 ./ nm2 ; yavg2 = yavg2 ./ nm2 ;
%     xavg3 = ( xvel( allEdges(:, 2) ) + xvel( allEdges(:, 3) ) ) ./ ( fr(allEdges(:,2)) + fr(allEdges(:,3)) ) ;
%     yavg3 = ( yvel( allEdges(:, 2) ) + yvel( allEdges(:, 3) ) ) ./ ( fr(allEdges(:,2)) + fr(allEdges(:,3)) ) ;
%     nm3 = sqrt( xavg3.^2 + yavg3.^2 ) + eps ; xavg3 = xavg3 ./ nm3 ; yavg3 = yavg3 ./ nm3 ;
    % Then compute velocity average over two frames.
%     xavg1 = ( xvel( allEdges(:, 1) ) + xvel( allEdges(:, 2) ) ) / 2 ;
%     xavg2 = ( xvel( allEdges(:, 3) ) + xvel( allEdges(:, 4) ) ) / 2 ;
%     yavg1 = ( yvel( allEdges(:, 1) ) + yvel( allEdges(:, 2) ) ) / 2 ;
%     yavg2 = ( yvel( allEdges(:, 3) ) + yvel( allEdges(:, 4) ) ) / 2 ;

%% These represent bilinear constraints that are the simplest form of constraints.
%%% They can be encouraging as well as discouraging.
%     veldiff = sqrt( (xvel(allEdges(:,1))-xvel(allEdges(:,2))).^2. + (yvel(allEdges(:,1))-yvel(allEdges(:,2))).^2 ) ./ min(xnrm(allEdges(:,1)), xnrm(allEdges(:,2))) ;

    % Finally get all the pairs who are close together.
%     veldiff = sqrt( (xavg2-xavg3).^2 + (yavg2-yavg3).^2 ) ;
      veldiff = real(acos( xvelnm(allEdges(:,1)).*xvelnm(allEdges(:,2)) + yvelnm(allEdges(:,1)).*yvelnm(allEdges(:,2)) ));
      veldiff = min( veldiff, 2*pi - veldiff ) ;
%     veldiff = acos( xavg2.*xavg3 + yavg2.*yavg3 ) ;
%     veldiff = sqrt( (xavg2-xavg3).^2 + (yavg2-yavg3).^2 ) ;
%     veldiff = ( sqrt( (xavg1-xavg2).^2 + (yavg1-yavg2).^2 ) + sqrt( (xavg1-xavg3).^2 + (yavg1-yavg3).^2 ) ) / 2 ;
    if negvar
        idx = find( veldiff > velthresh ) ;
    else
        idx = find( veldiff < velthresh ) ;
    end

    idx = setdiff( idx, find( (ismember(allEdges(:,1),idxzero)+ismember(allEdges(:,2),idxzero)) > 0 ) ) ;
    % compose relaxation constraints for them.
%     [A, b, edge_npairs] = composeRelaxationTriConstraints( allEdges(idx, :), nvars ) ;
    [A, b, edge_npairs] = composeRelaxationConstraints( allEdges(idx, :), nvars ) ;
    if ~negvar
        edge_velocity = 10*exp( -veldiff(idx)/pi ) ;
    else
        edge_velocity = 10 * exp( -5./veldiff(idx) ) ;
    end

%     save('tmpdata7.mat', 'A', 'b', 'edge_velocity', 'allEdges', 'idx', 'nvarq', 'veldiff','-v7.3' ) ;
% end
% [edge_negpairs, edge_nnegpairs, edge_velocity, maxvel] = addTemporalConstraintsMatlab( detstruct, edge_xi, edge_xj, xs, frids, velthresh ) ;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Normalization of Velocity Vectors %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% edge_vecnm = [sqrt(sum(edge_velocity(:,1:2).^2, 2)) sqrt(sum(edge_velocity(:, 3:4).^2, 2))] ;
% edge_veczero = double( edge_vecnm < eps ) ; % if norm is 0, then make it 1
% edge_vecnm = edge_vecnm + edge_veczero ;
% edge_velocity = [edge_velocity(:, 1)./edge_vecnm(:, 1) edge_velocity(:, 2)./edge_vecnm(:, 1) ...
% 				   edge_velocity(:, 3)./edge_vecnm(:, 2) edge_velocity(:, 4)./edge_vecnm(:, 2)] ;
% maxvel = 1 ;
% 
% [A, b, edge_npairs] = composeQuadRelaxationConstraints( edge_negpairs, nvars ) ;
% edge_velocity = -exp(-2*( ( edge_velocity(:,1)-edge_velocity(:,3) ).^2+( edge_velocity(:,2)-edge_velocity(:,4) ).^2 ) )  ;

fprintf( 'Length of vectors chosen turns out to be %d/%d\n', length(idx), length(veldiff) ) ;

% Very simple matrix, but created for debugging purposes. And also used to augment ytilde.
Q_data = zeros( length(idx), 3 ) ;
% assert(size(edge_negpairs, 1) == edge_nnegpairs)
Q_data(:, 1) = allEdges(idx, 1) ;
Q_data(:, 2) = allEdges(idx, 2) ;
% Q_data(:, 3) = allEdges(idx, 3) ;
% Q_data(:, 4) = allEdges(idx, 4) ;
Q_data(:, 3) = edge_velocity ;

% Q = sptensor( Q_data(:, 1:4), Q_data(:, 5), [nvarq nvarq nvarq nvarq] ) ;
% Q = sptensor( Q_data(:, 1:3), Q_data(:, 4), [nvarq nvarq nvarq] ) ;
Q = sparse( Q_data(:,1), Q_data(:,2), Q_data(:,3), nvarq, nvarq ) ;

