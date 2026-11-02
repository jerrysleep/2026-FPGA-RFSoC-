#ifndef EMMC_H
#define EMMC_H

#include "xparameters.h"	 
#include "xsdps.h"		 
#include "xil_printf.h"
#include "ff.h"
#include "xil_cache.h"
#include "xplatform_info.h"
#include "stdbool.h"

#include "globalvar.h"

#include "semphr.h"

extern SemaphoreHandle_t xSemaphoreTarStore;
extern SemaphoreHandle_t xSemaphoreTarSend;
extern SemaphoreHandle_t xSemaphoreReadEmmcParam;


extern int g_emmcMounted;
extern int g_emmcpramatoPL;
 

 

#define WRITE_CHUNK   8192


 
int EmmcReadAndWriteParameters(u8 *SourceAddress);
int EmmcParamFileReadAndToPL(uint16_t cmdType);
int EmmcParamFileWrite(uint16_t cmdType,uint8_t*data,uint32_t size);
void initialparamsettask();
void SendTargetDataTask();
void EmmcWriteTargetDataTask();
FRESULT Emmc_EnsureMounted();

extern int udp_packet_send_custom(u8 *send_buf,int length);
extern int udp_packet_send(u8 *send_buf,int length);
void readEmmcParamTask();

void noPulseCompressCmdSet();
void PulseCompressCmdSet();

#endif
