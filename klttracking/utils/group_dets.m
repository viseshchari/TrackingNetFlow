function dets = group_dets(dets)
    C = zeros(length(dets), length(dets));
    frames = [dets(:).frame];
    % Exclusion principle : two detections in the same frame can't be combined
    framediff = repmat(frames', 1, numel(frames)) - repmat(frames, numel(frames), 1);
    C(~framediff) = -inf;
    uframes = unique(frames);
    uframes = sort(uframes);
    bboxall = cat(1, dets(:).rect);

    for i = 1:(length(uframes) - 1)
        for j = (i + 1):min(i + 12, length(uframes))
            ind1 = find(frames == uframes(i));
            ind2 = find(frames == uframes(j));
            for k1 = ind1
                for k2 = ind2
                    C(k2, k1) = bboxoverlapval(bboxall(k1,:), bboxall(k2,:));
                    C(k1, k2) = C(k2, k1); % symmetrize
                end
            end
        end
    end
    
    clus = agglomclus(C, 0.6);
    
    nc = 0;
    for i = 1:length(clus)
        nc = nc + 1;
        for j = 1:length(clus{i})
            k = clus{i}(j);
            dets(k).track = nc;
        end
      
        % adjust track length and mean confidence values
        ind = find([dets.track] == nc);
        trackconf = mean([dets(ind).conf]);
        tracklength = length(ind);
        for j = 1:length(ind)
            dets(ind(j)).trackconf = trackconf;
            dets(ind(j)).tracklength = tracklength;
        end
    end
end
