function info = getvideoinfo(videofname, frames)
    info = mexMediaInfo(videofname);
    info.filename = videofname;
    [~, info.name, ~] = fileparts(info.filename);
    info.maxframe = round(info.duration * info.fps / 1000);
end
