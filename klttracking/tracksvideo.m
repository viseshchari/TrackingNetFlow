function tracksvideo(mediainfo, readframe, output_folder, frames, thresh, chunk_size)

if nargin < 5, thresh = -1.1; end
if nargin < 6, chunk_size = 100; end

% if frames = -1 then treat whole video
if frames == -1
    s1 = 1;
    s2 = round(info.duration * info.fps / 1000);
else
    s1 = frames(1);
    s2 = frames(2);
end

debug = false;

videoName         = mediainfo.name;
videoString       = sprintf('%s_%07d_%07d', videoName, s1, s2);
datadir           = fullfile(output_folder, videoName);
shotfname         = fullfile(datadir, [videoString '_shots.txt']);
fullvideo         = fullfile(datadir, [videoString '_tracks_full.webm']);

[fullpipef, fulltmpfile] = write_webm_start(fullvideo);

shots = read_shots(shotfname);
for shot = 1:size(shots, 2)
    s1 = shots(1, shot);
    s2 = shots(2, shot);
    shotString = sprintf('%s_%07d_%07d', videoName, s1, s2);

    imgs_frames = s1:s2;

    proctrackfname = fullfile(datadir, [shotString '_processedtracks.txt']);

    if exist(proctrackfname, 'file')
        tracks = readtracks(proctrackfname);
    else
        tracks = [];
    end


    if ~isempty(tracks)
        if isfield(tracks(1),'track')
            ids = [tracks(:).track];
        else
            ids = 1:length(tracks);
        end
        frames = [tracks(:).frame];
    else
        ids = [];
        frames = [];
    end

    uids = unique(ids);
    colors = rand(length(uids), 3);

    videofile = [datadir '/' shotString '_tracks.webm'];
    fprintf('Writing tracks video for shot %d, frames %d-%d to %s\n', shot, s1, s2, videofile);
    [pipef, tmpfile] = write_webm_start(videofile);
    tic
    for chunk_start = 1:chunk_size:length(imgs_frames)
        chunk_end = min(chunk_start + chunk_size - 1, length(imgs_frames));
        chunk_frames = chunk_start:chunk_end;
        imgs = readframes(mediainfo, readframe, s1 + chunk_frames - 1);
        im = color(im2double(imgs{1}));
        vidframes = uint8(zeros([size(im), length(chunk_frames)]));
        for i = chunk_start:chunk_end
            f = imgs_frames(i);
            ind = find(frames == f);
            im = color(im2double(imgs{i - chunk_start + 1}));
            for j = ind
                det = tracks(j);
                id = ids(j);
                if isfield(det,'trackconf')
                    trackconf = det.trackconf;
                else
                    trackconf = det.conf;
                end
                if trackconf < thresh
                    continue;
                end
                rect = round(det.rect);
                im = draw_rectangle_on_image(im, rect(1), rect(2), rect(3), rect(4), colors(find(uids == id),:));
            end
            vidframes(:,:,:, i - chunk_start + 1) = uint8(255*im);
        end
        write_webm_chunk_double(pipef, fullpipef, tmpfile, vidframes);
    end
    write_webm_end(pipef, tmpfile);
    toc
end
write_webm_end(fullpipef, fulltmpfile);
