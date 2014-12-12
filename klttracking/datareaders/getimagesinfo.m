function info = getimagesinfo(pattern, frames, name, stepsz)
    if nargin < 3, name = strrep(pattern, filesep, '_'); end
	if nargin < 4, stepsz = 5; end 
    info = [];
    info.pattern = pattern;
    info.name = name;
    if frames == -1
        i = 1;
		info.stepsz = stepsz ;
		info.start = 1 ;
        while exist(sprintf(pattern, i), 'file')
            i = i + info.stepsz; %%%%%% Modified, Visesh Chari May 10, 2013
        end
        info.maxframe = i - 1;
	elseif length(frames) == 3
		info.stepsz = frames(3) ;
		info.start = 1 ; 
		info.frames = frames ;
	else
		info.stepsz = 1 ;
		info.start = frames(1) ;
		info.frames = frames ;
    end
end
