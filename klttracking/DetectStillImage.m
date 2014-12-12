function bbox = DetectStillImage(   img , ...
                                    frame , ...
                                    pffubfmodel_path , ...
                                    facemodel_path , ...
                                    merging_params , ...
                                    fid_faces , ...
                                    fid_ub , ...
                                    verbose )
% runs upper body detector and optionally a opencv face detector on an image,
% face detection are regressed to the upper body detector coordinate frame using prelearned parameters
% Input:
% fullimgpath - relative/absolute path to an image
% ubfmodel_path - relative/absolute path to the pretrained upper body part-based model
% facemodel_path - (optional) relative/absolute path to the pretrained opencv face model (xml file)
%                  if [] then skip face detection
% verbose - 0 - no output
%         - 1 - print on screen
%         - 2 - show images
% Output:
% bbox(i,:)= [x1 y1 x2 y2 score] set of detections

    if nargin < 6
        fid_faces = [];
    end
    if nargin < 7
        fid_ub = [];
    end
    if nargin < 8
        verbose = 1;
    end


    %%% loading the pedro felzenshwalb model
	%%%% Don't need this part.
	%%%% Modified by Visesh Chari, May10th 2013
    %%%% pffmodel = load(pffubfmodel_path);
    %%%% pffmodel = pffmodel.model;


    %%% upper body detection %%%%%%%%%%%%%%%%%
    threshold   = -1.5;
    tic;

	%%%%%%%% Modified, Visesh Chari, May 10 2013 %%%%%%%%
    % parts       = detect( img , pffmodel , threshold ); % DPM for upperbody
    fprintf('\tdetecting UB took %5.2fs...\n',toc);
    % ubox        = getboxes( pffmodel , parts ); % getting the bbox given the parts
	ubox = load( sprintf( pffubfmodel_path, frame ) ) ;
	ubox = ubox.bxs ;
	wtmp = ubox(:,3) - ubox(:,1) ;
	htmp = ubox(:,4) - ubox(:,2) ;
	% ubox(:,1) = ubox(:,1) + wtmp/3 ;
	% ubox(:,2) = ubox(:,2) + htmp/4 ;
	% ubox(:,3) = ubox(:,3) - wtmp/3 ;
	% ubox(:,4) = ubox(:,4) - htmp/4 ;
	%ubox(:,5) = 1.0 ;
	idx = find( ubox(:, end) >= -0.9 ) ;
	ubox = ubox(idx, :) ;
	%% idx = find( ( ( ubox(:, 4) - ubox(:, 2) ) > 30 ) & ( ( ubox(:, 3) - ubox(:, 1) ) > 30 ) ) ;
	%% ubox = ubox(idx, :) ;
	if size(ubox,2) > 4
		ubox = ubox(:, [1:4 end]) ;
	else
		ubox = [ubox(:, [1:4]) ones(size(ubox,1),1)] ;
	end
	% idx = find( ( ( ubox(:, 4) - ubox(:, 2) ) <100 ) & ( ( ubox(:, 3) - ubox(:, 1) ) < 100 ) ) ;
	% ubox = ubox(idx, :) ;
	% idx = find( ubox(:, end) > -1.05 ) ; % This is probably for 879
	% idx = find( ubox(:, end) > -0.85 ) ;
	% ubox = ubox(idx, :) ;
	% ubox(:, 1:4) = ubox(:, 1:4) * 1.7778 ; %%% ONLY FOR SCENE7
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	%%%%% Modified by Visesh Chari, May 10 2013
    %%%%% if ~isempty(ubox)
    %%%%%     ab = merging_params.ub.platt;

    %%%%%     % making the upperbody bbox 50% bigger
    %%%%%     box = ubox(:,1:4);
    %%%%%     h = box(:,4)-box(:,2);
    %%%%%     box(:,4) = box(:,4)+h/2;

    %%%%%     % making the scores comparable using the calibration
    %%%%%     s = ubox(:,end);
    %%%%%     s = platt(s,ab);

    %%%%%     ubox = [box,s];
    %%%%%     idx = s>0.5;
    %%%%%     ubox = ubox(idx,:);

    %%%%%     if ~isempty(fid_ub)
    %%%%%         fprintf(fid_ub,'% 4d % 7.1f % 7.1f % 7.1f % 7.1f % 5.3f\n',[frame*ones(size(ubox,1),1) ubox]');
    %%%%%     end

    %%%%%     ubox = me_iou_nms( ubox , 0.3 );

    %%%%% end


    if verbose
        fprintf('\t%d upper bodies detected...\n',size(ubox,1));
    end


    bbox = ubox;

    %%% face_detection %%%%%%%%%%%%%%%%%%%%%%%
    if isempty(facemodel_path)
        return
    end

    facemodel = load(facemodel_path);

    threshold = -0.8;
    [fbox, pose] = detectFaces(color(img), facemodel,  threshold);
    fprintf('\tdetecting faces took %5.2fs...\n',toc);

    if ~isempty(fbox)

        ab  = merging_params.face.platt;
        W   = merging_params.face.warp;

        s = fbox(:,end);
        s = platt(s,ab);
        idx = s>0.5;
        fbox(:,end) = s;

        fbox = fbox(idx,:);

        if ~isempty(fid_faces)
            fprintf(fid_faces,'% 4d % 7.1f % 7.1f % 7.1f % 7.1f % 5.3f\n',[frame*ones(size(fbox,1),1) fbox]');
        end

        box = fbox(:,1:4);
        box = box*W;
        fbox(:,1:4) = box;

    end

    bbox = [bbox;fbox];

    bbox = me_iou_nms(bbox,0.3);

    if verbose
        fprintf('\t%d faces detected...\n',size(fbox,1));
        fprintf('\t%d detections kept after non-maximal suppression\n',size(bbox,1));
    end
end
