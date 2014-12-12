function dres = convert_detections_to_dres( detections, frids, Amats )
% function dres = convert_detections_to_dres( detections, frids, Amats )

dres.x = detections(:, 1) ;
dres.y = detections(:, 2) ;
dres.w = detections(:, 3) - detections(:, 1) ;
dres.h = detections(:, 4) - detections(:, 2) ;
dres.fr = frids ;
dres.r = detections(:, end) ;


cumdets = 0 ;
tic ;
for i = 1 : length(Amats)
	idx = find( Amats{i}(:) > 0 ) ;
	[rw, cl] = ind2sub( size(Amats{i}), idx ) ;
	if toc > 2
		fprintf( 'Processing shot %d\n', i ) ;
		tic ;
	end
	for j = 1 : size(Amats{i}, 1)
		idxtmp = find( rw == j ) ;
		dres.nei(j+cumdets).ind = cl(idxtmp) + cumdets ;
		dres.nei(j+cumdets).val = Amats{i}(idx(idxtmp)) ;
		dres.nei(j+cumdets).lenind = length(idxtmp) ;
	end
	cumdets = cumdets + size(Amats{i}, 1) ;
end