function [trclen, trcdists] = visualizetracks( tracks, fig1, fig2 )
% function visualizetracks( tracks )

if nargin < 2
	;
else
	figure(fig1) ; clf ;
end

trcs = [tracks.track] ;
frames = [tracks.frame] ;
etrcs = 0 ;
septhresh = 3 ;
fprintf( '%d\n', max(trcs) ) ;

trclen = [] ;
trcdists = [] ;
nfulltrcks = 0 ;

for i = 1 : max(trcs)
	idx = find( trcs == i ) ;

	% Now find frames that belong to these numbers
	frms = frames(idx)  ;
	if isempty(frms)
		etrcs = etrcs + 1 ;
		continue ;
	end
	idx = find( abs(frms(2:end)-frms(1:(end-1))) > 1 ) ;

	if ~isempty(idx)
		nfulltrcks = nfulltrcks + 1 ;
	end
	
	trcdists = [trcdists frms(idx+1)-frms(idx)-1] ;
	idx = [0 idx length(frms)] ;
	trclen = [trclen length(frms)] ;

	% x = plot( frms, i*septhresh*ones(1,length(frms)), 'b.') ;
	if nargin < 2
		;
	else
		x = line( [frms(idx(1:(end-1))+1)' frms(idx(2:end))']', [i*septhresh*ones(length(idx)-1,1) i*septhresh*ones(length(idx)-1,1)]' ) ;
		set(x, 'linewidth', 2, 'color', 'b' ) ;
	end
end

fprintf( 'New Empty Tracks %d %d\n', etrcs, nfulltrcks ) ;

if nargin < 2
	;
else
	figure(fig2) ; clf ;
	plot( sort(trclen), 'r' ) ;
end
