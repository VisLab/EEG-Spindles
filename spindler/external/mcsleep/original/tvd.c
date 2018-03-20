
/* output = tvd(input,width,lambda)
 * Total variation denoising (1-D signals)
 *
 * Mex version: Faruk UYSAL June 2012
 *
 * Original: L. Condat, A Direct Algorithm for 1D Total Variation Denoising
 *   preprint hal-00675043, Feb. 2012.
 *   http://www.greyc.ensicaen.fr/~lcondat/
 */

//include libraries
#include "mex.h"
#include "matrix.h"
#include <stdio.h>
#include <math.h>
#include <string.h>


// Macro for real full double vector checking:
#define IS_REAL_FULL_DOUBLE_VECTOR(P) (		\
mxIsDouble(P)						&&	\
!mxIsComplex(P)						&&	\
!mxIsSparse(P)						&&	\
mxGetNumberOfDimensions(P) < 3		&&	\
(mxGetM(P)==1 ||  mxGetN(P)==1))			\


// -------------------------------------------------------------------------
//		Gateway Function (like main function. Starting point of program)
// -------------------------------------------------------------------------

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
//gateway function for mex
{
    /* Arguments
     * nlhs: Number of expected output mxArrays
     * plhs: Array of pointers to the expected output mxArrays
     * nrhs: Number of input mxArrays
     * prhs: Array of pointers to the input mxArrays.
     */

    double *input, *output;
    mwSize mrows, ncols;
    int width,N;
    double lambda,width_temp;
    void TV1D_denoise(double* input, double* output, const int width, const double lambda);

    /* check for the proper number of arguments */
    if(nrhs != 3)
        mexErrMsgTxt("There should be 3 input arguments.");
    if(nlhs > 1 )
        mexErrMsgTxt("Too many output arguments.");

    /* row and column vectors are allowed.*/
	if IS_REAL_FULL_DOUBLE_VECTOR(prhs[0]) {

		/* get the length of input vector  */
		N = mxGetNumberOfElements(prhs[0]);

		/* get pointers input vector */
		input = mxGetPr(prhs[0]);

	} else {
		mexErrMsgTxt("x must be a vector (double, non-sparse).");
	}

    /*Check that width is an integer scaler */
    width_temp = mxGetScalar(prhs[1]); // Get width as a double
    if(mxIsDouble(prhs[1]) && mxGetNumberOfElements(prhs[1]) == 1 && width_temp/1.00 == (int)width_temp)
        width=(int)width_temp;
    else
        mexErrMsgTxt("width must be an integer scalar.");

    if (width>N)
        mexErrMsgTxt("width must be equal or smaller than signal length.");

    /*Check that labmda is a double scaler */
    if(mxIsDouble(prhs[2]) && mxGetNumberOfElements(prhs[2]) == 1)
        lambda=mxGetScalar(prhs[2]);
    else
        mexErrMsgTxt("lambda must be a double  scalar."); /* Get r */


    /* Create a matrix for the return argument */
    plhs[0]= mxCreateDoubleMatrix(1, N, mxREAL);
    /* Assign pointers to the output parameters */
    output = mxGetPr(plhs[0]);

    TV1D_denoise(input, output, width, lambda);

    return;

}


// The following function is from the webpage of Laurent Condat
// http://www.greyc.ensicaen.fr/~lcondat/

// -------------------------------------------------------------------------
//				TV1D_denoising
// -------------------------------------------------------------------------


/*
 * This function implements the 1D total variation denoising
 * algorithm described in the paper referenced above.
 * If output=input, the process is performed in place. Else,
 * the values of input are left unchanged.
 * lambda must be nonnegative. lambda=0 is admissible and
 * yields output[k]=input[k] for all k.
 * If width<=0, nothing is done.
 */
void TV1D_denoise(double* input, double* output, const int width, const
double lambda) {
    if (width>0) {				/*to avoid invalid memory access to input[0]*/
        int k=0, k0=0;			/*k: current sample location, k0: beginning of current segment*/
        double umin=lambda, umax=-lambda;	/*u is the dual variable*/
        double vmin=input[0]-lambda, vmax=input[0]+lambda;	/*bounds for the segment's value*/
        int kplus=0, kminus=0; 	/*last positions where umax=-lambda, umin=lambda, respectively*/
        const double twolambda=2.0*lambda;	/*auxiliary variable*/
        const double minlambda=-lambda;		/*auxiliary variable*/
        for (;;) {				/*simple loop, the exit test is inside*/
            while (k==width-1) {	/*we use the right boundary condition*/
                if (umin<0.0) {			/*vmin is too high -> negative jump necessary*/
                    do output[k0++]=vmin; while (k0<=kminus);
                    umax=(vmin=input[kminus=k=k0])+(umin=lambda)-vmax;
                } else if (umax>0.0) {	/*vmax is too low -> positive jump necessary*/
                    do output[k0++]=vmax; while (k0<=kplus);
                    umin=(vmax=input[kplus=k=k0])+(umax=minlambda)-vmin;
                } else {
                    vmin+=umin/(k-k0+1);
                    do output[k0++]=vmin; while(k0<=k);
                    return;
                }
            }
            if ((umin+=input[k+1]-vmin)<minlambda) {		/*negative jump necessary*/
                do output[k0++]=vmin; while (k0<=kminus);
                vmax=(vmin=input[kplus=kminus=k=k0])+twolambda;
                umin=lambda; umax=minlambda;
            } else if ((umax+=input[k+1]-vmax)>lambda) {	/*positive jump necessary*/
                do output[k0++]=vmax; while (k0<=kplus);
                vmin=(vmax=input[kplus=kminus=k=k0])-twolambda;
                umin=lambda; umax=minlambda;
            } else { 	/*no jump necessary, we continue*/
                k++;
                if (umin>=lambda) {		/*update of vmin*/
                    vmin+=(umin-lambda)/((kminus=k)-k0+1);
                    umin=lambda;
                }
                if (umax<=minlambda) {	/*update of vmax*/
                    vmax+=(umax+lambda)/((kplus=k)-k0+1);
                    umax=minlambda;
                }
            }
        }
    }
}
