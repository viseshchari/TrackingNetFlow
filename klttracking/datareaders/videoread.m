function im = videoread(videoinfo, frame)
    persistent frames framestart frameend;
    if ~isempty(frames) & framestart <= frame & frame <= frameend
        im = frames{frame - framestart + 1};
    else
        framestart = frame;
        frameend = min(frame + 99, videoinfo.maxframe);
        frames = readvideo(videoinfo.filename, framestart:frameend);
        im = frames{1};
    end
end
