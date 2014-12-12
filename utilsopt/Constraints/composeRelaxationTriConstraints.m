function [A, b, edge_npairs] = composeRelaxationTriConstraints( edge_negpairs, nvars )
% function [A, b, edge_npairs] = composeRelaxationTriConstraints( edge_negpairs, nvars )

idx = find( edge_negpairs(:, 1) == 0 ) ;  
[~,btmp,~,A_datatmp] = composeRelaxationConstraints( edge_negpairs(idx,2:3), nvars ) ;
edge_negpairs(idx, :) = [] ;
nvars = nvars + length(idx) ;

edge_npairs = size( edge_negpairs, 1 ) ;

% xscent = [xs(:, 1) + xs(:, 3) xs(:, 2) + xs(:, 4)] / 2 ;
% xone = xscent(edge_xj(edge_negpairs(:,1)), 1) - xscent(edge_xi(edge_negpairs(:,1)), 1) ;
% yone = xscent(edge_xj(edge_negpairs(:,1)), 2) - xscent(edge_xi(edge_negpairs(:,1)), 2) ;
% xtwo = xscent(edge_xj(edge_negpairs(:,2)), 1) - xscent(edge_xi(edge_negpairs(:,2)), 1) ;
% ytwo = xscent(edge_xj(edge_negpairs(:,2)), 2) - xscent(edge_xi(edge_negpairs(:,2)), 2) ;

% edge_velocity = (xone-xtwo).^2 + (yone-ytwo).^2 ;
% edge_velocity = edge_velocity / max( edge_velocity ) ;

A_data = zeros(10*edge_npairs, 3) ;

% Convention. nvars is always nedgs + ndets + nsource + nsink + nbdry.
% So variables are arranged as 
% [
%      z-variable (connection + detction ),
%      source variables 
%      sink variables 
%      boundary variables (bdry source and bdry sink) (if they exist)
%      Relaxation variables
% ]
display('Its in the organize function') ;

if ~isempty( A_datatmp )
    maxeqs = max( A_datatmp(:, 1) ) ;
else
    maxeqs = 0 ;
end
for i = 1 : edge_npairs
	A_data( 10*i-9, 1 ) = 4*i-3+maxeqs ;
	A_data( 10*i-9, 2 ) = nvars+i ;
	A_data( 10*i-9, 3 ) = 1 ;

	A_data( 10*i-8, 1 ) = 4*i-3+maxeqs ;
	A_data( 10*i-8, 2 ) = edge_negpairs(i, 1) ;
	A_data( 10*i-8, 3 ) = -1 ;

	A_data( 10*i-7, 1 ) = 4*i-2+maxeqs ;
	A_data( 10*i-7, 2 ) = nvars+i ;
	A_data( 10*i-7, 3 ) = 1 ;

	A_data( 10*i-6, 1 ) = 4*i-2+maxeqs ;
	A_data( 10*i-6, 2 ) = edge_negpairs(i, 2) ;
	A_data( 10*i-6, 3 ) = -1 ;

    A_data( 10*i-5, 1 ) = 4*i-1+maxeqs ;
	A_data( 10*i-5, 2 ) = nvars+i ;
	A_data( 10*i-5, 3 ) = 1 ;

	A_data( 10*i-4, 1 ) = 4*i-1+maxeqs ;
	A_data( 10*i-4, 2 ) = edge_negpairs(i, 3) ;
	A_data( 10*i-4, 3 ) = -1 ;
    
	A_data( 10*i-3, 1 ) = 4*i+maxeqs ;
	A_data( 10*i-3, 2 ) = edge_negpairs(i, 1) ;
	A_data( 10*i-3, 3 ) = 1 ;

	A_data( 10*i-2, 1 ) = 4*i+maxeqs ;
	A_data( 10*i-2, 2 ) = edge_negpairs(i, 2) ;
	A_data( 10*i-2, 3 ) = 1 ;
    
    A_data( 10*i-1, 1 ) = 4*i+maxeqs ;
	A_data( 10*i-1, 2 ) = edge_negpairs(i, 3) ;
	A_data( 10*i-1, 3 ) = 1 ; 

	A_data( 10*i, 1 ) = 4*i+maxeqs ;
	A_data( 10*i, 2 ) = nvars+i ;
	A_data( 10*i, 3 ) = -1 ;
end

A_data = [A_datatmp; A_data] ;
A = sparse( A_data(:, 1), A_data(:, 2), A_data(:, 3), 4*edge_npairs+3*length(idx), nvars+edge_npairs ) ;
b = zeros( 4*edge_npairs, 1  ) ;
b(4:4:end) = 2 ;
b = [btmp;b] ;
edge_npairs = edge_npairs + length(idx) ;