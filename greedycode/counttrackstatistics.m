function [histval, histids] = counttrackstatistics( track, ourtracks )
% function histval = counttrackstatistics( track, ourtracks )

histval = zeros(length(track), 1) ;
histids = zeros(length(track), 1) ;
% maxtr = max( -ourtracks.r ) ;
maxtr = 51 ;
validtr = ones(maxtr, 1) ;
rct = [ourtracks.x ourtracks.y ourtracks.x+ourtracks.w ourtracks.y+ourtracks.h] ;

for i = 1 : length(track)
	trackbxs = computefullgttrack( track{i} ) ;

	ml = 0 ;
	midx = [-1 -1] ;
	fprintf( 'Processing track %d', i ) ;
	
	for j = 1 : maxtr
		idx = find( ourtracks.r == -j ) ;
		ovval = bboxoverlapval(rct(idx, :), trackbxs(:, 1:4)) ;
		[x, smfr] = findsamefrsum( ourtracks.fr(idx), trackbxs(:, 5), ovval ) ;
		if x > ml
			ml = x ;
			midx = [j, smfr] ;
		end
	end
	fprintf( '...Done\n') ;

	histval(i) = midx(2) ;
	histids(i) = midx(1) ;
end

function [nval, nfr] = findsamefrsum( trcks1fr, trcks2fr, ovval )
% function [nval, nfr] = findsamefrsum( trcks1fr, trcks2fr, ovval )
% ovval is of size length(trcks1fr) x length(trcks2fr)

nval = 0 ;
nfr = 0 ;

for i = 1 : length(trcks2fr)
	idx = find( trcks1fr == trcks2fr(i) ) ;
	if ~isempty(idx)
		if ovval(idx, i) > 0.5
			nval = nval + ovval(idx, i) ;
			nfr = nfr + 1 ;
		end
	end
end



function trackbxs = computefullgttrack( trackkey )
% function trackbxs = computefullgttrack( trackkey )

numfr = size(trackkey, 1) ;
trackbxs = [] ;
tx = [] ;
ty = [] ;
tw = [] ;
th = [] ;
tf = [] ;

for i = 2 : numfr
	fr1 = trackkey(i-1, 5) ;
	fr2 = trackkey(i, 5) ;

	bx1 = trackkey(i-1, 1:4) ;
	bx2 = trackkey(i, 1:4) ;

	alphas = 0 : 1 / (fr2-fr1) : 1 ;

	tx = [tx bx1(1) * (1-alphas) + bx2(1) * alphas] ;
	ty = [ty bx1(2) * (1-alphas) + bx2(2) * alphas] ;
	tw = [tw bx1(3) * (1-alphas) + bx2(3) * alphas] ;
	th = [th bx1(4) * (1-alphas) + bx2(4) * alphas] ;
	tf = [tf fr1:fr2] ;
end

trackbxs = [tx; ty; tx+tw; ty+th; tf]' ;
