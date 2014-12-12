function [A, b, edge_velocity, Q_data, Q] = addThreadingConstraints( xs, frids, edge_xi, edge_xj, distthresh, firstdets, firstedgs, nvars, nvarq )
% function [A, b, edge_velocity, Q_data, Q] = addThreadingConstraints( xs, frids, edge_xi, edge_xj, distthresh, firstdets, firstedgs, nvars, nvarq )

maxdiff = max( frids( edge_xj ) - frids( edge_xi ) ) ;
maxfr = max( frids ) ;
minfr = min( frids ) ;
nedgs = length(edge_xi) ;

dx = (xs(:,1)+xs(:,3)) / 2 ;
dy = xs(:,2) ;
dy(1:firstdets) = ( dy(1:firstdets) + xs(1:firstdets, 4) ) / 2 ;


%% This code computes all the head detections that "thread through" edges connecting human detections.
midx = ( xs((firstdets+1):end, 1) + xs((firstdets+1):end, 3) ) / 2 ;
leftx = xs((firstdets+1):end, 1) ;
rightx = xs((firstdets+1):end, 3) ;
midy = xs((firstdets+1):end, 2) + 10 ;

gracethresh = 5 ; % This allows for some leeway

ldx = xs(1:firstdets, 1) - gracethresh ;
rdx = xs(1:firstdets, 3) + gracethresh ;
ldy = xs(1:firstdets, 2) - gracethresh ;
rdy = xs(1:firstdets, 4) + gracethresh ;
collect_pts = zeros(80000000, 6) ;
cntr = 1 ;
tic ;
for i = (firstedgs+1):length(edge_xi)
    if toc > 10
        fprintf('Edge Number %d/%d\n', i, length(edge_xi)) ;
        tic ;
    end
    fx = frids( edge_xi(i) ) ;
    fy = frids( edge_xj(i) ) ;
	if (fy-fx) > 4
		continue ;
	end
    range = fx : fy ;
    range = range - fx ;
    range = range' / (fy-fx) ;
    mx = midx( edge_xi(i)-firstdets ) * (1-range) + midx( edge_xj(i)-firstdets ) * range ;
    lx = leftx( edge_xi(i)-firstdets ) * (1-range) + leftx( edge_xj(i)-firstdets ) * range ;
    rx = rightx( edge_xi(i)-firstdets ) * (1-range) + rightx( edge_xj(i)-firstdets ) * range ;
    my = midy( edge_xi(i)-firstdets ) * (1-range) + midy( edge_xj(i)-firstdets ) * range ;
    collect_pts(cntr:(cntr+length(range)-1), 1) = i ;
    collect_pts(cntr:(cntr+length(range)-1), 2) = [fx:fy]' ;
    collect_pts(cntr:(cntr+length(range)-1), 3) = mx ;
    collect_pts(cntr:(cntr+length(range)-1), 4) = lx ;
    collect_pts(cntr:(cntr+length(range)-1), 5) = rx ;
    collect_pts(cntr:(cntr+length(range)-1), 6) = my ;
    cntr = cntr + length(range) ;
%     collect_pts = [collect_pts; [i*ones(fy-fx+1,1) [fx:fy]' mx lx rx my]] ;
end
    

tic ;
edge_pairs = zeros(10000000,2) ;
edge_negpair = zeros(10000000,2) ;
cntrp = 1 ;
cntrn = 1 ;
% for i = 1 : firstdets
%      if toc > 10
%          fprintf( 'In polygon frame %d/%d\n', i, firstdets ) ;
%          tic ;
%      end
% 	idx2 = find( collect_pts(:, 2) == frids(i) ) ;
% 	in = inpolygon( collect_pts(idx2, 3), collect_pts(idx2, 6), xs(i, [1 1 3 3 1]), xs(i, [2 4 4 2 2]) ) ;
% 	idxtmp = find(in) ;
% 	edgs = collect_pts(idx2(idxtmp), 1) ;
% 	edge_pairs(cntrp:(cntrp+length(idxtmp)-1), 1) = edgs ;
% 	edge_pairs(cntrp:(cntrp+length(idxtmp)-1), 2) = nedgs+i ; % [edge_pairs; [edgs nedgs+i*ones(length(idxtmp),1)]] ;
% 	cntrp = cntrp+length(idxtmp) ;
% 	% for k = 1 : length(edgs)
% 	% 	edge_negpair(cntrn:(cntrn+length(edgs)-k-1), 1) = edgs(k) ;
% 	% 	edge_negpair(cntrn:(cntrn+length(edgs)-k-1), 2) = edgs((k+1):end) ;
% 	% 	cntrn = cntrn+length(edgs)-k ;
% 	% 	% edge_negpair = [edge_negpair; [edgs(k)*ones(length(edgs)-k,1) [edgs((k+1):end)] ] ] ;
% 	% end
% end

for i = minfr : maxfr
    if toc > 10
        fprintf( 'In polygon frame %d/%d\n', i, maxfr ) ;
        tic ;
    end
    idx1 = find( frids(1:firstdets) == i ) ;
    idx2 = find( collect_pts(:, 2) == i ) ;
    
    for j = 1 : length(idx1)
        in = inpolygon( collect_pts(idx2, 3), collect_pts(idx2, 6), xs(idx1(j),[1 1 3 3 1]), xs(idx1(j), [2 4 4 2 2]) ) ;
        idxtmp = find( in ) ;
        edge_pairs(cntrp:(cntrp+length(idxtmp)-1), 1) = collect_pts(idx2(idxtmp),1) ;
		edge_pairs(cntrp:(cntrp+length(idxtmp)-1), 2) = nedgs+idx1(j) ; % [edge_pairs; [collect_pts(idx2(idxtmp),1) nedgs+idx1(j)*ones(length(idxtmp),1)]] ;
		cntrp = cntrp + length(idxtmp) ;
		edgs = collect_pts(idx2(idxtmp),1) ;
		if length(edgs) < 2
			continue ;
		end
		for k = 1 : length(edgs)
			edge_negpair(cntrn:(cntrn+length(edgs)-k-1), 1) = edgs(k) ;
			edge_negpair(cntrn:(cntrn+length(edgs)-k-1), 2) = edgs((k+1):end) ; % [edge_negpair; [edgs(k)*ones(length(edgs)-1,1) [edgs((k+1):end)] ] ] ;
			cntrn = cntrn + length(edgs) - k ;
		end
    end
end
    
edge_pairs = edge_pairs(1:(cntrp-1), :) ;
edge_negpair = edge_negpair(1:(cntrn-1), :) ;
% idxtmp = find( edge_negpair(:,2) < edge_negpair(:, 1) ) ;
% [edge_negpair(idxtmp,1) edge_negpair(idxtmp,2)] = deal(edge_negpair(idxtmp,2), edge_negpair(idxtmp,1)) ;
%         idmx = find( (frids(1:firstdets) == j) & (mx >= ldx) & (mx <= rdx) & (my >= ldy) & (my <= rdy) ) ;
%         idlx = find( (frids(1:firstdets) == j) & (lx >= ldx) & (lx <= rdx) & (my >= ldy) & (my <= rdy) ) ;
%         idrx = find( (frids(1:firstdets) == j) & (rx >= ldx) & (rx <= rdx) & (my >= ldy) & (my <= rdy) ) ;
%         edge_pairs = [edge_pairs; [i*ones(length(idmx),1) nedgs+idmx]] ;
%         edge_pairs = [edge_pairs; [i*ones(length(idlx),1) nedgs+idlx]] ;
%         edge_pairs = [edge_pairs; [i*ones(length(idrx),1) nedgs+idrx]] ;
%     end
edge_pairs = unique(edge_pairs, 'rows') ;
edge_negpair = unique(edge_negpair, 'rows') ;
size(edge_negpair)
idxtmp = find( edge_xi(edge_negpair(:,1)) == edge_xj(edge_negpair(:,2)) ) ;
edge_negpair(idxtmp, :) = [] ;
idxtmp = find( edge_xj(edge_negpair(:,1)) == edge_xj(edge_negpair(:,2)) ) ;
edge_negpair(idxtmp, :) = [] ;
idxtmp = find( edge_xi(edge_negpair(:,1)) == edge_xi(edge_negpair(:,2)) ) ;
edge_negpair(idxtmp, :) = [] ;
idxtmp = find( edge_xj(edge_negpair(:,1)) == edge_xi(edge_negpair(:,2)) ) ;
edge_negpair(idxtmp, :) = [] ;
edge_velocity = -10./(frids(edge_xj(edge_pairs(:,1))) - frids(edge_xi(edge_pairs(:,1)))) ;
edge_pairs = [edge_pairs; edge_negpair] ;
edge_velocity = [edge_velocity; 10*ones(length(edge_negpair), 1)] ;

% % headBox = {} ;
% % edstart = {} ;
% % edge_pairs = [] ;
% % for i = (firstdets+1):length(dx)
% %     headBox{i-firstdets} = [] ;
% % end
% % for i = 1:firstdets
% %     edstart{i} = [] ;
% % end
% % 
% % for i = 1:firstedgs
% %     edstart{edge_xi(i)} = [edstart{edge_xi(i)} i] ;
% %     edstart{edge_xj(i)} = [edstart{edge_xj(i)} i] ;
% % end
% % 
% % tic ;
% % for i = minfr : maxfr
% %     if toc > 1
% %         fprintf( 'Frame %d/%d in building datastruct\n', i, maxfr ) ;
% %         tic ;
% %     end
% %     idx1 = find( frids(1:firstdets) == i ) ;
% %     idx2 = find( frids((firstdets+1):end) == i ) + firstdets ;
% %     
% %     l1 = length(idx1) ;
% %     l2 = length(idx2) ;
% %     
% %     dist = sqrt( (repmat( dx(idx1), 1, l2 ) - repmat( dx(idx2)', l1, 1 )).^2 + ( repmat( dy(idx1), 1, l2 ) - repmat( dy(idx2)', l1, 1 ) ).^2 ) ;
% %     dist = dist' ;
% %     for j = 1 : length(idx2)
% %         idx3 = find( dist(j, :) < distthresh ) ;
% %         headBox{idx2(j)-firstdets} = [headBox{idx2(j)-firstdets} cat(1,cell2mat(edstart(idx1(idx3))))] ;
% %     end
% % end
 
% % tic ;
% % for i = (firstedgs+1):length(edge_xi)
% %     if toc > 10
% %         fprintf( 'Adding edges %d/%d\n', i, length(edge_xi) ) ;
% %         tic ;
% %     end
% %     idx1 = headBox{edge_xi(i)-firstdets} ;
% %     idx2 = headBox{edge_xj(i)-firstdets} ;
% %     idx12 = intersect( idx1, idx2 ) ;
% %     if ~isempty(idx12)
% %         edge_pairs = [edge_pairs; [i*ones(length(idx12),1) idx12']] ;
% %     end
% % end

% %% This code just computes the quadratic function for forcing two detections to be selected together.
% for i = minfr : maxfr
%    idx1 = find( frids(1:firstdets) == i ) ;
%    idx2 = find( frids((firstdets+1):end) == i ) + firstdets ;
%    
%    mx1 = ( xs( idx1, 1 ) + xs( idx1, 3 ) ) / 2 ;
%    my1 = ( xs( idx1, 2 ) + xs( idx1, 4 ) ) / 2 ;
%    
%    mx2 = ( xs( idx2, 1 ) + xs( idx2, 3 ) ) / 2 ;
%    my2 = xs( idx2, 2 ) ;
%    
%    l1 = length(idx1) ;
%    l2 = length(idx2) ;
%    
%    dist = sqrt( ( repmat( mx2', l1, 1 ) - repmat( mx1, 1, l2 ) ).^2 + ( repmat( my2', l1, 1 ) - repmat( my1, 1, l2 ) ).^2 ) ;
%    [idx1sel, idx2sel] = ind2sub( size(dist), find( dist(:) < distthresh ) ) ;
%    edge_pairs = [edge_pairs; nedgs+[idx1(idx1sel) idx2(idx2sel)]] ;
% end
 
% tic ;
% %% This code computes the quadratic function for selecting two edges together.
% for i = minfr : maxfr
%     for j = 1 : maxdiff
%         if toc > 10
%             fprintf( 'In Frame %d/%d\n', i, i+j ) ;
%             tic ;
%         end
%             
%         idx1 = find( ( frids(edge_xi(1:firstedgs)) == i ) & ( frids(edge_xj(1:firstedgs)) == (i+j) ) ) ;
%         idx2 = find( ( frids(edge_xi((firstedgs+1):end)) == i ) & ( frids(edge_xj((firstedgs+1):end)) == (i+j) ) ) + firstedgs ;
%         
%         l1 = length(idx1) ;
%         l2 = length(idx2) ;
%         
%         dist1 = ( ( repmat( dx(edge_xi(idx1)), 1, l2 ) - repmat( dx(edge_xi(idx2))', l1, 1 ) ).^2 + ...
%                    ( repmat( dy(edge_xi(idx1)), 1, l2 ) - repmat( dy(edge_xi(idx2))', l1, 1 ) ).^2 ) ;
%         dist2 = ( ( repmat( dx(edge_xj(idx1)), 1, l2 ) - repmat( dx(edge_xj(idx2))', l1, 1 ) ).^2 + ...
%                    ( repmat( dy(edge_xj(idx1)), 1, l2 ) - repmat( dy(edge_xj(idx2))', l1, 1 ) ).^2 ) ;
%                
%         distedge = ( sqrt(dist1) < distthresh ) & ( sqrt(dist2) < distthresh ) ;
%         [idx1sel, idx2sel] = ind2sub( size(distedge), find( distedge(:) ) ) ;
%         
%         edge_pairs = [edge_pairs; idx1(idx1sel) idx2(idx2sel)] ;
%     end
% end
% 
% edge_pairs = unique( edge_pairs, 'rows' ) ;

[A, b, edge_npairs,~] = composeRelaxationConstraints( edge_pairs, nvars ) ;

Q_data = zeros( edge_npairs, 3 ) ;
Q_data(:, 1) = edge_pairs(:,1) ;
Q_data(:, 2) = edge_pairs(:,2) ;
Q_data(:, 3) = edge_velocity ;

Q = sparse( Q_data(:, 1), Q_data(:, 2), Q_data(:, 3), nvarq, nvarq ) ;

% edge_velocity = -1 * ones(edge_npairs, 1) ;
