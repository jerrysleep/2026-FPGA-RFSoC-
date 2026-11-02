#include "ps_ttc.h"
#include "bram.h"
XTtcPs TtcTimer;
extern XScuGic xInterruptController;    

volatile uint32_t g_ttc100usCnt = 0;
SemaphoreHandle_t xTtcSem = NULL;

int addr = 0;
 
void TtcIntrHandler(void *CallBackRef)
{
    XTtcPs *TtcPtr = (XTtcPs *)CallBackRef;
    BaseType_t xHigherPriorityTaskWoken = pdFALSE;

    u32 StatusEvent;

    StatusEvent = XTtcPs_GetInterruptStatus(TtcPtr);
    XTtcPs_ClearInterruptStatus(TtcPtr, StatusEvent);

    if (StatusEvent & XTTCPS_IXR_INTERVAL_MASK)
    {
       
    	 

		addr = 0;
		if(radarstate.target == 1)
		{
			for(int i=0;i<5;i++)
			{
				Xil_Out32(XPAR_BRAM_2_BASEADDR+addr,sendresultdt_target[i]);
				addr+=4;
				usleep(1);
			}
		}
		else
		{
			for(int i=0;i<5;i++)
			{
				Xil_Out32(XPAR_BRAM_2_BASEADDR+addr,sendresultdt_state[i]);
				addr+=4;
				usleep(1);
			}
		}
    }

     
}

 
int Ttc100usConfig(void)
{
    int Status;
    XTtcPs_Config *TtcConfig;
    u16 Interval;
    u8 Prescaler;

    TtcConfig = XTtcPs_LookupConfig(TTC_DEVICE_ID);
    if (TtcConfig == NULL)
        return XST_FAILURE;

    Status = XTtcPs_CfgInitialize(&TtcTimer,
                                  TtcConfig,
                                  TtcConfig->BaseAddress);
    if (Status != XST_SUCCESS)
        return XST_FAILURE;

    XTtcPs_SetOptions(&TtcTimer,
                      XTTCPS_OPTION_INTERVAL_MODE |
                      XTTCPS_OPTION_WAVE_DISABLE);

    XTtcPs_CalcIntervalFromFreq(&TtcTimer,
                                TTC_FREQ_HZ,
                                &Interval,
                                &Prescaler);

    XTtcPs_SetInterval(&TtcTimer, Interval);
    XTtcPs_SetPrescaler(&TtcTimer, Prescaler);

    XTtcPs_EnableInterrupts(&TtcTimer, XTTCPS_IXR_INTERVAL_MASK);

    return XST_SUCCESS;
}


 
void Ttc100usTask(void *pvParameters)
{
    while (1)
    {
        if (xSemaphoreTake(xTtcSem, portMAX_DELAY) == pdTRUE)
        {
             
             
        }
    }
}





