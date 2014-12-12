Copyright (c) 2014 Visesh Chari, Simon-Lacoste Julien, Ivan Laptev, Josef Sivic.

LICENSING TERMS

This program is granted free of charge for non-commercial research and
education purposes. However you must obtain a license from the author
to use it for commercial purposes.

Scientific results produced using the software provided shall
acknowledge the use of this code. Please cite as

Visesh Chari, Simon-Lacoste Julien, Ivan Laptev, Josef Sivic
"On Pairwise Cost for Multi-Object Network Flow Tracking"
ArXiv, July, 2014

Moreover shall the author of code be informed about the
publication.

The software and derivatives of the software must not be distributed
without prior permission of the author.

By using this code you agree to the licensing terms.


NO WARRANTY

BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT
WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER
PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE
PROGRAM IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME
THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE PROGRAM, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF
THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO
LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY
OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED
OF THE POSSIBILITY OF SUCH DAMAGES.


----------------------------------------------------------------------------------

OBTAINING:
This code can be downloaded from the following url
	URL:

DEPENDENCIES:
	This code requires the installation of CPLEX. CPLEX is an optimization
	software with license provided FREE FOR ACADEMIC PURPOSES by IBM.
	You can download CPLEX by following this link.

	http://www.ibm.com/developerworks/downloads/ws/ilogcplex/index.html?cmp=dwenu&cpb=dwweb&ct=dwcom&cr=dwcom&ccy=zz

	Check out the IBM Academic initiative to get a free license.

	http://www-304.ibm.com/ibm/university/academic/pub/page/ban_ilog_programming

UNPACKING:
	Unpack the tar file using the command in linux
	> tar -xvzf pairwisecost.tar.gz

	This should create a directory "PairwiseCost" in the folder you execute
	this operation in..

	Move into the folder
	> cd PairwiseCost

	You should see five directories
	> ls
	displayfuncs - codes for displaying
	greedycode - code by Deva et al. for greedy optimization [1]
	scripts - sample scripts for running the entire optimization
	utils - utility functions
	utilsopt - utility functions for the optimization

COMPILING:

	Open MATLAB, and go to the "PairwiseCost" folder.
	First run
	> pathadd

	This should add all the required paths to your PATH variable in MATLAB.
	
	Compile using the command
	> make

	This should compile the mex files in the code.

	> demo
	This runs the sample example and shows the result. Please wait a few minutes for the code to
	complete. It might take time depending on the system. We tried/tested this code
	on linux machines with over 8GB of RAM. We suggest you do the same.

USAGE:

	Usage of this code for your own purposes requires understanding of two main things
	1) How to setup the datastructures required for optimization.
	2) How to setup the constraint functions.

	1) How to setup the datastructures.

		Optimization variable: The optimization variable consists of 4 components. Let n be the
		number of detections and m be the number of edges. Then the optimization variable 
		is of size [m + n + 2*n + k] x 1, 
		where k is the number of constraint variables. The first m variables denote edge selections,
		& the next n denote detection selections. The next 2*n variables denote selections of 
		connections between each detection and the dummy source and sink. The final k denote
		selection of constraint variables.

		In order to setup the optimization, we first have to define the 'param' structure. This
		is done by using the command.

	> param = SetUpOptimVarsAndConstraints( detections, edges, framenums ) 
		detections 	- a matrix of size n x 5 in which the first 4 columns denote the top-left and
					bottom right corners of each detection, and the 5th column denotes the
					confidence. Each row of this variable represents 1 detection.
					Its format is thus [x11 y11 x12 y12 c1; ....; xn1 yn1 xn2 yn2 cn] ;
		edges		- a matrix of size m x 3 in which the first 2 columns are indices into the
					rows of the detections variable. The last column is edge confidence.
					Its format is [i11 i12 e1; ...; im1 im2 em] ;
		framenums	- a matrix of size n x 1 where each element is a number that denotes the frame
						number that the corresponding detection belongs to i.e. the ith element
						of this matrix gives the frame number of the detection in the 
						ith row of 'detections' matrix.
		NOTE: 1) Always structure edges such that framenums( edges(i, 1) ) < framenums( edges(i, 2) ) 
			  2) Please avoid duplicating edges, since this will create many separate variables
			  		for 1 edge in the actual graph.

	param datastructure contains all the elements needed to run the optimization procedure.
	Look at step 2 to see how to create constraint functions.
	The variable 'param.nConstraints' stores the different type of constraints you have defined.
	NOTE: param.nConstraints is NOT EQUAL to 'k' mentioned above. param.nConstraints represents
	the type of constraints you have added. For example, lets say you add two types of constraints,
	temporal and spatial. There are 1000 temporal variables and 2000 spatial variables. Then
	k = 3000 and param.nConstraints = 2. See paper for more details.

	At this point, you might want to save the 'param' variable in a mat file, since this structure
	now contains all variables needed to perform the optimization (except weights).

	Next, we set the weights of these variables using the sparse function. 
	> weights.model.w = sparse([1, 0, 1, 0, 0, 0])' ; % sample weight, general idea is 4 + 2*param.nConstraints
	The weights structure stores the weights that you might want to give for 'scaling' and 'biasing'
	different elements of the optimization. The different elements are 'edges', 'detections',
	'constraints'
	
	'edges' 		- The first two elements in 'w' store the scaling and bias given to edge variables.
					Thus in the optimization, an edge confidence ei is multiplied by the scaling variable and added
					to the bias variable. 
	'detections' 	- The next two elements in 'w' store scaling and bias given to detection
					variables. Detection confidences are then modified the same way as edge
					confidences in the optimization.
	'constraints'	- The next 2*param.nConstraints variables in 'w' store scaling and bias given to constraint
						variables. They are stored in the format [scaling1, bias1, scaling2, bias2, ...]'
						Constraint variables are then scaled and biased accordingly.

	Finally, you can perform the optimization by calling the following function.
	> [yint, ypred] = predict( param, weights ) ;
	It returns two variables, 'yint' and 'ypred'
	'yint' 			- Optimization variable representing integer solution, obtained after final
						Frank-Wolfe rounding step. See paper for details. This is the output you
						generally want.
	'ypred'			- Optimization variable containting fractional solution before running the 
						Frank-Wolfe rounding step. Generally its a good practice to check the
						difference between them to assess how far the integer solution is from
						the fractional solution.
						The 'predict' function normally outputs some statistics of how good 
						the rounding has been, but we provide the fractional solution additionally
						so that you can run your own tests if/when needed. Its also generally
						a good idea to save both solutions.

	Finally, you now need to convert the optimization output into a datastructure that you can
	visualize/evaluate. This command converts the optimization variable to such a datastructure.
	> opttracks = findalltracks( yint([param.optstruct.detids param.optstruct.connids]), ...
					param.ndets, param.ntrcks, param.edge_xi, param.edge_xj, ...
					param.edgemat, param.nedgs, param.alldets ) ;
	> dresdp = convert_opttracks_to_dres( opttracks, param.xs ) ;

	dresdp is now a datastructure that contains the following fields.
	dresdp.x 		- matrix of size n x 1 containing top-left x-coordinate of all detections.
	dresdp.y 		- matrix of size n x 1 containing top-left y-coordinate of all detections.
	dresdp.w 		- matrix of size n x 1 containing width of all detections.
	dresdp.h 		- matrix of size n x 1 containing height of all detections.
	dresdp.fr 		- matrix of size n x 1 containing frame number of all detections.
	dresdp.id 		- matrix of size n x 1 containing track number of all detections (-1 denotes detections not selected)
	dresdp.hogconf 	- matrix of size n x 1 containing confidences of all detections (includes edge confidences)

	You can now evaluate your solution w.r.t the ground truth. Check demo.m to see details on how
	to do this.

	2) Setting up a constraint function
	A constraint function is of the form
	Q_data = constraintFunction( variable arguments designed by user )
		Q_data is a matrix of the form k x 3, where there are k number of pairwise constraints. Each
		row of Q_data is of the form [v11 v12 k1] where
		v1 and v2 denote the two optimization variables (edges or detections) that form a pairwise
		constraint. k1 denotes the penalty of selecting v1 and v2 simultaneously. 
		For example, let us say we want to enforce the pairwise cosntraint
		'Edge 1 and Detection 10 must always be selected simultaneously'
		In such a case v1 = 1 (edge number 1)
		v2 = m + 10 (since optimization contains edge variables first, the 10 detection is
					represented by the variable number m + 10 in 'yint' and 'ypred')
		k1 = -ve number (because we want to give a 'boost' to joint selection. If you want
						to supress, give a +ve number).

		You can model your constraint function by using already implemented examples available in
		the directory 'utilsopt/Constraints'

		Finally, you have to edit SetUpOptimVarsAndConstraints.m, to add your function to the 
		optimization process. There are sample constraints already added in the file. Please
		edit it to add your own.

	3) Plotting functions
		plotTracks( dresdp ) - plots tracks, with each track in different color.
		showboxes( im, bxs ) - overlays bounding boxes onto images.
		showboxes( im, bxs, clrs ) - shows each box with a different color, specified by the nx3
									matrix clrs. 0.0 <= clrs(i) <= 1.0
							- see demoscript.m for an example on how to use this function
									to show tracks overlayed on a set of images.
							- save these images and use a function like mencoder to create a result
									video for tracking. 

If you have any questions please email Visesh Chari. You can find his email id
at http://www.di.ens.fr/~chari
