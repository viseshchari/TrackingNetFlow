function [A, b, edge_velocity, Q_data, Q] = addTemporalTriRelaxedConstraints( detstruct, xs, frids, edge_xi, edge_xj, nvars, nvarq, firstdets )
% function [A, b, edge_velocity, Q_data, Q] = addTemporalTriRelaxedConstraints( detstruct, xs, frids, edge_xi, edge_xj )
if nargin < 8
	firstdets = 0 ;
end

% Then compute the centres of the detections.
xscent = [xs(:,1)+xs(:,3) xs(:,2)+xs(:,4)]/2.0 ;

fr = frids(edge_xj) - frids(edge_xi) ;

normdiff = 1 ;

% Then compute velocity of each edge.
xvel = ( xscent(edge_xj, 1) - xscent(edge_xi, 1) ) ./ ( frids(edge_xj) - frids(edge_xi) ) ;
yvel = ( xscent(edge_xj, 2) - xscent(edge_xi, 2) ) ./ ( frids(edge_xj) - frids(edge_xi) ) ;

for i = 1 : length(detstruct)
   ei = detstruct(i).edgenum ;
   detstruct(i).xvel = xvel(ei)' ;
   detstruct(i).yvel = yvel(ei)' ;
end

% create second layer.
for i = 1 : length(detstruct)
    detstruct(i).xav = [] ;
    detstruct(i).yav = [] ;
    detstruct(i).detids = [] ;
    detstruct(i).edids = [] ;
    for j = 1 : length(detstruct(i).nextdets)
        if (detstruct(i).xvel(j) == 0) & (detstruct(i).yvel(j) == 0)
            continue ;
        end
        nd = detstruct(i).nextdets(j) ;
        ed = detstruct(i).edgenum(j) ;
        xav = ( detstruct(i).xvel(j) + detstruct(nd).xvel ) / 2 ;
        yav = ( detstruct(i).yvel(j) + detstruct(nd).yvel ) / 2 ;
        
        if ~normdiff
            nm = sqrt( xav.^2 + yav.^2 ) ;
            xav = xav ./ nm ;
            yav = yav ./ nm ;
        end
            
        len = length(xav) ;
        
        detstruct(i).detids = [detstruct(i).detids nd*ones(1,len)] ;
        detstruct(i).xav = [detstruct(i).xav xav] ;
        detstruct(i).yav = [detstruct(i).yav yav] ;
        detstruct(i).edids = [detstruct(i).edids [ed*ones(1,len); detstruct(nd).edgenum]] ;
    end
end

vecs = [] ;
vecval = [] ;
tic ;

% Now for the final term computation.
for i = firstdets+1 : length(detstruct)
    for j = 1 : length(detstruct(i).xav)
        if ( detstruct(i).xav(j) == 0 ) & ( detstruct(i).yav(j) == 0 )
            continue ;
        end
        if toc > 10
            fprintf( 'In term %d/%d %d/%d Terms added %d\n', i, length(detstruct), j, length(detstruct(i).xav), size(vecs, 2) ) ;
            tic ;
        end
        nd = detstruct(i).detids(j) ;
        if isempty( detstruct(nd).edids )
            continue ;
        end
        selidx = find( detstruct(i).edids(2,j) == detstruct(nd).edids(1,:) ) ;
        if normdiff
            veldiff = sqrt( (detstruct(i).xav(j) - detstruct(nd).xav(selidx)).^2 + (detstruct(i).yav(j) - detstruct(nd).yav(selidx)).^2 ) ;
        else
            veldiff = acos( detstruct(i).xav(j) * detstruct(nd).xav(selidx) + detstruct(i).yav(j) * detstruct(nd).yav(selidx) ) ;
        end
        
        idx = find( veldiff < 0.1 ) ;
        if isempty(idx)
            continue ;
        end
        len = length(idx) ;
        vecs = [vecs [detstruct(i).edids(1, j) * ones(1, len); detstruct(i).edids(2, j) *ones(1, len); detstruct(nd).edids(:, selidx(idx))]] ;
        vecval = [vecval veldiff(idx)] ;
    end
end

fprintf( 'Length of vectors chosen turns out to be %d\n', length(vecval) ) ;
keyboard ;
[A, b, edge_npairs] = composeRelaxationTriConstraints( vecs([1 2 4], :)', nvars ) ;
edge_velocity = -exp( -vecval/5 ) ;


% Very simple matrix, but created for debugging purposes. And also used to augment ytilde.
Q_data = zeros( length(vecval), 3 ) ;
% assert(size(edge_negpairs, 1) == edge_nnegpairs)
Q_data(:, 1) = vecs(1, :)' ;
Q_data(:, 2) = vecs(2, :)' ;
Q_data(:, 3) = vecs(4, :)' ;
% Q_data(:, 4) = allEdges(idx, 4) ;
Q_data(:, 4) = edge_velocity ;

% Q = sptensor( Q_data(:, 1:4), Q_data(:, 5), [nvarq nvarq nvarq nvarq] ) ;
Q = sptensor( Q_data(:, 1:3), Q_data(:, 4), [nvarq nvarq nvarq] ) ;




