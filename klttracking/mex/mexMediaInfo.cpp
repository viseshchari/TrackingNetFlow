#include "mex.h"
#include <string>
#include <cstdlib>

#include "MediaInfo/MediaInfo.h"
#include "ZenLib/Ztring.h"

using namespace MediaInfoLib;
using namespace ZenLib;
using namespace std;

#define _Z(s) Ztring(s)

#define NUMBER_OF_FIELDS (sizeof(field_names)/sizeof(*field_names))
const char *field_names[] = {"aspect", "fps", "duration", "width", "height"};

void assign_value_to_field(mxArray *dest, string field_name, double value)
{
  mxArray *field_value = mxCreateDoubleMatrix(1, 1, mxREAL);
  *mxGetPr(field_value) = value;
  int field_id = mxGetFieldNumber(dest, field_name.c_str());
  mxSetFieldByNumber(dest, 0, field_id, field_value);
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  if (nrhs != 1)
    mexErrMsgTxt("One input argument (filename) expected.\n");
  if (!(mxIsChar(prhs[0])))
    mexErrMsgTxt("Input must be of type string.\n.");
  if (nlhs != 1)
    mexErrMsgTxt("One output argument expected.\n");
  mwSize dims[2] = {1,1};
  plhs[0] = mxCreateStructArray(2, dims, NUMBER_OF_FIELDS, field_names);
  int aspect_field = mxGetFieldNumber(plhs[0], "aspect");
  int fps_field = mxGetFieldNumber(plhs[0], "fps");
  int duration_field = mxGetFieldNumber(plhs[0], "duration");
  int frames_field = mxGetFieldNumber(plhs[0], "frames");
  int width_field = mxGetFieldNumber(plhs[0], "width");
  int height_field = mxGetFieldNumber(plhs[0], "height");
  MediaInfo MI;
  char *filename = mxArrayToString(prhs[0]);
  if (!MI.Open(_Z(filename)))
    mexErrMsgTxt("Could not open file.\n");
  assign_value_to_field(plhs[0], "width", _Z(MI.Get(Stream_Video, 0, _Z("Width"))).To_int32u());
  assign_value_to_field(plhs[0], "height", _Z(MI.Get(Stream_Video, 0, _Z("Height"))).To_int32u());
  assign_value_to_field(plhs[0], "fps", _Z(MI.Get(Stream_Video, 0, _Z("FrameRate"))).To_float64());
  assign_value_to_field(plhs[0], "duration", _Z(MI.Get(Stream_Video, 0, _Z("Duration"))).To_int32u());
  assign_value_to_field(plhs[0], "aspect", _Z(MI.Get(Stream_Video, 0, _Z("DisplayAspectRatio"))).To_float64());
  MI.Close();
}
