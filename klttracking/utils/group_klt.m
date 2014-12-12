function dets = group_klt(dets, s1, s2, klt_mask, datadir, mediainfo, readframe)
    if isempty(dets), return; end

    klt_path = [datadir '/' 'klt'];
    klt_dist_path = [datadir '/' 'klt_dist'];

    if ~exist(klt_path, 'file'), mkdir(klt_path); end
    if ~exist(klt_dist_path, 'file'), mkdir(klt_dist_path); end

    fdf = [dets.frame];
	padsz = 500 ;
	for tmp = 1 : length(dets), dets(tmp).rect = dets(tmp).rect + padsz; end ;

    for step = [1, -1]
        if step == 1
            f1 = s1;
            f2 = s2;
        else
            f1 = s2;
            f2 = s1;
        end

        trkpath = [klt_path '/' sprintf('%06d-%06d_%d.mat', s1, s2, step)];

        if exist(trkpath, 'file')
            continue
        end

        tc  = klt_init('nfeats', 5000,...
                       'mindisp', 0.1,...
			'winsize', 5,...
			'smooth_sigma_factor', 1.0,...
                       'pyramid_levels', 2,...
                       'mineigval', 1/(255^6),...
                       'mindist', 7);
        K   = zeros(3, tc.nfeats, max(f1, f2) - min(f1, f2) + 1, 'single');
		disp('initializing') ;

        f = f1;

        % reading frame
		I = single(rgb2gray(imageread(mediainfo, f)))/255;
		I = padarray( I, [padsz padsz], 'both' ) ;

		M = dets_to_mask(dets, f, I, klt_mask);

		[tc, P] = klt_selfeats(tc, I, M);
		K(:, :, f - min(f1, f2) + 1) = P;

        if step == 1
            fprintf('Forward tracking of features\n');
        else
            fprintf('Backward tracking of features\n');
        end
		for f = (f1 + step):step:f2
			fprintf('\tFrame %d in [%d-%d]\r', f, f1, f2);

				% reading frame
			I = single(rgb2gray(imageread(mediainfo, f))) / 255;
			I = padarray( I, [padsz padsz], 'both' ) ;

			M = dets_to_mask(dets, f, I, klt_mask);

			[tc, P] = klt_track(tc, P, I, []); % use mask here ?
			if f ~= f2
				[tc, P] = klt_selfeats(tc, I, M, P);
			end
			K(:,:,f - min(f1, f2) + 1) = P;
		end
		fprintf('\n');

		save(trkpath, 'K');
    end

    trkpathF = [klt_path '/' sprintf('%06d-%06d_1.mat', s1, s2)];
    trkpathB = [klt_path '/' sprintf('%06d-%06d_-1.mat', s1, s2)];
    distpath = [klt_dist_path '/' sprintf('%06d-%06d.mat', s1, s2)];
    distpath

    if ~exist(distpath,'file')
        load(trkpathF, 'K');
        [TX, TY] = klt_parse_sparse(K);

        load(trkpathB, 'K');
        K = K(:, :, end:-1:1);
        [TXb, TYb] = klt_parse_sparse(K);
        TXb = TXb(end:-1:1, :);
        TYb = TYb(end:-1:1, :);
        TX = [TX TXb];
        TY = [TY TYb];

        FeatInBox = zeros(size(TX, 2), length(fdf)); % num features x num frames
        FeatInFrame = zeros(size(TX, 2), length(fdf));
        % FeatInBox2 = zeros(size(TX,2), length(fdf));
        % FeatInFrame2 = zeros(size(TX,2), length(fdf));
        FeatInBox = logical(FeatInBox);
        FeatInFrame = logical(FeatInFrame);
        % FeatInBox2 = logical(FeatInBox2);
        % FeatInFrame2 = logical(FeatInFrame2); 
        tic;
        fprintf('Associating klt tracks with detections\n');
        % Now if the size of the detections are not that big.
        allfrnms = int16(cat(1, dets.frame)) ;
        allrects = cat(1, dets.rect) ;
        FeatMinX = repmat( allrects(:,1)', size(TX,2), 1 ) ;
        FeatMinY = repmat( allrects(:,2)', size(TX,2), 1 ) ;
        FeatMaxX = repmat( allrects(:,3)', size(TX,2), 1 ) ;
        FeatMaxY = repmat( allrects(:,4)', size(TX,2), 1 ) ;
        
        tx = zeros( size(TX,2), length(fdf) ) ;
        ty = zeros( size(TX,2), length(fdf) ) ;
        num_frames = max(allfrnms) - s1 + 1 ;
        % keyboard ;

        for i = 1 : num_frames
           % Consider all the dets in the current frame,
           if toc > 1 || i == length(dets)
                fprintf('\tDetection %d/%d\r', i, num_frames);
                tic;
           end
           idx = find( allfrnms == (i-1+s1) ) ;
           [i size(tx) size(TX)]
           tx(:, idx) = kron( TX(i,:), ones(length(idx),1) )' ;
           ty(:, idx) = kron( TY(i,:), ones(length(idx),1) )' ;
           in_box = tx(:, idx) > 0 & ...
                    tx(:, idx) >= FeatMinX(:, idx) & ...
                    tx(:, idx) <= FeatMaxX(:, idx) & ...
                    ty(:, idx) >= FeatMinY(:, idx) & ...
                    ty(:, idx) <= FeatMaxY(:, idx) ;
           in_f = tx(:, idx) > 0 ;
           FeatInFrame(:, idx) = in_f ;
           FeatInBox(:, idx) = in_box ;
        end

        % for i = 1:length(dets)
        %     if toc > 1 || i == length(dets)
        %         fprintf('\tDetection %d/%d\r', i, length(fdf));
        %         tic;
        %     end
        %     fa = dets(i).frame;
        %     bba = dets(i).rect;
        %     in_box = TX(fa - s1 + 1, :) > 0 &...
        %              TX(fa - s1 + 1, :) >= bba(1) &...
        %              TX(fa - s1 + 1, :) <= bba(3) &...
        %              TY(fa - s1 + 1, :) >= bba(2) &...
        %              TY(fa - s1 + 1, :) <= bba(4);
        %     in_f = TX(fa - s1 + 1, :) > 0;
        %     FeatInFrame(:, i) = in_f';
        %     FeatInBox(:, i) = in_box';
        % end
        fprintf('Done with detections %d %d\n', length(dets), size(allfrnms,1));

        C = single(zeros(length(dets))); % similarity matrix
        NI = int16(zeros(length(dets))); % number of intersecting tracks
        % D = zeros(length(dets));
        
        % C2 = zeros(length(dets));
        % NI2 = zeros(length(dets));
        
        % cmnfrm = logical(zeros(length(dets))) ;
        allfr1 = int16(repmat( allfrnms, 1, length(allfrnms) )) ;
        cmnfrm = logical(allfr1 ~= allfr1') ; % compute whether two detections belong to same frame.
                                    % cmnfrm is a symmetric matrix.
        clear allfr1 ; 
        tic ;
        for i = 1 : size(FeatInBox,1)
            if toc > 1 
                fprintf('\tKLT Intersection %d/%d\r', i, size(FeatInBox,1)) ;
                tic;
            end
            idx1 = find( FeatInBox(i, :) == 1 ) ; % Find all boxes that its present in.
            idx2 = find( FeatInFrame(i, :) == 1 ) ; % Find all frames that its present in. idx2 contains *all* elements in idx1 + more.
            NI(idx1, idx1) = NI(idx1, idx1) + int16(cmnfrm(idx1, idx1)) ; % for different frames this adds one. This line produces
                            % symmetric matrices by design.
            C(idx1, idx2) = C(idx1, idx2) + cmnfrm(idx1, idx2) ;
            C(idx2, idx1) = C(idx2, idx1) + cmnfrm(idx2, idx1) ;
            C(idx1, idx1) = C(idx1, idx1) - cmnfrm(idx1, idx1) ;
        end
        
		clear allfr1 ;
        C = single(NI) ./ C ;
        % C2 = C2 + -Inf * (~cmnfrm) ;
        
         % fprintf('Computing klt tracks intersections\n');
         % d = -inf ;
         % tic ;
         % for i = 1:length(dets)
 
         %     C(i, i) = -inf;
 
         %     for j = 1:i-1
 
         %         if fdf(i) == fdf(j)
         %             c = -inf;
         %             d = -inf ;
         %             ni = 0;
         %         else
         %             ni = sum(FeatInBox(:, i) & FeatInBox(:, j));
         %             % c = full(ni / min(sum(FeatInFrame(:, i) & FeatInFrame(:, j)),sum(FeatInBox(:, i) | FeatInBox(:, j))));
         %             d = sum((FeatInBox(:, i) & FeatInFrame(:, j)) | (FeatInBox(:, j) & FeatInFrame(:, i))) ;
         %             c = full(ni / (sum((FeatInBox(:, i) & FeatInFrame(:, j)) | (FeatInBox(:, j) & FeatInFrame(:, i))))); % correct intersection over union
         %             % c = full(2 * ni / (sum(FeatInBox(:, i)) + sum(FeatInBox(:,j)))) % "dice" measure
         %         end
 
         %         C(i, j) = c;
         %         C(j, i) = c;
         %         D(i, j) = d ;
         %         D(j, i) = d ;
         %         NI(i, j) = ni;
         %         NI(j, i) = ni;
         %     end
 
         %     if toc > 1 || i == numel(dets)
         %         fprintf('\tDetection %d/%d\r', i, numel(dets));
         %         tic;
         %     end
         % end
         % fprintf('\n');

		clear cmnfrm ;
        save(distpath, 'C', 'NI', '-v7.3');
    else
        load(distpath, 'C', 'NI');
    end

    fprintf('Doing Agglomerative clustering, Max Cluster Value %f\n', max(C(:))) ;
    fdf = [dets.frame]';
    FD = repmat(fdf, 1, numel(fdf)) - repmat(fdf', numel(fdf), 1);
    C(~FD) = -inf;
	fprintf('Doing Agglomerative clustering, Max Cluster Value %f\n', max(C(:))) ;
    % C2(~FD) = -inf;
    
%%%    % clus = agglomclus_bkp(C, 0.5);
%%%    fprintf('Agglomerative clustering just done\n') ;
%%%
%%%    nc = 0;
%%%    for i = 1:length(clus)
%%%        nc = nc + 1;
%%%        for j = 1:length(clus{i})
%%%            k = clus{i}(j);
%%%            dets(k).track = nc;
%%%        end
%%%    end
%%%
%%%    for tmp = 1 : length(dets), dets(tmp).rect = dets(tmp).rect - padsz; end ;
%%%    dets = update_tracks_length(dets);
%%%    dets = update_tracks_conf(dets);
