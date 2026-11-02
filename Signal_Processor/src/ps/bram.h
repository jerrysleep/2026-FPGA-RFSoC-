#ifndef BRAM_H
#define BRAM_H

#include "xparameters.h"	 
#include "xsdps.h"		 
#include "xil_printf.h"
#include "ff.h"
#include "xil_cache.h"
#include "xplatform_info.h"

#include "globalvar.h"
#include "dataprocess.h"
#include "emmc.h"
#include "pl_uartlite.h"

 
struct ToDTState {
	u8 timelsb;
	u8 timemsb;
	u8 state1; 
	u8 state2; 
};
extern struct ToDTState todtstate;

 
struct RadarState {
	u8 wavemode;   
	u8 antenna;    
	u8 rftrans_onoff;  
	u8 rfreceiver_onoff;
	u8 reserve;
	u8 rfloca;
	u8 rfpower;
	u8 rftemp;
	u8 freqcode;
	u8 target;
	u8 workdone;
	u8 emmcparamd;
};
extern struct RadarState radarstate;

struct RadarParams{
	u32 farbeishu;
	u32 nearbeishu;
	u32 adcdelay;
	u32 rfmodulationwidth;
};
extern struct RadarParams radarparams;

extern SemaphoreHandle_t xSemaphoreMeasSend;

extern u8 TargetStorebuff[30000000];
extern u8 TargetReadbuff[30000000];
extern int TargetStoreCnt; 
extern int TarStoreCntCum; 
extern u8 FreqCode;
extern u8 RFState; 
extern u8 UpMState[100]; 
extern u8 g_MeasStarTrans; 
extern u8 UpMeasSend[1500]; 
extern u8 recvpstestbuff[200];

extern double tmprefrephase[4][1000];
extern double tmprefimphase[4][1000];


extern u8 pstestflag; 
extern u8 bjmode;
extern int tarstorecontrol;

extern u8 sendresultdt[5];  
extern u8 sendresultdt_state[5];   
extern u8 sendresultdt_target[5];  

extern double refre[4],refim[4];


#define MEAS_FRAMSIZE   11

void BramParamSetToPL_32(u16 addr,u32 data);
void BramReadAndProcMeasData();
void BramReadStateAndTime();

void MoniToDtTask();
#endif
