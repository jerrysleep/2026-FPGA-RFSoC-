#ifndef PL_UARTLITE_H
#define PL_UARTLITE_H

#include "xparameters.h"	 
#include "xsdps.h"		 
#include "xil_printf.h"
#include "ff.h"
#include "xil_cache.h"
#include "xplatform_info.h"

#include "xuartlite.h"
#include "xuartlite_l.h"
#include "stdio.h"
#include "xscugic.h"

#include "pl_gpio.h"

#include "globalvar.h"
#include "bram.h"


 
struct RF485State {
	u8 lockindic;
	u8 power;
	char temp;
};

extern struct RF485State rf485state;




int UartLiteInit();
void UartLite485RecvTask();
void UartLite485Send(u8 *buff,int length);
void UartLite485SendTask();
 
 
 
 

extern int udp_packet_send(u8 *send_buf,int length);

#endif
