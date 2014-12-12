function [A, b, edge_velocity, Q_data, Q] = addTemporalRelaxedConstraints( detstruct, edge_xi, edge_xj, xs, frids, velthresh, nvars, nvarq )
% [A, b, edge_velocity] = addTemporalRelaxedConstraints( detstruct, edge_xi, edge_xj, xs, velthresh, nvars ) ;

if nargin < 8
	nvarq = nvars ;
end

[edge_negpairs, edge_nnegpairs, edge_velocity, maxvel] = addTemporalConstraintsMatlab( detstruct, edge_xi, edge_xj, xs, frids, velthresh ) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Normalization of Velocity Vectors %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
edge_vecnm = [sqrt(sum(edge_velocity(:,1:2).^2, 2)) sqrt(sum(edge_velocity(:, 3:4).^2, 2))] ;
edge_veczero = double( edge_vecnm < eps ) ; % if norm is 0, then make it 1
edge_vecnm = edge_vecnm + edge_veczero ;
edge_velocity = [edge_velocity(:, 1)./edge_vecnm(:, 1) edge_velocity(:, 2)./edge_vecnm(:, 1) ...
				   edge_velocity(:, 3)./edge_vecnm(:, 2) edge_velocity(:, 4)./edge_vecnm(:, 2)] ;
maxvel = 1 ;

[A, b, edge_npairs] = composeRelaxationConstraints( edge_negpairs, nvars ) ;
edge_velocity = -exp(-2*( ( edge_velocity(:,1)-edge_velocity(:,3) ).^2+( edge_velocity(:,2)-edge_velocity(:,4) ).^2 ) )  ;

fprintf( 'Maxvel turns out to be %f\n', maxvel ) ;

% Very simple matrix, but created for debugging purposes. And also used to augment ytilde.
Q_data = zeros( edge_nnegpairs, 3 ) ;
assert(size(edge_negpairs, 1) == edge_nnegpairs)
Q_data(:, 1) = edge_negpairs(:,1) ;
Q_data(:, 2) = edge_negpairs(:,2) ;
Q_data(:, 3) = edge_velocity(:);

Q = sparse( Q_data(:, 1), Q_data(:, 2), Q_data(:, 3), nvarq, nvarq ) ;
