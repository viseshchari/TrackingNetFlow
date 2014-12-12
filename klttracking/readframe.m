function im = readframe( mediainfo, frame )
% function im = readframe( mediainfo, frame )

keyboard ;
if length(frame) == 3
	mediainfo.start + (frame-1) * mediainfo.stepsz
	im = imread( sprintf( mediainfo.pattern, mediainfo.start + (frame-1)*mediainfo.stepsz ) ) ;
else
	im = imread( sprintf( mediainfo.pattern, mediainfo.frames(frame) ) ) ;
end
