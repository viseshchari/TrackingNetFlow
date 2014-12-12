function [A, b, edge_secvelocity, Q_data, Q] = addOverlapRelaxedConstraintsOld( xs, frids, edge_xi, edge_xj, ovthresh, nvars, nvarq, firstdets, firstedgs ) 
% function [A2, b2, param.edge_secvelocity, param.Qt_data, param.Qt] = addOverlapRelaxedConstraintsOld( xs, frids, ovthresh ) 
% This function computes the overlap between all pairs of detections in a frame for all the frames of the video,
% and if the overlap value is greater than ovthresh, then it adds a constraint that discourages the pairs of 
% detections from being selected simultaneously.

if nargin < 9
    firstedgs = 0 ;
end

if nargin < 8
	firstdets = 0 ;
    firstedgs = 0 ;
end

if nargin < 5
	nvarq = nvars ;
end

% First finish off detection overlap. Easy stuff.
Q_data = zeros(0, 3) ;
nedgs = length(edge_xi) ;
ndets = size(xs, 1) ; 
tic ;

%%%%%%%%% Detection - Detection overlaps
for i = min(frids) : max(frids)
	idx = find( frids == i ) ;
	idx2 = find( (frids < (i+2)) & (frids >= i) ) ;
 	idx = setdiff( idx, [1:firstdets]' ) ;
 	idx2 = setdiff( idx2, [1:firstdets]' ) ;
	if toc > 10
		fprintf('Processing frame number %d/%d for overlap\n', i, max(frids)) ;
		tic 
	end

	ov = triu( bboxoverlapval( xs(idx, 1:4), xs(idx2, 1:4), 3 ) ) ;
	ovold = ov ;
	% ov(1:(length(idx)+1):(length(idx)*length(idx))) = 0 ; % remove all the self overlaps computed.
	% assert( sum( sum( abs( ovold-diag(diag(ovold)) - ov ) ) ) < eps ) ; % This assert does not work for non-square matrices


	ovidx = find( ov(:) > ovthresh ) ;
	[ei, ej] = ind2sub( size(ov), ovidx ) ;
	idxtmp = find( ((idx(ei)<=firstdets)&(idx2(ej)<=firstdets)) | ((idx(ei)>firstdets)&(idx2(ej)>firstdets)) ) ;
	ei = ei(idxtmp) ;
	ej = ej(idxtmp) ;
	ovidx = ovidx(idxtmp) ;
	idxtmp = find( (idx(ei)~=idx2(ej)) ) ;
	ei = ei(idxtmp) ;
	ej = ej(idxtmp) ;
	ovidx = ovidx(idxtmp) ;
	Q_data = [Q_data; [nedgs+idx(ei) nedgs+idx2(ej) 10*ones(length(ovidx), 1)]] ;
end

% Now check all the pairs of detections that have an edge connecting them.
% Obviously these two detections can be selected together.
[c, ia, ib] = intersect( nedgs+[edge_xi, edge_xj], Q_data(:, 1:2), 'rows' ) ;
Q_data = Q_data( setdiff( 1:size(Q_data,1), ib ), : ) ; 
fprintf('commenting done') ;
% % keyboard ;

% Now comes edge overlap stuff. Algorithm to do this.
% Select all the edges who cross each other. This can be done in the following way.
% - Compute line segments connecting each detetion centre of an edge.
% - Check if two line segments are parallel (angle between them is 0)
% - Otherwise check if their intersection point lies on the line segment.
% - This amounts to solve a set of linear equations. 

xscent = [xs(:,1)+xs(:,3) xs(:,2)+xs(:,4)] / 2 ;
vec = [xscent(edge_xi, 1) xscent(edge_xi, 2) xscent(edge_xj, 1) xscent(edge_xj, 2)] ; 
fri = frids(edge_xi) ;
frj = frids(edge_xj) ;
% fri( find( edge_xi <= firstdets ) ) = -Inf ;
% frj( find( edge_xj <= firstdets ) ) = -Inf ;
% 
%%%%%%% Edge - Detection overlaps
% % tic ;
% % for i = min(frids) : max(frids)
% % 	for j = i+2 : i+10
% % 		if toc > 10
% % 			fprintf('Now intersecting edge detection %d/%d\n', i, max(frids) ) ;
% % 			tic ;
% % 		end
% % 		idx = setdiff( find( (frids > i) & (frids < j) ),1:firstdets ) ; % find all in-between detections
% % 		idx2 = find( (fri<=i) & (frj>=j) & (edge_xi > firstdets) ) ;
% % 		inter1 = lineSegmentIntersect( [xs(idx, 1) xs(idx, 2) xs(idx, 3) xs(idx, 2)], vec(idx2, :) ) ;
% % 		inter2 = lineSegmentIntersect( [xs(idx, 1) xs(idx, 4) xs(idx, 3) xs(idx, 4)], vec(idx2, :) ) ; 
% % 		inter3 = lineSegmentIntersect( [xs(idx, 1) xs(idx, 2) xs(idx, 1) xs(idx, 4)], vec(idx2, :) ) ;
% % 		inter4 = lineSegmentIntersect( [xs(idx, 3) xs(idx, 2) xs(idx, 3) xs(idx, 4)], vec(idx2, :) ) ;
% % 		ei1 = idx(inter1(:,1)) ; ej1 = idx2(inter1(:,2)) ;
% % 		if size(ei1, 1) == 1
% % 			ei1 = ei1' ;
% % 		end
% % 		if size(ej1, 1) == 1
% % 			ej1 = ej1' ;
% % 		end
% % 		ei2 = idx(inter2(:,1)) ; ej2 = idx2(inter2(:,2)) ;
% % 			if size(ei2, 1) == 1
% % 			ei2 = ei2' ;
% % 		end
% % 		if size(ej2, 1) == 1
% % 			ej2 = ej2' ;
% % 		end
% % 		ei3 = idx(inter3(:,1)) ; ej3 = idx2(inter3(:,2)) ;
% % 			if size(ei3, 1) == 1
% % 			ei3 = ei3' ;
% % 		end
% % 		if size(ej3, 1) == 1
% % 			ej3 = ej3' ;
% % 		end
% % 		ei4 = idx(inter4(:,1)) ; ej4 = idx2(inter4(:,2)) ;
% % 			if size(ei4, 1) == 1
% % 			ei4 = ei4' ;
% % 		end
% % 		if size(ej4, 1) == 1
% % 			ej4 = ej4' ;
% % 		end
% % 		Q_data = [Q_data; nedgs+[(ei1);(ei2);(ei3);(ei4)] [(ej1);(ej2);(ej3);(ej4)] 10*ones(length(ei1)+length(ei2)+length(ei3)+length(ei4), 1)] ;
% % 	end
% % end
% % Had to switch off for CRW data because it is just way too long.
% % %%%%% Edge - Edge overlaps
tic ;
for i = min(frids) : max(frids)
	for j = i+1 : i+5
		idx = find( (fri == i) & (frj == j) ) ;
        idxtmp = find( idx <= firstedgs ) ;
		edge_pairs1 = idxtmp(lineSegmentIntersect( vec(idx(idxtmp), :), vec(idx(idxtmp), :) )) ;
        if size(edge_pairs1, 2) == 1
            edge_pairs1 = edge_pairs1' ;
        end
        idxtmp = find( idx > firstedgs ) ;
		edge_pairs2 = idxtmp(lineSegmentIntersect( vec(idx(idxtmp), :), vec(idx(idxtmp), :) )) ;
        if size(edge_pairs2, 2) == 1
            edge_pairs2 = edge_pairs2' ;
        end
        edge_pairs = [edge_pairs1; edge_pairs2] ;
        
		idx2 = find( (edge_xi(idx(edge_pairs(:,1))) ~= edge_xi(idx(edge_pairs(:, 2)))) & ...
						(edge_xj(idx(edge_pairs(:,1))) ~= edge_xj(idx(edge_pairs(:, 2)))) ) ;
		if toc > 10
			fprintf('Processing frame pair %d %d\n', i, j) ;
		end
		if ~isempty(edge_pairs)
            tmpvec = idx(edge_pairs(idx2, :)) ;
            if size(tmpvec, 2) == 1
                tmpvec = tmpvec' ;
            end
            Q_data = [Q_data; [tmpvec 10*ones(length(idx2), 1)]] ;
		end

		%% Just for display purposes. Remove later.
		% figure; hold on ;
		% l1 = line( vec(idx(edge_pairs(idx2, 1)), [1 3])', vec(idx(edge_pairs(idx2, 1)), [2 4])') ;
		% l2 = line( vec(idx(edge_pairs(idx2, 2)), [1 3])', vec(idx(edge_pairs(idx2, 2)), [2 4])') ;
		% set(l1, 'color', 'r' ) ;
		% set( l2, 'color', 'b' ) ;
		% keyboard ;
	end
end

[uniqIndices, ~, ib] = unique( Q_data, 'rows' ) ;
Q_data = uniqIndices ; % This modification ensures that I can check exact equality between solutions produced in old and refactored code.

[A, b, edge_nvelocity] = composeRelaxationConstraints( Q_data(:, 1:2), nvars ) ;
edge_secvelocity = Q_data(:, 3) ;

Q = sparse( Q_data(:, 1), Q_data(:, 2), Q_data(:, 3), nvarq, nvarq ) ;



