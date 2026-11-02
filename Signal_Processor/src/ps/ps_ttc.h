
#include "xparameters.h"
#include "xttcps.h"
#include "xscugic.h"
#include "xil_exception.h"

#include "FreeRTOS.h"
#include "semphr.h"
#include "task.h"

#define TTC_DEVICE_ID      XPAR_XTTCPS_1_DEVICE_ID
#define TTC_INTR_ID        XPAR_XTTCPS_1_INTR
#define TTC_FREQ_HZ        10000      

extern XTtcPs TtcTimer;
extern SemaphoreHandle_t xTtcSem;
int Ttc100usConfig(void);
void TtcIntrHandler(void *CallBackRef);
