function create_cvml( data, filename, resname )
% function create_cvml( data, file )

f = fopen(filename, 'w') ;

data.xc = data.x + data.w / 2 ;
data.yc = data.y + data.h / 2 ;


fprintf( f, '<?xml version="1.0" encoding="utf-8"?>\n' ) ;
fprintf( f, '<result name="%s">\n', resname) ;


for i = min(data.fr) : max(data.fr)
	fprintf( f, '    <frame number="%d">\n', i-1 ) ;
	fprintf( f, '        <objectlist>\n' ) ;
	idx = find( (data.fr==i) & (data.id~=-1) ) ;
	for j = 1 : length(idx)
		fprintf( f, '            <object id="%d">\n', data.id(idx(j)) ) ;
		fprintf( f, '                <box h="%.4f" w="%.4f" xc="%.4f" yc="%.4f"/>\n',...
							data.h(idx(j)), data.w(idx(j)), data.xc(idx(j)), data.yc(idx(j)) ) ;
		fprintf( f, '            </object>\n' ) ;
	end
	fprintf( f, '        </objectlist>\n' ) ;
	fprintf( f, '    </frame>\n' ) ;
end

fprintf( f, '</result>') ;

fclose(f) ;
