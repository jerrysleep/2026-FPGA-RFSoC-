#include "dataprocess.h"

 
double FeederPhaseComp_1[4]={0,0,0,0};  
double FeederPhaseComp_2[4]={0,0,0,0};  

double ResultTrans[10]; 


double g_tr_near=196e-9; 
double g_tr_far=484e-9;
double g_tp_near=40e-9; 
double g_tp_far=200e-9;


 
 
 
double parabola_peak_interp(double*refdata,int k)
{
	if(radarstate.wavemode==1 && (k==1 || k==60)) 
	{
		return k;
	}
	if(radarstate.wavemode==0 && (k==1 || k==49)) 
	{
		return k;
	}

	double alpha = refdata[0];
	double beta  = refdata[1];
	double gamma = refdata[2];

	alpha = 10*log10(alpha);
	beta = 10*log10(beta);
	gamma = 10*log10(gamma);

	 
	double den = alpha-2*beta+gamma;
	double delta = 0;

	if(fabs(den)<1e-12)
	{
		delta=0;
	}
	else
	{
		delta = 0.5*(alpha-gamma)/den;
	}

	 
	double peak_index = k+delta;

	return peak_index;
}

 
double wrap(double x)
{
	while(x>M_PI) x-=2*M_PI;
	while(x<-M_PI) x+=2*M_PI;

	return x;
}
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 
 
 

 
 
 
 
 
 

 
 
 
 
 
 


 
 
 
 
 
void SolvePitchAndAngle(double *input,double *refphase,int antenna,double lamda,double *output)
{
	 
 
 
 
 
	double d_x_short_14 = 0.5*LIGHT_SPEED/26e9;
	double d_x_long_15  = 3.0*LIGHT_SPEED/26e9;
	double d_y_short_12 = 0.5*LIGHT_SPEED/26e9;
	double d_y_long_13  = 3.0*LIGHT_SPEED/26e9;

	 
 
 
 
 
 
 
 
 
 
	double phi_x_short_14 = input[3]-input[0];  
	double phi_x_long_15  = input[4]-input[0];  
	double phi_y_short_12 = input[1]-input[0];  
	double phi_y_long_13  = input[2]-input[0];  

	 
 
 
 
 
	double ref_x_short_14 = refphase[2];
	double ref_x_long_15  = refphase[3];
	double ref_y_short_12 = refphase[0];
	double ref_y_long_13  = refphase[1];

	double dphi_x_short_14;
	double dphi_x_long_15;
	double dphi_y_short_12;
	double dphi_y_long_13;

	 
	if(antenna == 0)
	{
		 
		dphi_x_short_14 = wrap(phi_x_short_14-ref_x_short_14-FeederPhaseComp_1[0]);
		dphi_x_long_15  = wrap(phi_x_long_15-ref_x_long_15-FeederPhaseComp_1[1]);
		dphi_y_short_12 = wrap(phi_y_short_12-ref_y_short_12-FeederPhaseComp_1[2]);
		dphi_y_long_13  = wrap(phi_y_long_13-ref_y_long_13-FeederPhaseComp_1[3]);
	}
	else if(antenna == 1)
	{
		dphi_x_short_14 = wrap(phi_x_short_14-ref_x_short_14-FeederPhaseComp_2[0]);
		dphi_x_long_15  = wrap(phi_x_long_15-ref_x_long_15-FeederPhaseComp_2[1]);
		dphi_y_short_12 = wrap(phi_y_short_12-ref_y_short_12-FeederPhaseComp_2[2]);
		dphi_y_long_13  = wrap(phi_y_long_13-ref_y_long_13-FeederPhaseComp_2[3]);
	}
	else
	{
		 
		output[0] = NAN;
		output[1] = NAN;
		return;
	}

	 
	double ux_short = lamda*dphi_x_short_14/(2*M_PI*d_x_short_14);
	double uy_short = lamda*dphi_y_short_12/(2*M_PI*d_y_short_12);

	 
	double n_amb_x = round(ux_short*d_x_long_15/lamda -
	                       dphi_x_long_15/(2*M_PI));
	double n_amb_y = round(uy_short*d_y_long_13/lamda -
	                       dphi_y_long_13/(2*M_PI));

	 
	double dphi_x_long_unwrap = dphi_x_long_15 + 2*M_PI*n_amb_x;
	double dphi_y_long_unwrap = dphi_y_long_13 + 2*M_PI*n_amb_y;

	 
	double ux_long = dphi_x_long_unwrap*lamda/(2*M_PI*d_x_long_15);
	double uy_long = dphi_y_long_unwrap*lamda/(2*M_PI*d_y_long_13);

	 
 
 
 
	double azi_est_long = atan2(uy_long,ux_long);

	double direction_cosine_xy = sqrt(ux_long*ux_long + uy_long*uy_long);
	if(direction_cosine_xy > 1.0)
		direction_cosine_xy = 1.0;

	double ele_est_long = acos(direction_cosine_xy);

	output[0] = azi_est_long/M_PI*180.0;
	output[1] = ele_est_long/M_PI*180.0;
}




 
void UintQuantitative(double *ResultTrans,u8 *sendresult)
{
	sendresult[0] = 0xE5;
	if(ResultTrans[0]<0)
		ResultTrans[0]=ResultTrans[0]+360;

	sendresult[1] = (u8)(ResultTrans[0]/1.5); 
	sendresult[2] = (u8)(ResultTrans[1]/1);   
	sendresult[3] = (u8)(ResultTrans[2]/0.3); 
	sendresult[4] = (u8)(ResultTrans[3]/12.5); 
}
