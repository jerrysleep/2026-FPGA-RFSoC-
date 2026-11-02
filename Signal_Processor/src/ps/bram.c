#include "bram.h"


struct ToDTState todtstate;
struct RadarState radarstate;
struct RadarParams radarparams;


u8 FreqCode=200; 
u8 RFState = 0; 

u8 UpMState[100]; 

u8 sendresultdt[5];  
u8 sendresultdt_state[5];   
u8 sendresultdt_target[5];  


u8 UpMeasSend[1500]; 
int measrecvcnt = 0; 
uint32_t measrecvtotalcnt = 0; 
u8 g_MeasStarTrans=0; 

 
u8 TargetStorebuff[30000000]; 
u8 TargetReadbuff[30000000]; 

int TargetStoreCnt = 0; 
int TarStoreCntCum = 0; 
int tarstorecontrol = -1;

 
u8 recvpstestbuff[200];
u8 pstestflag = 0; 
u8 bjmode = 0;  

 
 
 
void BramParamSetToPL_32(u16 addr,u32 data)
{
	Xil_Out32(XPAR_BRAM_1_BASEADDR+addr,data);
	usleep(10);
}


double wrap_to_pi(double x)
{
	while(x>PI)
		x-=2.0*PI;
	while(x<-PI)
		x+=2.0*PI;

	return x;
}

void CalRefPhaseStd(double *std,int n)
{
	int i=0,j=0;
	double sum_sin[4]={0,0,0,0};
	double sum_cos[4]={0,0,0,0};
	double mean_phase[4]={0,0,0,0};
	for(j=0;j<4;j++)
	{
		for(i=0;i<n;i++)
		{
			sum_sin[j] += tmprefimphase[j][i];
			sum_cos[j] += tmprefrephase[j][i];
		}
	}

	for(i=0;i<4;i++)
	{
		mean_phase[i] = atan2(sum_sin[i],sum_cos[i]);
	}

	double sum_squre[4]={0,0,0,0};

	for(j=0;j<4;j++)
	{
		for(i=0;i<n;i++)
		{
			double phase = atan2(tmprefimphase[j][i],tmprefrephase[j][i]);
			double diff = wrap_to_pi(phase-mean_phase[j]);

			sum_squre[j] += diff*diff;
		}
	}

	for(i=0;i<4;i++)
	{
		std[i] = sqrt(sum_squre[i]/n);
	}
}

 
 
void BramReadStateAndTime()
{
	uint32_t readbuff32[6];

	int addr = 0;
	for(int i = 0;i<6;i++)
	{
		readbuff32[i] = Xil_In32(XPAR_BRAM_0_BASEADDR+addr);
		addr+=4;
	}

	addr = 0;
	int hour = readbuff32[1];
	int min = readbuff32[2];
	int sec = readbuff32[3];
	int msec10 = readbuff32[4];
	int fk_state = readbuff32[5];

	int totalsecond10 = (min*60+sec)*10+msec10/10;

	u8 sendbuf[5];
	sendbuf[0] = 0xE5;
	sendbuf[1] = totalsecond10 & 0xff;
	sendbuf[2] = (totalsecond10>>8) & 0xff;
	sendbuf[3] = FreqCode;
	sendbuf[4] = (fk_state & 0xf8) | (RFState & 0x07); 

	 
	todtstate.timelsb = sendbuf[1];
	todtstate.timemsb = sendbuf[2];
	todtstate.state1 = sendbuf[3];
	todtstate.state2 = sendbuf[4];

	 
	sendresultdt_state[0] = 0xEA;
	sendresultdt_state[1] = todtstate.timelsb;
	sendresultdt_state[2] = todtstate.timemsb;
	sendresultdt_state[3] = todtstate.state1;
	sendresultdt_state[4] = todtstate.state2;

	 
	u8 data[4];
	data[0] = sendbuf[0];
	data[1] = sendbuf[3];
	data[2] = sendbuf[4];
	data[3] = 0;
	for(int i=0;i<4;i++)
	{
		Xil_Out32(XPAR_BRAM_3_BASEADDR+addr,data[i]);
		addr+=4;
		usleep(10);
	}

	 
	UpMState[0] = 0xEB;
	UpMState[1] = 0x08;
	UpMState[2] = 0xA4;
	UpMState[3] = FreqCode;
	UpMState[4] = todtstate.timelsb ;
	UpMState[5] = todtstate.timemsb ;
	UpMState[6] = rf485state.lockindic;
	UpMState[7] = rf485state.power;
	UpMState[8] = rf485state.temp;
	UpMState[9] = fk_state;

	int azi = (int)(ResultTrans[0]*1000);
	UpMState[10] = azi>>24 & 0xff;
	UpMState[11] = azi>>16 & 0xff;
	UpMState[12] = azi>>8 & 0xff;
	UpMState[13] = azi>>0 & 0xff;

	int ele = (int)(ResultTrans[1]*1000);
	UpMState[14] = ele>>24 & 0xff;
	UpMState[15] = ele>>16 & 0xff;
	UpMState[16] = ele>>8 & 0xff;
	UpMState[17] = ele>>0 & 0xff;

	int distance = (int)(ResultTrans[2]*1000);
	UpMState[18] = distance>>24 & 0xff;
	UpMState[19] = distance>>16 & 0xff;
	UpMState[20] = distance>>8 & 0xff;
	UpMState[21] = distance>>0 & 0xff;

	int speed = (int)(ResultTrans[3]*1000);
	UpMState[22] = speed>>24 & 0xff;
	UpMState[23] = speed>>16 & 0xff;
	UpMState[24] = speed>>8 & 0xff;
	UpMState[25] = speed>>0 & 0xff;

	UpMState[26] = radarstate.target;
	UpMState[27] = radarstate.emmcparamd;


	 
	double refphasestd[4];
	CalRefPhaseStd(refphasestd,1000);

	int tmphase = (int)(refphasestd[0]*1000);
	UpMState[28] = tmphase>>24 & 0xff;
	UpMState[29] = tmphase>>16 & 0xff;
	UpMState[30] = tmphase>>8 & 0xff;
	UpMState[31] = tmphase>>0 & 0xff;

	tmphase = (int)(refphasestd[1]*1000);
	UpMState[32] = tmphase>>24 & 0xff;
	UpMState[33] = tmphase>>16 & 0xff;
	UpMState[34] = tmphase>>8 & 0xff;
	UpMState[35] = tmphase>>0 & 0xff;

	tmphase = (int)(refphasestd[2]*1000);
	UpMState[36] = tmphase>>24 & 0xff;
	UpMState[37] = tmphase>>16 & 0xff;
	UpMState[38] = tmphase>>8 & 0xff;
	UpMState[39] = tmphase>>0 & 0xff;

	tmphase = (int)(refphasestd[3]*1000);
	UpMState[40] = tmphase>>24 & 0xff;
	UpMState[41] = tmphase>>16 & 0xff;
	UpMState[42] = tmphase>>8 & 0xff;
	UpMState[43] = tmphase>>0 & 0xff;

	radarstate.wavemode = (fk_state>>7) & 0x01;
	radarstate.antenna = (fk_state>>6) & 0x01;
	radarstate.rftrans_onoff = (fk_state>>5) & 0x01;
	radarstate.rfreceiver_onoff = (fk_state>>4) & 0x1;
	radarstate.rfloca = (fk_state>>2) & 0x1;
	radarstate.rfpower = (fk_state>>1) & 0x1;
	radarstate.rftemp = (fk_state>>0) & 0x1;
	radarstate.freqcode = FreqCode;
	radarstate.workdone = 1;
}

 
void MoniToDtTask()
{
	int addr = 0;
	for(;;)
	{
		addr = 0;
		 
		for(int i=0;i<5;i++)
		{
			Xil_Out32(XPAR_BRAM_2_BASEADDR+addr,sendresultdt[i]);
			addr+=4;
			usleep(10);
		}
		vTaskDelay(pdMS_TO_TICKS(1)); 
	}
}

 
 
 
 
 
 

 
double refre[4]={0,0,0,0},refim[4]={0,0,0,0};
double tmprefrephase[4][1000]={0};
double tmprefimphase[4][1000]={0};
u32 tmprefcnt = 0;
void BramReadAndProcMeasData()
{
	u32 readbuff32[MEAS_FRAMSIZE];
	u16 readbuff[MEAS_FRAMSIZE*2];
	double phase5[5];  
	int i=0;
	int addr = 512;
	int refortarflag = 0;
	BaseType_t xHighterPriorityTaskWoken = pdFALSE;

	for(i = 0;i<MEAS_FRAMSIZE;i++)
	{
		readbuff32[i] = Xil_In32(XPAR_BRAM_1_BASEADDR+addr);
		addr+=4;
	}

	for(i=0;i<MEAS_FRAMSIZE;i++)
	{
		readbuff[2*i] = readbuff32[i]>>16 & 0xffff;
		readbuff[2*i+1] = readbuff32[i]>>0  & 0xffff;
	}

	if(pstestflag == 1)
	{
		for(i=0;i<5;i++)
		{
			readbuff[16+i] = (u16)(recvpstestbuff[2*i+3]<<8 | recvpstestbuff[2*i+4]);
		}

		readbuff[4] = (u16)(recvpstestbuff[13]<<8 | recvpstestbuff[14]); 
		readbuff[5] = (u16)(recvpstestbuff[15]<<8 | recvpstestbuff[16]); 

		for(i=0;i<5;i++)
		{
			readbuff32[i+3] = recvpstestbuff[17+4*i]<<24 | recvpstestbuff[18+4*i]<<16 | recvpstestbuff[19+4*i]<<8 | recvpstestbuff[20+4*i];
		}
	}

	refortarflag = readbuff[2];  

	if(bjmode == 1)  
	{
		refortarflag = 1;

		for(i=0;i<4;i++)
		{
			refre[i] = 0;
			refim[i] = 0;
		}

	}
	else if(bjmode == 0)  
	{
		bjmode = 3;
	}

	if(refortarflag == 1)  
	{
		 
		double refdiffphase[4];  
		refdiffphase[0] = (double)((short)readbuff[17])/pow(2,13) - (double)((short)readbuff[16])/pow(2,13); 
		refdiffphase[1] = (double)((short)readbuff[18])/pow(2,13) - (double)((short)readbuff[16])/pow(2,13); 
		refdiffphase[2] = (double)((short)readbuff[19])/pow(2,13) - (double)((short)readbuff[16])/pow(2,13); 
		refdiffphase[3] = (double)((short)readbuff[20])/pow(2,13) - (double)((short)readbuff[16])/pow(2,13); 

		tmprefrephase[0][tmprefcnt]  = cos(refdiffphase[0]);
		tmprefimphase[0][tmprefcnt]  = sin(refdiffphase[0]);
		tmprefrephase[1][tmprefcnt]  = cos(refdiffphase[1]);
		tmprefimphase[1][tmprefcnt]  = sin(refdiffphase[1]);
		tmprefrephase[2][tmprefcnt]  = cos(refdiffphase[2]);
		tmprefimphase[2][tmprefcnt]  = sin(refdiffphase[2]);
		tmprefrephase[3][tmprefcnt]  = cos(refdiffphase[3]);
		tmprefimphase[3][tmprefcnt]  = sin(refdiffphase[3]);

		tmprefcnt++;
		if(tmprefcnt>=1000)
			tmprefcnt = 0;

		refre[0]+= cos(refdiffphase[0]);
		refim[0]+= sin(refdiffphase[0]);
		refre[1]+= cos(refdiffphase[1]);
		refim[1]+= sin(refdiffphase[1]);
		refre[2]+= cos(refdiffphase[2]);
		refim[2]+= sin(refdiffphase[2]);
		refre[3]+= cos(refdiffphase[3]);
		refim[3]+= sin(refdiffphase[3]);
	}
	else if(refortarflag ==2)  
	{
		 
		double refmeanPhase[4]={0,0,0,0};
		refmeanPhase[0] = atan2(refim[0],refre[0]);
		refmeanPhase[1] = atan2(refim[1],refre[1]);
		refmeanPhase[2] = atan2(refim[2],refre[2]);
		refmeanPhase[3] = atan2(refim[3],refre[3]);

		 
		for(i=16;i<21;i++)
		{
			double tmp = (short)readbuff[i];
			phase5[i-16] = tmp/pow(2,13);
		}

		int tarflag = readbuff[3]>> 8 & 0xff;  
		int antenna = readbuff[3]>> 0 & 0xff;  

		radarstate.target = tarflag;
		if(tarflag == 1 || pstestflag == 1)  
		{
			tarstorecontrol = 1;

			 
			int k_vn = readbuff[4];
			int k_bm = readbuff[5];

			double range_profile_bm[3]={readbuff32[3],readbuff32[4],readbuff32[5]}; 
			double range_profile_vn[3]={readbuff32[6],readbuff32[4],readbuff32[7]}; 

			double peak_indx_bm = parabola_peak_interp(range_profile_bm,k_bm);
			double peak_indx_vn = parabola_peak_interp(range_profile_vn,k_vn);

			 
			double tr = 0;
			double tp = 0;
			double sample = 0;
			double m_fft = 0;
			if(radarstate.wavemode == 1) 
			{
				tr = g_tr_far;
				tp = g_tp_far;
				m_fft = FFT_NUM_FAR;
				sample = SAMPLE_FAR/(radarparams.farbeishu+1);
			}
			else if(radarstate.wavemode == 0) 
			{
				tr = g_tr_near;
				tp = g_tp_near;

				m_fft = FFT_NUM_NEAR;
				sample = SAMPLE_NEAR/(radarparams.nearbeishu+1);
			}
			double delta_r = LIGHT_SPEED/2.0/sample; 
			double delta_fd = 1.0/tr/m_fft;
			double r_measure = peak_indx_bm*delta_r;
			double f0 = radarstate.freqcode*10e6+24e9;
			double v_measure;

			if(peak_indx_vn>m_fft/2)
			  v_measure = (-m_fft/2-1+peak_indx_vn)*delta_fd*LIGHT_SPEED/f0/2;
			else
			  v_measure = peak_indx_vn*delta_fd*LIGHT_SPEED/f0/2;

			double B = BANDWIDTH;
			double K = B/tp;
			 
			double v_result = v_measure;    
			double r_result = r_measure+1/K*v_result*f0; 

			 
			double lamda = LIGHT_SPEED/f0;
			double angleresult[2]; 
			SolvePitchAndAngle(phase5,refmeanPhase,antenna,lamda,angleresult);

			 
			ResultTrans[0] = angleresult[0];
			ResultTrans[1] = angleresult[1];
			ResultTrans[2] = r_result;
			ResultTrans[3] = v_result;

			 
			UintQuantitative(ResultTrans,sendresultdt_target);

			TargetStorebuff[TargetStoreCnt++] = 0xE5;
			TargetStorebuff[TargetStoreCnt++] = ResultTrans[0];
			TargetStorebuff[TargetStoreCnt++] = ResultTrans[1];
			TargetStorebuff[TargetStoreCnt++] = ResultTrans[2];
			TargetStorebuff[TargetStoreCnt++] = ResultTrans[3];

			for(int j=0;j<11;j++)
			{
				TargetStorebuff[TargetStoreCnt++] = readbuff32[j]>>24 & 0xff;
				TargetStorebuff[TargetStoreCnt++] = readbuff32[j]>>16 & 0xff;
				TargetStorebuff[TargetStoreCnt++] = readbuff32[j]>>8 & 0xff;
				TargetStorebuff[TargetStoreCnt++] = readbuff32[j]>>0 & 0xff;
			}

			TarStoreCntCum += 49;

			if(TargetStoreCnt>=29400000)
				TargetStoreCnt = 29400000;
		}
		else             
		{
			if(tarstorecontrol == 1)
			{
				xSemaphoreGiveFromISR(xSemaphoreTarStore,&xHighterPriorityTaskWoken);
				tarstorecontrol = -1;
			}
		}
	}

	 
	if(g_MeasStarTrans == 1)
	{
		memcpy(UpMeasSend+measrecvcnt*MEAS_FRAMSIZE*4,readbuff32,MEAS_FRAMSIZE*4);
		measrecvcnt++;
		measrecvtotalcnt++;
		if(measrecvcnt>=30) 
		{
			measrecvcnt=0;
			if(measrecvtotalcnt>=0xffffffff)
				measrecvtotalcnt=0;
			xSemaphoreGiveFromISR(xSemaphoreMeasSend,&xHighterPriorityTaskWoken);
		}
	}

	portYIELD_FROM_ISR(xHighterPriorityTaskWoken);
}
