function X = read_warp(path)

fid = fopen(path);

X = cell2mat(textscan(fid,'%f %f %f %f','CommentStyle','#'));

fclose(fid);

end