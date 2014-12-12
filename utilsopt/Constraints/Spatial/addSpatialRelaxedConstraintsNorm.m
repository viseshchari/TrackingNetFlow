function [A, b, edge_velocity, Q_data, Q] = addSpatialRelaxedConstraints( detstruct, edge_xi, edge_xj, xs, frids, velthresh, nvars, nvarq )
% [A, b, edge_velocity] = addSpatialRelaxedConstraints( detstruct, edge_xi, edge_xj, xs, frids, velthresh, nvars )

if nargin < 8
	nvarq = nvars ;
end

[edge_negpairs, edge_nnegpairs, edge_velocity, maxvel] = addParallelismConstraints( xs, frids, edge_xi, edge_xj, velthresh ) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Normalization of Velocity Vectors %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
edge_vecnm = [sqrt(sum(edge_velocity(:,1:2).^2, 2)) sqrt(sum(edge_velocity(:, 3:4).^2, 2))] ;
edge_veczero = double( edge_vecnm < eps ) ; % if norm is 0, then make it 1
edge_vecnm = edge_vecnm + edge_veczero ;
edge_velocity = [edge_velocity(:, 1)./edge_vecnm(:, 1) edge_velocity(:, 2)./edge_vecnm(:, 1) ...
				   edge_velocity(:, 3)./edge_vecnm(:, 2) edge_velocity(:, 4)./edge_vecnm(:, 2)] ;

maxvel = 1 ;

[A, b, edge_npairs] = composeRelaxationConstraints( edge_negpairs, nvars ) ;
edge_velocity = ( ( edge_velocity(:,1)-edge_velocity(:,3) ).^2+( edge_velocity(:,2)-edge_velocity(:,4) ).^2 ) ;

% Very simple matrix, but created for debugging purposes. And now used to augment ytilde.
Q_data = zeros( edge_nnegpairs, 3 ) ;
for i = 1 : edge_nnegpairs
	Q_data(i, 1) = edge_negpairs(i, 1) ;
	Q_data(i, 2) = edge_negpairs(i, 2) ;
	Q_data(i, 3) = edge_velocity(i) ;
end

Q = sparse( Q_data(:, 1), Q_data(:, 2), Q_data(:, 3), nvarq, nvarq ) ;
