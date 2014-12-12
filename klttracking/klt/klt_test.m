function trckednums = klt_test()
% Code to test what are the best values for the klt tracker.

% figure(1);
% clf reset;
% set(gcf,'doublebuffer','on');

% imgpath='c:/temp/bas_%05d.pgm';
% maskpath='c:/temp/basmask_%05d.pgm';

nf = 5000 ;
mdsp = {} ;
wnsz = {} ;
ssg = {} ;
pyl = {} ;
mineig = 1/(255^6) ;
mdst = {} ;
% max value - mdisp(0.1), winsz(5), ssg(5), pyl(2), mdist(7)

for i = [0.1 0.3 0.5 1.0]
	for j = [5 7 9 11]
		for k = [0.1 0.5 2.0 3.0 4.0 5.0]
			for l = [2 3 5] ;
				for m = [3 5 7]
					mdsp = [mdsp i] ;
					wnsz = [wnsz j] ;
					ssg = [ssg k] ;
					pyl = [pyl l] ;
					mdst = [mdst m] ;
				end
			end
		end
	end
end

[length(mdsp) length(wnsz) length(ssg) length(pyl) length(mdst)] 


alltrcked = APT_run( 'klt_trackfeatsapt', {nf}, mdsp, wnsz, ssg, pyl, {mineig}, mdst, ...
				'UseCluster', 1, 'NJobs', 30, 'ClusterID', 1, 'Memory', 3000, 'CombineArgs', 0 ) ;

trckednums = cat(1, alltrcked) ;

