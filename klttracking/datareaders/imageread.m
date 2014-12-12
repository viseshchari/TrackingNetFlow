function im = imagesread(videoinfo, frame)
%%%% Modified by Visesh Chari, May 10 2013
if length(videoinfo.frames) == 3
    frame = videoinfo.start + (frame-1) * videoinfo.stepsz
    im = imread(sprintf(videoinfo.pattern, frame));
else
	sprintf(videoinfo.pattern, videoinfo.frames(frame))
	im = imread(sprintf(videoinfo.pattern, videoinfo.frames(frame))) ;
end
