function ims = readframes(mediainfo, readframe, frames)
    ims = cell(1, length(frames));
    for i = 1:length(frames)
        ims{i} = readframe(mediainfo, frames(i));
    end
end
