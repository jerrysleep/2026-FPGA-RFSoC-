#include "pl_interrupt.h"
#include "bram.h"
#include "xtime_l.h"
#include "xil_printf.h"
#include "ps_ttc.h"


 
void IntcTypeSetup(XScuGic *InstancePtr,int intID,int intType)
{
	int mask;

	intType &=INT_TYPE_MASK;
	mask = XScuGic_DistReadReg(InstancePtr,INT_CFGO_OFFSET+(intID/16)*4);
	mask &= ~(INT_TYPE_MASK << (intID%16)*2);
	mask |= intType << ((intID%16)*2);

	XScuGic_DistWriteReg(InstancePtr,INT_CFGO_OFFSET+(intID/16)*4,mask);
}

 
void SW1_intr_Handler()
{
 
 

	BramReadAndProcMeasData();

 
 
 
 
 
}

 
void SW2_intr_Handler()
{
	BramReadStateAndTime();
}


 
void SW3_intr_Handler()
{
 
 
}


 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

int IntInit()
{
    int status;

    status = XScuGic_Connect(&xInterruptController,
                             SW1_INT_ID,
                             (Xil_ExceptionHandler)SW1_intr_Handler,
                             (void*)1);
    if(status != XST_SUCCESS)
        return XST_FAILURE;

    status = XScuGic_Connect(&xInterruptController,
                             SW2_INT_ID,
                             (Xil_ExceptionHandler)SW2_intr_Handler,
                             (void*)2);
    if(status != XST_SUCCESS)
        return XST_FAILURE;

    status = XScuGic_Connect(&xInterruptController,
                             SW3_INT_ID,
                             (Xil_ExceptionHandler)SW3_intr_Handler,
                             (void*)3);
    if(status != XST_SUCCESS)
        return XST_FAILURE;


     
    status = Ttc100usConfig();

    if(status != XST_SUCCESS)
        return XST_FAILURE;

    status = XScuGic_Connect(&xInterruptController,
                             TTC_INTR_ID,
                             (Xil_ExceptionHandler)TtcIntrHandler,
                             &TtcTimer);
    if(status != XST_SUCCESS)
        return XST_FAILURE;


     
    XScuGic_SetPriorityTriggerType(&xInterruptController,
                                   SW1_INT_ID,
                                   0x90,
                                   0x03);

    XScuGic_SetPriorityTriggerType(&xInterruptController,
                                   SW2_INT_ID,
                                   0x90,
                                   0x03);

    XScuGic_SetPriorityTriggerType(&xInterruptController,
                                   SW3_INT_ID,
                                   0x90,
                                   0x03);

     
    XScuGic_SetPriorityTriggerType(&xInterruptController,
                                   TTC_INTR_ID,
                                   0xA0,
                                   0x03);


     
    XScuGic_Enable(&xInterruptController, SW1_INT_ID);
    XScuGic_Enable(&xInterruptController, SW2_INT_ID);
    XScuGic_Enable(&xInterruptController, SW3_INT_ID);
    XScuGic_Enable(&xInterruptController, TTC_INTR_ID);


     
    XTtcPs_Start(&TtcTimer);

    return XST_SUCCESS;
}
 
void int_init_task()
{
	IntInit();       
}
