#ifndef DATAPROCESS_H
#define DATAPROCESS_H

#include "math.h"

#include "globalvar.h"
#include "bram.h"

#define LIGHT_SPEED    299792458

#define SAMPLE_FAR         250e6
#define SAMPLE_NEAR        250e6

#define TR_FAR         484e-9
#define TR_NEAR        196e-9

#define TP_FAR         200e-9;
#define TP_NEAR        40e-9;

#define BANDWIDTH      50e6;

#define FFT_NUM_NEAR   512
#define FFT_NUM_FAR    1024

#define FARWAVE     0
#define NEARWAVE    1

#define PI 3.14159265358979323846

extern double ResultTrans[10]; 

extern double g_tr_near; 
extern double g_tr_far;
extern double g_tp_near; 
extern double g_tp_far;

extern double FeederPhaseComp_1[4];  
extern double FeederPhaseComp_2[4];  

void SolvePitchAndAngle(double *input,double *refphase,int antenna,double lamda,double *output);
void UintQuantitative(double *ResultTrans,u8 *sendresult);
double parabola_peak_interp(double*refdata,int k);
#endif
