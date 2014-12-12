function [A, b, edge_npairs] = composeRelaxationQuadConstraints( edge_negpairs, nvars )
% function [A, b, edge_npairs] = composeRelaxationQuadConstraints( edge_negpairs, nvars )

edge_npairs = size( edge_negpairs, 1 ) ;

% xscent = [xs(:, 1) + xs(:, 3) xs(:, 2) + xs(:, 4)] / 2 ;
% xone = xscent(edge_xj(edge_negpairs(:,1)), 1) - xscent(edge_xi(edge_negpairs(:,1)), 1) ;
% yone = xscent(edge_xj(edge_negpairs(:,1)), 2) - xscent(edge_xi(edge_negpairs(:,1)), 2) ;
% xtwo = xscent(edge_xj(edge_negpairs(:,2)), 1) - xscent(edge_xi(edge_negpairs(:,2)), 1) ;
% ytwo = xscent(edge_xj(edge_negpairs(:,2)), 2) - xscent(edge_xi(edge_negpairs(:,2)), 2) ;

% edge_velocity = (xone-xtwo).^2 + (yone-ytwo).^2 ;
% edge_velocity = edge_velocity / max( edge_velocity ) ;

A_data = zeros(13*edge_npairs, 3) ;

% Convention. nvars is always nedgs + ndets + nsource + nsink + nbdry.
% So variables are arranged as 
% [
%      z-variable (connection + detction ),
%      source variables 
%      sink variables 
%      boundary variables (bdry source and bdry sink) (if they exist)
%      Relaxation variables
% ]

for i = 1 : edge_npairs
	A_data( 13*i-12, 1 ) = 5*i-4 ;
	A_data( 13*i-12, 2 ) = nvars+i ;
	A_data( 13*i-12, 3 ) = 1 ;

	A_data( 13*i-11, 1 ) = 5*i-4 ;
	A_data( 13*i-11, 2 ) = edge_negpairs(i, 1) ;
	A_data( 13*i-11, 3 ) = -1 ;

	A_data( 13*i-10, 1 ) = 5*i-3 ;
	A_data( 13*i-10, 2 ) = nvars+i ;
	A_data( 13*i-10, 3 ) = 1 ;

	A_data( 13*i-9, 1 ) = 5*i-3 ;
	A_data( 13*i-9, 2 ) = edge_negpairs(i, 2) ;
	A_data( 13*i-9, 3 ) = -1 ;

    A_data( 13*i-8, 1 ) = 5*i-2 ;
	A_data( 13*i-8, 2 ) = nvars+i ;
	A_data( 13*i-8, 3 ) = 1 ;

	A_data( 13*i-7, 1 ) = 5*i-2 ;
	A_data( 13*i-7, 2 ) = edge_negpairs(i, 3) ;
	A_data( 13*i-7, 3 ) = -1 ;
    
    A_data( 13*i-6, 1 ) = 5*i-1 ;
	A_data( 13*i-6, 2 ) = nvars+i ;
	A_data( 13*i-6, 3 ) = 1 ;

	A_data( 13*i-5, 1 ) = 5*i-1 ;
	A_data( 13*i-5, 2 ) = edge_negpairs(i, 4) ;
	A_data( 13*i-5, 3 ) = -1 ;    
    
	A_data( 13*i-4, 1 ) = 5*i ;
	A_data( 13*i-4, 2 ) = edge_negpairs(i, 1) ;
	A_data( 13*i-4, 3 ) = 1 ;

	A_data( 13*i-3, 1 ) = 5*i ;
	A_data( 13*i-3, 2 ) = edge_negpairs(i, 2) ;
	A_data( 13*i-3, 3 ) = 1 ;
    
    A_data( 13*i-2, 1 ) = 5*i ;
	A_data( 13*i-2, 2 ) = edge_negpairs(i, 3) ;
	A_data( 13*i-2, 3 ) = 1 ;
    
	A_data( 13*i-1, 1 ) = 5*i ;
	A_data( 13*i-1, 2 ) = edge_negpairs(i, 4) ;
	A_data( 13*i-1, 3 ) = 1 ;    

	A_data( 13*i, 1 ) = 5*i ;
	A_data( 13*i, 2 ) = nvars+i ;
	A_data( 13*i, 3 ) = -1 ;
end

A = sparse( A_data(:, 1), A_data(:, 2), A_data(:, 3), 5*edge_npairs, nvars+edge_npairs ) ;
b = zeros( 5*edge_npairs, 1  ) ;
b(5:5:end) = 3 ;