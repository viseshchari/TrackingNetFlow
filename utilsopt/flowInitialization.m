function [Aeq_data, cntr] = flowInitialization( edge_xi, edge_xj, nedgs, ndets )
% function [Aeq_data, cntr] = flowInitialization( edge_xi, edge_xj, nedgs, ndets )

Aeq_data = zeros( 3e7, 3 ) ;
Aeq_data(:, 3) = 1 ;
Aeq_data( 1:(2*ndets), 3 ) = -1 ;
Aeq_data( 1:ndets, 1 ) = 2*(1:ndets) - 1 ;
Aeq_data( 1:ndets, 2 ) = nedgs + (1:ndets) ;
Aeq_data( (ndets+1):(2*ndets), 1 ) = 2*(1:ndets) ;
Aeq_data( (ndets+1):(2*ndets), 2 ) = nedgs + (1:ndets) ;
Aeq_data( (2*ndets+1):(3*ndets), 1 ) = 2*(1:ndets) - 1 ;
Aeq_data( (2*ndets+1):(3*ndets), 2 ) = nedgs+ndets+(1:ndets) ;
Aeq_data( (3*ndets+1):(4*ndets), 1 ) = 2*(1:ndets) ;
Aeq_data( (3*ndets+1):(4*ndets), 2 ) = nedgs+2*ndets+(1:ndets) ;
cntr = 4 * ndets ;

for i = 1 : nedgs
	Aeq_data( cntr+1, 1 ) = 2*edge_xj(i)-1 ;
	Aeq_data( cntr+1, 2 ) = i ;
	cntr = cntr + 1 ;
	Aeq_data( cntr+1, 1 ) = 2*edge_xi(i) ;
	Aeq_data( cntr+1, 2 ) = i ;
	cntr = cntr + 1 ;
end 
