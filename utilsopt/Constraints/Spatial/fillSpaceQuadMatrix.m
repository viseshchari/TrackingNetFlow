function [Q_data, nvals] = fillSpaceQuadMatrix( edge_group, edge_cost, nedgs, ntrcks, maxvel ) 
% function [Q_data, nvals] = fillSpaceQuadMatrix( pm, edge_group, edge_cost, nedgs, ntrcks )

nvals = size( edge_group, 1 ) ;	
Q_data = ones(4*nvals, 3) ;
maxvel = sqrt(maxvel) ;
edge_cost(:, 1:2) = edge_cost(:, 1:2) ./ maxvel ;
edge_cost(:, 3:4) = edge_cost(:, 3:4) ./ maxvel ;
eqcntr = 1 ;
edusedcntr = 1 ;

tic ;
edlength = zeros( nedgs,1) ;
for i = 1 : nedgs
	idxone = find( edge_group(:, 1) == i ) ;
	edlength(i) = length(idxone) ;
	if isempty(idxone)
		continue ;
	end
	if toc > 5
		fprintf( 'Processing group d %d\n', i ) ;
		tic ;
	end
	Q_data(eqcntr, 1) = edusedcntr ;
	Q_data(eqcntr, 2) = i ;
	Q_data(eqcntr, 3) = edge_cost(idxone(1), 1) ;
	Q_data(eqcntr+(1:length(idxone)), 1) = edusedcntr ;
	Q_data(eqcntr+(1:length(idxone)), 2) = edge_group(idxone, 2) ;
	Q_data(eqcntr+(1:length(idxone)), 3) = -(edge_cost(idxone, 3))/(ntrcks + 30 - length(idxone)) ; % ntrcks+30 works best for scene7
										% FREE VARIABLE %%%%%%% HARD CONSTRAINT %%%%%%%
	edusedcntr = edusedcntr + 1 ;
	eqcntr = eqcntr + 1 + length(idxone) ;
	Q_data(eqcntr, 1) = edusedcntr ;
	Q_data(eqcntr, 2) = i ;
	Q_data(eqcntr, 3) = edge_cost(idxone(1), 2) ;
	Q_data(eqcntr+(1:length(idxone)), 1) = edusedcntr ;
	Q_data(eqcntr+(1:length(idxone)), 2) = edge_group(idxone, 2) ;
	Q_data(eqcntr+(1:length(idxone)), 3) = -(edge_cost(idxone, 4))/(ntrcks + 30 - length(idxone)) ;
	edusedcntr = edusedcntr + 1 ;
	eqcntr = eqcntr + 1 + length(idxone) ;
end
Q_data = Q_data(1:(eqcntr-1), :) ;

nvals = (edusedcntr-1) / 2 ;