function [xl, xu, Aeq, beq] = addFlowAndBoundaryConstraints( xs, frids, imsz, bdry, Aeq_data, cntr, nedgs, ndets, ntrcks )
% function [xl, xu, Aeq, beq] = addFlowAndBoundaryConstraints( xs, frids, imsz, bdry, Aeq_data, cntr, nedgs, ndets, ntrcks )

nvars = nedgs + 3 * ndets + 2 ;

xl = zeros( nvars, 1 ) ;
xu = ones( nvars, 1 ) ;

xc = (xs(:,1) + xs(:,3))/2; % center of x coordinates
yc = (xs(:,2) + xs(:,4))/2; % center of y coordinates

% use center of bounding box to determine boundary:


% Tracks cannot end or start anywhere except on the boundary.
idx = find( ( xc > bdry(1) ) & ( xc < (imsz(1)-bdry(1)) ) & ...
				( yc > bdry(2) ) & ( yc < (imsz(2)-bdry(2)) ) ) ;
xu( nedgs+2*ndets+(idx) ) = 0 ;
xu( nedgs+ndets+(idx) ) = 0 ;

% Detections in the last frame are exempt from the ending rule however.
idx = find( frids > (max(frids)-3) ) ;
xu( nedgs+2*ndets+idx ) = 1 ;

% Detections from the first frame are exempt from the starting rule.
idx = find( frids < (min(frids)+3) ) ;
xu( nedgs+ndets+idx ) = 1 ;

% Now set the capacities for the "dummy track" directly connecting source
% and sink
% Also called the shortcircuit constraint.
beq = zeros( 2*ndets+3, 1 ) ;

Aeq_data( (cntr+1):(cntr+ndets+1), 1 ) = 2*ndets+1 ;
Aeq_data( (cntr+1):(cntr+ndets+1), 2 ) = [nedgs+ndets+(1:ndets) nvars-1]';
cntr = cntr + ndets + 1 ;
Aeq_data( (cntr+1):(cntr+ndets+1), 1 ) = 2*ndets+2 ;
Aeq_data( (cntr+1):(cntr+ndets+1), 2 ) = [nedgs+2*ndets+(1:ndets) nvars]';
cntr = cntr + ndets + 1 ;

Aeq_data( cntr+1, 1 ) = 2*ndets+3 ;
Aeq_data( cntr+1, 2 ) = nvars-1 ;
Aeq_data( cntr+1, 3 ) = 1 ;
cntr = cntr + 1 ;
Aeq_data( cntr+1, 1 ) = 2*ndets+3 ;
Aeq_data( cntr+1, 2 ) = nvars ;
Aeq_data( cntr+1, 3 ) = -1 ;
cntr = cntr + 1 ;
beq((2*ndets+1):(2*ndets+2)) = ntrcks ; 

Aeq = sparse( Aeq_data(1:cntr, 1), Aeq_data(1:cntr, 2), Aeq_data(1:cntr, 3), 2*ndets+3, nvars ) ;
xu(end-1) = ntrcks ;
xu(end) = ntrcks ;
