function tracks = update_tracks_properties(tracks)
    if ~isfield(tracks, 'track')
        return
    end
    ids = cat(1, tracks(:).track);
    uids = unique(ids);
    for i = 1:length(uids)
        ind = find(ids == uids(i));
        conf = cat(1, tracks(ind).conf);
        trackconf = mean(conf(~isinf(conf)));
        if isnan(trackconf) trackconf = -inf; end
        for j = 1:length(ind)
            tracks(ind(j)).trackconf = trackconf;
            tracks(ind(j)).tracklength = length(ind);
        end
    end
