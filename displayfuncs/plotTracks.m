function colrs = plotTracks( dresypred, trno, showcoords, colrs, figval, im )
% function plotTracks( dresypred, trno, showcoords, im )

if (nargin < 2) | isempty(trno)
    trno = 1:max(dresypred.id) ;
end

if nargin < 3
	showcoords = 0 ;
end

if nargin < 4
    colrs = [] ;
end

if nargin < 5
    figval = 1 ;
end

figure(figval) ; 
if nargin == 6
	imshow(im) ;
end
hold on ;

if isempty(colrs)
    colrs = rand( max(dresypred.id), 3 ) ;
end

if isfield( dresypred, 'clr' )
    maxval = -min( dresypred.clr ) ;
end

for j = 1:length(trno)
    i = trno(j) ;
	idx = find( dresypred.id == i ) ; 
    if isempty(idx)
        continue ; % track does not exist so what is the point
    end    
    idxfirst = find( (dresypred.id == i) & (dresypred.fr == min( dresypred.fr(idx) )) ) ;
    xfirst = dresypred.x(idxfirst)+dresypred.w(idxfirst)/2 ;
    yfirst = dresypred.y(idxfirst)+dresypred.h(idxfirst)/2 ;
	x = dresypred.x(idx)+dresypred.w(idx)/2 ;
	y = dresypred.y(idx)+dresypred.h(idx)/2 ;
    mfirst = plot( xfirst, yfirst, 'k*' ) ;
	l = plot( x, y, 'b-') ;
    set(l, 'linewidth', 2) ;
	if isfield(dresypred, 'vx')  
		l2 = line( [x x+dresypred.vx(idx)]', [y y+dresypred.vy(idx)]' ) ;
		set(l2, 'color', 'r') ;
    end
    if ~isfield( dresypred, 'clr' )
        set(l, 'color', colrs(i, :), 'linewidth', 2 ) ;
    else
        idxtmp = find( dresypred.clr(idx) < 0 ) ;
        for k = 1 : length(idxtmp)
            ltmp = line( [x(idxtmp(k))';x(idxtmp(k)+1)'], [y(idxtmp(k))';y(idxtmp(k)+1)'] ) ;
            set(ltmp, 'color', [1 0 0] * -dresypred.clr(idx(idxtmp(k)))/10, 'linewidth', 3) ;
        end
    end
%     elseif dresypred.clr(idxfirst) == -1
%         set(l, 'color', [0 0 1], 'linewidth', 3 ) ;
%     else
%         set(l, 'color', [1 0 0], 'linewidth', 3 ) ;
%     end
    set(mfirst, 'markersize', 10) ;

	if showcoords
		for j = 1 : length(idx)
			text( x((j))+0.5, y((j))+0.5, sprintf('(%d,%d)', i, dresypred.fr(idx(j)))) ;
		end
	end
end

axis ij ; % because xy axis is different from image axis. And we want to plot in image axis.
return ;

% % code that could be used to visualize the edge pairs in tracks that have been selected.
% 
% plotTracks( dresnew ) ; hold on ;
% idx = find( STATS.yhatcell{1}(param.Q_data(:,1)).*STATS.yhatcell{1}(param.Q_data(:,2)) ) ;
% e1 = param.Q_data(idx, 1) ;
% e2 = param.Q_data(idx, 2) ;
% xscent = [param.xs(:,1)+param.xs(:,3) param.xs(:,2)+param.xs(:,4)]/2 ;
% xs1 = xscent(edge_xi(e1), :) ;
% xs2 = xscent(edge_xi(e2), :) ;
% vec = xscent(param.edge_xj, :) - xscent(param.edge_xi, :) ;
% vec1 = vec(e1, :) ;
% vec2 = vec(e2, :) ;
% l1 = line( [xs1(:,1) xs1(:,1)+vec1(:,1)]', [xs1(:,2) xs1(:,2)+vec1(:,2)]' ) ;
% set(l1, 'color', 'r', 'linewidth', 2 ) ;
% l2 = line( [xs2(:,1) xs2(:,1)+vec2(:,1)]', [xs2(:,2) xs2(:,2)+vec2(:,2)]' ) ;
% set(l2, 'color', 'b', 'linewidth', 2);