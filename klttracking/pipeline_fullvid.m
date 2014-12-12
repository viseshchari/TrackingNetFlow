function pipeline_fullvid(mediainfo, readframe, detector, output_folder, frames, klt_tracking, conf_thresh, klt_mask)
% function pipeline_fullvid(mediainfo, readframe, detector, output_folder, frames, klt_tracking, conf_thresh, klt_mask)

if nargin < 7, conf_thresh = -0.9; end
if nargin < 8, klt_mask = []; end

chunk_size = 60;

% if frames = -1 then treat whole video
if frames == -1
    s1 = 1;
    s2 = mediainfo.maxframe;
else
	if length(frames) == 3
		s1 = frames(1);
		s2 = frames(2);
	else
		s1 = 1;
		s2 = length(frames) ;
	end
end
imgs_frames = s1:s2;

if isdeployed, maxNumCompThreads(1); end

videoName         = mediainfo.name;
videoString       = sprintf('%s_%07d_%07d', videoName, s1, s2);
datadir           = fullfile(output_folder, videoName);
fprintf('Processing video %s, producing results in %s\n', videoName, datadir);

if ~exist(datadir, 'file')
    mkdir(datadir);
end

%%% SHOT DETECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
shotfname       = fullfile(datadir, [videoString '_shots.txt']);
if ~exist(shotfname, 'file')
    fprintf('Detecting shots\n');
    shots      = s1

    for chunk_start = s1:(chunk_size - 2):s2
        chunk_end = min(chunk_start + chunk_size - 1, s2);
        fprintf('Loading frames from %d to %d...\n', chunk_start, chunk_end);

        chunk_frames = chunk_start:chunk_end
        imgs = readframes(mediainfo, readframe, chunk_frames);

        % getting the shot changes
		if length(frames) > 3
			shot_change = find( (frames(chunk_frames(2:end))-frames(chunk_frames(1:end-1))) > 1 ) ;
			shots       = [shots, chunk_frames(shot_change)+1];
			shots		= [shots, chunk_end+1] ;
		else
        	B           = cell2mat(cellfun(@(x) histc(x(:), 0:255), imgs, 'UniformOutput', false));
        	shot_change = find( sum(abs(diff(B, 1, 2)), 1) > 1.03 * mean(sum(abs(diff(B, 1, 2)), 1)) )
			if ~isempty(shot_change)
				shots       = [shots, chunk_frames(shot_change(1))+1];
				keyboard ;
			end
		end
    end

    shots(end+1) = s2 + 1; % Hack : add lastframe+1 as a shot starting frame
    shots = unique(shots) ;
    %%%% % rewrite shots to read as S(1,i) = start frame / S(2,i) = end frame for shot i
    %%%% shots = [shots(1:end-1) ; shots(2:end) - 1]
	%%%% idx = find( ( shots(2, :) - shots(1, :) ) < 20 ) ;
	%%%% shots(1, idx+1) = shots(2, idx-1) + 1 ;
	%%%% shots(:, idx) = [] ;
	%%%% idx = find( ( shots(2, :) - shots(1, :) ) > 30 ) ;
	%%%% for i = length(idx) : -1 : 1
	%%%% 	val = shots(2, idx(i))-shots(1, idx(i)) ;
	%%%% 	tmp = [] ;
	%%%% 	curr = shots(1, idx(i)) ;
	%%%% 	while( (val/30) > 1.0 )
	%%%% 		tmp = [tmp [curr; curr+30]] ;
	%%%% 		curr = curr + 31 ;
	%%%% 		val = val - 30 ;
	%%%% 	end
	%%%% 	shots(:, idx(i)) = tmp ;
	%%%% end

	%%% Shots need to be computed every 10 frames. Works better for 
	%%% this set of videos.
	shots = [] ;
	for tmp = 1:10:s2
		if tmp == s2
			continue ;
		end
		shots = [shots [tmp;min(tmp+15,s2)]] ;
	end
	shots(end) = s2 ;
	write_shots(shots, shotfname);
end

shots = read_shots(shotfname);
ln = length(shots) ;
if size(shots, 2) == 1
	shots = [shots [0;0]] ;
	ln = 1 ;
end

for shot = 1:ln
    s1 = shots(1, shot);
    s2 = shots(2, shot);
    shotString = sprintf('%s_%07d_%07d', videoName, s1, s2);
    fprintf('Processing shot %d with frames %d-%d\n', shot, s1, s2);

    %%% DETECTION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    detfname        = fullfile(datadir, [shotString '_dets.txt']);

    if ~exist(detfname, 'file')
        det       = [];
        fprintf('Computing detections\n');

        for chunk_start = s1:chunk_size:s2
			s2
            chunk_end = min(chunk_start + chunk_size - 1, s2)
			if chunk_start > s2
				keyboard ;
			end
            imgs = readframes(mediainfo, readframe, chunk_start:chunk_end);

            for f = chunk_start:chunk_end
                fprintf('\tFrame %d in [%d,%d]\r', f, s1, s2);

                bbs = detector(mediainfo, imgs{f - chunk_start + 1}, f);

                % get the number of detections
                [n , ~] = size(bbs);

                for j = 1:n
                    det(end + 1).frame = f;
                    det(end).conf      = bbs(j, end);
                    det(end).rect      = bbs(j, 1:4);
                end
            end
        end
        fprintf('\n');

        writetracks(det, detfname);
    end

%%%% %%%%% New code for parallelizing starts from here
%%%% end
%%%% 
%%%% s1 = {} ;
%%%% s2 = {} ;
%%%% dets = {} ;
%%%% startshot = 0 ;
%%%% for shot = 1:ln
%%%% 	s1{shot-startshot} = shots(1, shot) ;
%%%% 	s2{shot-startshot} = shots(2, shot) ;
%%%% 	shotString = sprintf('%s_%07d_%07d', videoName, s1{shot-startshot}, s2{shot-startshot});
%%%% 	detfname = [datadir '/' shotString '_dets.txt']; 
%%%% 	detfname
%%%% 	dets{shot-startshot} = readtracks(detfname) ;
%%%% 
%%%% 	if ~rem(shot, 15)
%%%% 		tracks = APT_run( 'group_klt', dets, s1, s2, {klt_mask}, {datadir}, {mediainfo}, ...
%%%% 					'UseCluster', 1, 'NJobs', 15, 'ClusterID', 2, 'Memory', 27000 ) ;
%%%% 
%%%% 		for st = (startshot+1):shot
%%%% 			shotString = sprintf('%s_%07d_%07d', videoName, s1{st-startshot}, s2{st-startshot});
%%%% 			trackfname = fullfile(datadir, [shotString '_tracks.txt']) ;
%%%% 		
%%%% 			if ~exist(trackfname, 'file') && exist(detfname, 'file')
%%%% 				writetracks(tracks{st-startshot},trackfname);
%%%% 			end
%%%% 		end
%%%% 		startshot = shot ;
%%%% 		s1 = {} ;
%%%% 		s2 = {} ;
%%%% 		dets = {} ;
%%%% 	end
%%%% end
%%%% 		
%%%% tracks = APT_run( 'group_klt', dets, s1, s2, {klt_mask}, {datadir}, {mediainfo}, ...
%%%% 			'UseCluster', 1, 'NJobs', 5, 'ClusterID', 2, 'Memory', 27000 ) ;
%%%% 
%%%% for st = (startshot+1):shot
%%%% 	shotString = sprintf('%s_%07d_%07d', videoName, s1{st-startshot}, s2{st-startshot});
%%%% 	trackfname = fullfile(datadir, [shotString '_tracks.txt']) ;
%%%% 
%%%% 	if ~exist(trackfname, 'file') && exist(detfname, 'file')
%%%% 		writetracks(tracks{st-startshot},trackfname);
%%%% 	end
%%%% end

%%%%%
%%%%% IF USING APT, COMMENT LINES STARTING FROM HERE
    %%% ACTUAL TRACKING CODE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    trackfname = fullfile(datadir, [shotString '_tracks.txt']);

    if ~exist(trackfname, 'file') && exist(detfname, 'file')
        % read saved detections
        detfname = [datadir '/' shotString '_dets.txt'];
        det      = readtracks(detfname);

        % idx = [det.conf] > conf_thresh;
        % det = det(idx);

        fprintf('Tracking start: read %d detections from %s\n', length(det), detfname);

        if klt_tracking % use KLT tracker
            tracks = group_klt(det, s1, s2, klt_mask, datadir, mediainfo, readframe);
        else            % track bounding boxes
            tracks = group_dets(det);
        end

        % write tracks to file
        writetracks(tracks,trackfname);
    end

     %%% POST-PROCESSING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     proctrackfname = fullfile(datadir, [shotString '_processedtracks.txt']);

     if ~exist(proctrackfname, 'file') && exist(trackfname, 'file')
         % read saved tracks
         trackfname = [datadir '/' shotString '_tracks.txt'];
         tracks = readtracks(trackfname);

         fprintf('Post-processing start: read %d tracks with %d detections from %s\n', length(unique([tracks.track])), length(tracks), trackfname);

         % process tracks
         proctracks = processtracks(tracks);

         % write processed tracks to file
         writetracks(proctracks, proctrackfname);
     end
end
%%%%% TO HERE // IF USING APT, COMMENT TILL HERE
