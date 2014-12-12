function check_id_continuity( dres )
% function check_id_continuity( dres )

maxtrcks = max( dres.id ) ;
allcln = 1 ;

for i = 1 : maxtrcks
	idx = find( dres.id == i ) ;
	if abs( idx(2:end) - idx(1:(end-1)) ) > 1
		sprintf( 'Track %d not continuous', i ) ;
		 allcln = 0 ;
	end
end

if allcln
	disp('No discontinous tracks!') ;
end