function [c, Q] = getweightedObjective( pm, model, x )

xedgs = double( x( pm.connids ) ) ;
xdets = double( x( pm.detids ) ) ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Scale the linear data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% construct coefficient vector with following operation.
% [w_1 * edge_vector + w_2
%  w_3 * detection_vector + w_4]
c = [model.w(1)/pm.featScale(1) * xedgs + model.w(2)/pm.featScale(2) ; ...
	model.w(3)/pm.featScale(1) * xdets + model.w(4)/pm.featScale(4) ; ...
	zeros( pm.applen, 1 )] ;

if ~pm.linearrelaxation
	% scale the QP matrix
	if pm.onlyquadscaling
		if pm.spatiotemporal
			Q = 2*pm.Q'*pm.Q * model.w(5)/pm.featScale(5) + 2*pm.Qt'* pm.Qt * model.w(6)/pm.featScale(6) ;
		else
			Q = 2*pm.Q'*pm.Q * model.w(5)/pm.featScale(5) ; % only add quadratic scaling term.
		end
	else
		%%%% NO SPATIOTEMPORAL HERE!!
		% First compute bias term by creating a matrix of similar structure as Q but with just 1's
		% Then compute Q'*Q with this new matrix, and compute its maximum value.
		% Then multiple this *normalize* matrix with the quadratic bias parameter and
		% add to the quadratic term.
		Qa = sparse( pm.Q_data(:, 1), pm.Q_data(:, 2), 1, max(pm.Q_data(:,1)), pm.nvars ) ; 
		Qmax = max(max(Qa'*Qa)) ; % normalization factor for bias matrix.
		Q = 2*pm.Q'*pm.Q * model.w(5)/pm.featScale(5) + 2*Qa'*Qa*model.w(6) / Qmax / pm.featScale(6) ;
	end
else
	% in linear relaxation case, scale the LP matrix 
	if pm.onlyquadscaling
		if pm.spatiotemporal
			qdata = [pm.Q_data; pm.Qt_data] ;
			ed = pm.edge_velocity * model.w(5) / pm.featScale(5) ;
			edt = pm.edge_secvelocity * model.w(6) / pm.featScale(6) ;
			Q = sparse( qdata(:, 1), qdata(:, 2), [ed; edt], pm.nvars, pm.nvars ) ; 
        elseif pm.dimension > 4
			Q = sparse( pm.Q_data(:, 1), pm.Q_data(:, 2), pm.Q_data(:, 3) * model.w(5)/pm.featScale(5), pm.nvars, pm.nvars ) ; % only add quadratic scaling term.
        else
            Q = sparse( [], [], [], pm.nvars, pm.nvars ) ; % linear case
        end
	else
		%%%%% NO SPATIOTEMPORAL HERE!!
		% First compute bias term by creating a matrix of similar structure as Q but with just 1's
		% Then compute Q'*Q with this new matrix, and compute its maximum value.
		% Then multiple this *normalize* matrix with the quadratic bias parameter and
		% add to the quadratic term.
		Q = sparse( pm.Q_data(:, 1), pm.Q_data(:, 2), pm.Q_data(:, 3) * model.w(5)/pm.featScale(5), pm.nvars, pm.nvars ) ;
		Qa = sparse( pm.Q_data(:, 1), pm.Q_data(:, 2), 1, max(pm.Q_data(:,1)), pm.nvars, pm.nvars ) ; 
		Qmax = max(max(Qa'*Qa)) ; % normalization factor for bias matrix.
		Q = Q + Qa'*Qa*model.w(6) / (Qmax * pm.featScale(6)) ;
	end 
	Q = Q + Q' ;
end
