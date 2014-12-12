function [xl, xu, Aeq, beq, Aeq_data, cntr] = addFlowConstraints( xs, frids, Aeq_data, cntr, nedgs, ndets, nvars, ntrcks, firstdets )
% function [Aeq, beq] = addFlowConstraints( xs, frids, Aeq_data, cntr, nedgs, ndets, nvars, ntrcks )

nvars = nedgs + 3*ndets ;

if nargin < 9
	beq = zeros( 2*ndets+3, 1 ) ;
	Aeq_data( (cntr+1):(cntr+ndets+1), 1 ) = 2*ndets+1 ;
	Aeq_data( (cntr+1):(cntr+ndets+1), 2 ) = [nedgs+ndets+(1:ndets) nvars+1] ;
	cntr = cntr + ndets + 1 ;
	Aeq_data( (cntr+1):(cntr+ndets+1), 1 ) = 2*ndets+2 ;
	Aeq_data( (cntr+1):(cntr+ndets+1), 2 ) = [nedgs+2*ndets+(1:ndets) nvars+2] ;
	cntr = cntr + ndets + 1 ;
	beq((2*ndets+1):(2*ndets+2)) = ntrcks ; % 41 for 879, 50 for 7
	extra = 0 ;
else
    beq = zeros( 2*ndets+4, 1 ) ;
    Aeq_data( (cntr+1):(cntr+firstdets+1), 1 ) = 2*ndets+1 ;
    Aeq_data( (cntr+1):(cntr+firstdets+1), 2 ) = [nedgs+ndets+(1:firstdets) nvars+1] ;
    cntr = cntr + firstdets + 1 ;
    Aeq_data( (cntr+1):(cntr+(ndets-firstdets)+1), 1 ) = 2*ndets+2 ;
    Aeq_data( (cntr+1):(cntr+(ndets-firstdets)+1), 2 ) = [nedgs+ndets+((firstdets+1):ndets) nvars+1] ;
    cntr = cntr + (ndets-firstdets) + 1 ;
    Aeq_data( (cntr+1):(cntr+ndets+1), 1 ) = 2*ndets+3 ;
    Aeq_data( (cntr+1):(cntr+ndets+1), 2 ) = [nedgs+2*ndets+(1:ndets) nvars+2] ;
    cntr = cntr + ndets + 1 ;
    beq((2*ndets+1):(2*ndets+2)) = ntrcks / 2 ;
    beq(2*ndets+3) = ntrcks ;
    extra = 1 ;
end

% Now add shortcircuit constraint.
Aeq_data( cntr+1, 1 ) = 2*ndets+3+extra ;
Aeq_data( cntr+1, 2 ) = nvars+1 ;
Aeq_data( cntr+1, 3 ) = 1 ;
Aeq_data( cntr+2, 1 ) = 2*ndets+3+extra ;
Aeq_data( cntr+2, 2 ) = nvars+2 ;
Aeq_data( cntr+2, 3 ) = -1 ;
cntr = cntr + 2 ;	

Aeq = sparse( Aeq_data(1:cntr, 1), Aeq_data(1:cntr, 2), Aeq_data(1:cntr, 3), 2*ndets+3+extra, nvars+2 ) ;
xl = zeros( nvars+2, 1 ) ;
xu = ones( nvars+2, 1 ) ;
xu(nvars+1) = ntrcks ;
xu(nvars+2) = ntrcks ;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
