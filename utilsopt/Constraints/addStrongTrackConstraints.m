function [Aeq, beq, Aeq_data] =  addStrongTrackConstraints( param, gt, ylabel )
% [xl, xu, Aeq, beq] = function addStrongTrackConstraints( param, Aeq_data, cntr, ylabel )
% This function basically takes ylabel, and for all detections that overlap with the same
% ground truth in the first and last frames, sets equality constraints
% on the edges connecting them to source and sink respecitvely.

detids = (param.nedgs+1):(param.nedgs+param.ndets) ;
nedgs = param.nedgs ;
ndets = param.ndets ;
ngttrcks = 0 ;
Aeq_data = zeros( 3e5, 3 ) ;
beq = [] ;
cntr = 0 ;
neqns = 0 ;
ntrcks = param.ntrcks ;
frids = param.frids ;
nvars = length(param.xl) ;

for i = 1 : max(gt.r)
	% first put source constraints for a track.
	tridx = find( gt.r == i ) ;

	if isempty(tridx)
		continue ;
	end

	frmin = min(gt.fr(tridx))-1 ;
	frmax = max(gt.fr(tridx))+1 ;

	idx = [] ;
	% find all detections that overlap with the ground truth of track
	% i in the first frame
	while isempty(idx) & (frmax<=max(frids))
		frmin = frmin + 1 ;
		idx = find( (ylabel(detids) == i ) & (frids == frmin ) ) ;
	end

	if ~isempty(idx)
		% Now put an additional set of constraint on all the sources in these variables.
		Aeq_data( (cntr+1):(cntr+length(idx)), 1 ) = neqns+1 ;
		Aeq_data( (cntr+1):(cntr+length(idx)), 2 ) = nedgs+ndets+idx ;
		Aeq_data( (cntr+1):(cntr+length(idx)), 3 ) = 1 ;
		cntr = cntr + length(idx) ;
		neqns = neqns + 1 ;
		beq = [beq; 1] ;
	end

	% Now find all detections that overlap with the ground truth track
	% i in the last frame
	idx = [] ;
	while isempty(idx) & (frmax>1)
		frmax = frmax-1 ;
		idx = find( (ylabel(detids) == i ) & (frids == frmax ) ) ;
	end

	if ~isempty(idx)
		% Now put an additional set of constraint on all the sink in these variables.
		Aeq_data( (cntr+1):(cntr+length(idx)), 1 ) = neqns+1 ;
		Aeq_data( (cntr+1):(cntr+length(idx)), 2 ) = nedgs+2*ndets+idx ;
		Aeq_data( (cntr+1):(cntr+length(idx)), 3 ) = 1 ;
		cntr = cntr + length(idx) ;
		neqns = neqns + 1 ;
		beq = [beq; 1] ;
	end

	% Now count the total number of present ground truth tracks.
	ngttrcks = ngttrcks + 1 ;
end

% Finally add constraints that will hard code the fact that the short circuit
% will have a flow of ntrcks - ngttracks 
Aeq_data( cntr+1, 1 ) = neqns+1 ;
Aeq_data( cntr+1, 2 ) = nvars - 1 ;
Aeq_data( cntr+1, 3 ) = 1 ;
cntr = cntr + 1 ;
neqns = neqns  + 1 ; 
beq = [beq; ntrcks-ngttrcks] ;

Aeq_data( cntr+1, 1 ) = neqns+1 ;
Aeq_data( cntr+1, 2 ) = nvars ;
Aeq_data( cntr+1, 3 ) = 1 ;
cntr = cntr + 1 ;
neqns = neqns  + 1 ; 
beq = [beq; ntrcks-ngttrcks] ;

Aeq = sparse( Aeq_data(1:cntr, 1), Aeq_data(1:cntr, 2), Aeq_data(1:cntr, 3), neqns, nvars ) ;

Aeq_data = Aeq_data(1:cntr, :) ;