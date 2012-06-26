#ifdef __cplusplus
extern "C" {
#endif

//These are the only 2 functions you have to use. Don't care about the ones in husl.c

//Pass in HUSL values and get back RGB values, H ranges from 0 to 360, S and L from 0 to 100.
//RGB values will range from 0 to 1.
void HUSLtoRGB(float *r, float *g, float *b, float h, float s,float l);

//Pass in RGB values ranging from 0 to 1 and get back HUSL values.
//H ranges from 0 to 360, S and L from 0 to 100.
void RGBtoHUSL(float *h, float *s,float *l, float r, float g, float b);


#ifdef __cplusplus
} 
#endif