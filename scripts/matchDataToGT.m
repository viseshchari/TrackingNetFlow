function ylabel = matchDataToGT( xs, frids, edge_xi, edge_xj, gt, relprec )
% function ylabel = matchDataToGT( xs, frids, edge_xi, edge_xj, gt )
% This function takes as input the following variables.
% xs - matrix (n x 5) where n is the number of detections. Each row is ordered as
%			[xmin ymin width height confidence]
% frids - vector n x 1 where n is the number of detections. Represents the frame
%			number of each 
% edge_xi - vector e x 1 where e is the number of edges. Represents all the detection
%			indexes that form the left detection of the edge.
% edge_xj - vector e x 1 where e is the number of edges. Represents all the detection
%			indexes that form the right detection of the edge.
% gt	  - gt is a structure that represents all the ground truth bounding box information.
%		  - gt.x     - nd x 1 vector where nd is the number of ground truth detections.
%	      - gt.y     - nd x 1 vector of minimum y coordinate
%		  - gt.fr    - nd x 1 vector of frame numbers.
%		  - gt.r 	 - nd x 1 vector of track id.
%		  - gt.w 	 - nd x 1 vector of detection width.
%		  - gt.h 	 - nd x 1 vector of detection height.
% relprec - boolean variable denoting whether relaxed precision information needs to be computed.
% Output
% ylabel - binary vector specifying which detections and edges are part of the ground truth data.

if nargin < 7
	disp = false ;
end

if nargin < 6
	relprec = true ;
end

% Number of edges and detections.
nedgs = length(edge_xi) ;
ndets = size(xs, 1) ;

% Global variable that stores whether a detection or edge has enough overlap with
% the ground truth, so that it is not penalized if chosen.
global wval ;

% Create nd x 5 matrix of detections for ease of use.
rct = [gt.x gt.y gt.x+gt.w gt.y+gt.h] ; %  [minx miny maxx maxy] ylabel = zeros( nedgs+ndets, 1 ) ; % variable storing ground truth labels.
wval = ones( nedgs+ndets, 1 ) ; % initialize with 1, meaning all deviations are penalized.
ovthresh = 0.5 ;				% minimum overlap threshold.

% For each track present in the ground truth.
for i = 1 : max( gt.r )
	% First find the index of all the bounding boxes in the current track.
	idx = find( gt.r == i ) ;
	previdx = -1 ; % variable that stores the index of the detection assigned to ground truth in
							% previous iteration
	currtrckidx = [] ; % Display/Debug variable.
	fprintf( 'Track number %d\n', i ) ;
	
	% For each frame of the current track. Only one ground truth bounding box exists per frame.
	for j = min(gt.fr(idx)) : max( gt.fr(idx) )

		% Find the index of all detections in the current frame number
		idx2 = find( frids == j ) ;

		% Find the overlap between detections in the current frame and the selected bounding box.
		ov = bboxoverlapval( xs(idx2, 1:4), rct(idx(find(gt.fr(idx)==j)), 1:4) ) ;

		% Find the detection with maximum overlap with the ground truth bounding box.
		[mval, midx] = max( ov ) ;

		% If the maximum overlap is greater than overlap threshold
		if mval > ovthresh 	

			% Give the label 1 to the corresponding detection.
			ylabel(nedgs+idx2(midx)) = 1 ;

			% If a previous assignment exists
			if previdx ~= -1

				% Find the edge that is aligned with the current track.
				eidx = find( (edge_xi == previdx) & (edge_xj == idx2(midx)) ) ;

				% Give the label 1 to the corresponding edge.
				ylabel(eidx) = 1 ;

				% Store the index of assigned detection.
				prevfr = j ;
				previdx = idx2(midx) ;
			else
				% If previous assignment does not exist.
				% then just store the index of assigned detection.
				previdx = idx2(midx) ;
				prevfr = j ;
			end
		end

		% Find all the detections that had good overlap with the ground truth bounding box
		idxallow = find( mval > ovthresh ) ;

		% Relax precision variable turned on for all such detections with good overlap.
		if relprec
			wval(nedgs+idx2(midx(idxallow))) = 0 ;
		end
	end
end

% Find  all the edges that connect two detections of "relaxed precision"
% and mark these edges also for relaxed precision
if relprec
	idx = find( (wval(nedgs+edge_xi)+wval(nedgs+edge_xj)) == 0 ) ;
	wval(idx) = 0 ;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% End of Function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Discarded Code %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% for i = 1 : max( gt.fr )
%%%%% 	idx = find( gt.fr == i ) ;
%%%%% 	idx2 = find( frids == i ) ;
%%%%% 	ov = bboxoverlapval( xs(idx2, 1:4), rct(idx, 1:4) ) ;
%%%%% 	[mval, midx] = max( ov ) ;
%%%%% 	idxlone = find( mval > 0.49 ) ; % atleast a 0.5 overlap
%%%%% 	ylabel( (nedgs + idx2(midx(idxlone))) ) = rct(idx(idxlone), 5) ;
%%%%% end
%%%%% 
%%%%% % Now given all the detections, fill in all the edges.
%%%%% eqidx = find( (ylabel((nedgs+edge_xi)) == ylabel((nedgs+edge_xj))) & ...
%%%%% 		( ylabel((nedgs+edge_xi)) > 0 ) ) ;
%%%%% 
%%%%% % The problem here is that more than one edge belonging to a track might 
%%%%% % get turned on, but this might not be a bad thing.
%%%%% ylabel(eqidx) = 1 ;
%%%%% idxtmp = find( ylabel > 1 ) ;
%%%%% ylabel(idxtmp) = 1 ;
%%%%% keyboard ;
%%%%% % dbsum = ylabel((nedgs+edge_xi)) + ylabel((nedgs+edge_xj)) ;
%%%%% 
%%%%% % idx = find( dbsum == 2 ) ;
%%%%% % ylabel(idx) = 1 ;

