function psi = featureFunctionFlexible( pm, x, y )
% function psi = featureFunctionFlexible( pm, x, y )
% This function computes the feature associated with SSVM.

FS = pm.optstruct.featScale ;

yedgs = double( y( 1:pm.nedgs ) ) ;
ydets = double( y( (pm.nedgs+1):(pm.nedgs+pm.ndets) ) ) ;
xedgs = double( x( 1:pm.nedgs ) ) ;
xdets = double( x( (pm.nedgs+1):(pm.nedgs+pm.ndets) ) ) ;

linrelaxscore = [] ;
if pm.optstruct.separateWeights
    for i = 1 : pm.optstruct.nConstraints
        linrelaxscore = [linrelaxscore; -dot( pm.optstruct.Constraints{i}.Acoeff, y( pm.nvars+1:end ) ) / FS(4+i)] ;
        if pm.optstruct.separateBias
            linrelaxscore = [linrelaxscore; sum( y( pm.nvars+1:end ) ) / FS(4+pm.optstruct.nConstraints+i)] ;
        end
    end
elseif pm.dimension > 4
    linrelaxscore = 0 ;
    for i = 1 : pm.optstruct.nConstraints
        linrelaxscore = linrelaxscore + -dot( pm.optstruct.Constraints{i}.Acoeff, y( pm.nvars+1:end ) ) ;
    end
    linrelaxscore = linrelaxscore / FS(5) ;
    if pm.dimension == 6
        linrelaxscore = [linrelaxscore; sum( y( pm.nvars+1:end ) ) / FS(6)] ;
    end
end

psi = sparse( [
		dot( xedgs, yedgs ) / FS(1) ; ...
		sum( yedgs ) / FS(2) ; ...
		dot( xdets, ydets ) / FS(3) ; ...
		sum( ydets ) / FS(4) ; ...
		linrelaxscore ;
        ] ) ;