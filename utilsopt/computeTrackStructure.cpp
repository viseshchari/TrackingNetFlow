#include "mex.h"
#include <stdio.h>
#include <iostream>
#include <math.h>
#include <stdlib.h>
#include <vector>

using namespace std ;

struct detections{
	int id ;
	vector<int> nextdets ;
	vector<int> edgenum ;
	void clear()
	{
		id = -1 ;
		nextdets.clear() ;
	}
	~detections()
	{
		clear() ;
	}
} ;

vector<detections> detarray ;
int nedgs = 0 ;

void add_matrix_to_detarray( mxArray *currmat, int ndets ) ;

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
	const char* fieldnames[] = { "detno", "nextdets", "edgenum" } ;
	mxArray *x, *y, *z ;
	int ndets = 0, ncells, currm ;

	// First part of the code that reads the cell array and extracts all the 2D arrays.
	ncells = mxGetNumberOfElements( prhs[0] ) ;

	mexPrintf( "Number of cells %d\n", ncells ) ;

	for( int i = 0 ; i < ncells ; i++ )
	{
		currm = mxGetM( mxGetCell( prhs[0], i) ) ;
		mexPrintf( "Processing cell number %d with size %d\n", i, currm ) ;
		add_matrix_to_detarray( mxGetCell( prhs[0], i ), ndets ) ;
		ndets += currm ;
	}
	mexPrintf( "Total number of detections %d\n", ndets ) ;

	// Now create structure array with the required fields.
	plhs[0] = mxCreateStructMatrix( 1, ndets, 3, fieldnames ) ;

	// Second part of the code writes the cell array into the structure array.
	for( int i = 0 ; i < ndets ; i++ )
	{
		x = mxCreateDoubleMatrix( 1, 1, mxREAL ) ;
		y = mxCreateDoubleMatrix( 1, detarray[i].nextdets.size(), mxREAL ) ;
		z = mxCreateDoubleMatrix( 1, detarray[i].edgenum.size(), mxREAL ) ;

		(*mxGetPr(x)) = detarray[i].id ;
		for( int j = 0 ; j < detarray[i].nextdets.size() ; j++ )
			mxGetPr(y)[j] = detarray[i].nextdets[j] ;
		for( int j = 0 ; j < detarray[i].edgenum.size() ; j++ )
			mxGetPr(z)[j] = detarray[i].edgenum[j] ;
		mxSetFieldByNumber( plhs[0], i, 0, x ) ;
		mxSetFieldByNumber( plhs[0], i, 1, y ) ;
		mxSetFieldByNumber( plhs[0], i, 2, z ) ;
	}

	detarray.clear() ;
	return ;
}

void add_matrix_to_detarray( mxArray *currmat, int ndets )
{
	int m, n ;
	m = mxGetM( currmat ) ;
	n = mxGetN( currmat ) ;
	mexPrintf( "Size of the matrix %d %d %s\n", m, n, mxGetClassName( currmat ) ) ;

	detections newdet ;
	float *pr = (float *) mxGetData( currmat ) ;

	// mexPrintf( "%f %f %f %f\n", pr[267*m], pr[134*m], pr[2*m], pr[3*m] ) ;
	for( int i = 0 ; i < m ; i++ )
		detarray.push_back( newdet ) ;

	for( int i = 0 ; i < m*n ; i++ )
	{
		detarray[ndets+i%m].id = i%m+1+ndets ;
		// mexPrintf( "Current index %d/%d\n", i, m ) ;
		if( pr[i] > 0.0 )
			detarray[ndets+i%m].nextdets.push_back( i/m+1+ndets ) ;
		// detarray.push_back( newdet ) ; // add the current structure to the array.
		// clear temporary structure to add new information.
		// newdet.clear() ;
	}

	for( int i = 0 ; i < m*n ; i++ )
		if( pr[i] > 0.0 )
			detarray[ndets+i%m].edgenum.push_back( ++nedgs ) ;

	mexPrintf( "Done with the processing\n" ) ;

	return ;
}