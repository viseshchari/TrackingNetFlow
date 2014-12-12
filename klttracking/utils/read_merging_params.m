function s = read_merging_params()

platt_f     = '/meleze/data0/tracking/data/platt-calibration-faces.txt';
platt_ub    = '/meleze/data0/tracking/data/platt-calibration-upperbody.txt';
warp        = '/meleze/data1/bojanows/thesis/tracking/warp-faces-ub.txt';

X = read_warp(warp);
[a_f,b_f] = read_platt(platt_f);
[a_ub,b_ub] = read_platt(platt_ub);

s = struct();

face = struct();
face.platt = [a_f,b_f];
face.warp = X;

ub = struct();
ub.platt = [a_ub,b_ub];

s.face = face;
s.ub = ub;

end
