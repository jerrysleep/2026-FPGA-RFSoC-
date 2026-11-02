#ifndef PL_INTERRUPT_H
#define PL_INTERRUPT_H

#include "xparameters.h"
#include "xscugic.h"
#include "freertos.h"
#include "globalvar.h"

#define INTC_DEVICE_ID     XPAR_SCUGIC_SINGLE_DEVICE_ID

#define INT_CFGO_OFFSET    0x00000C00
#define SW1_INT_ID         121
#define SW2_INT_ID         122
#define SW3_INT_ID         123

#define INT_TYPE_RISING_EDGE  0x03
#define INT_TYPE_HIGHLEVEL    0x01
#define INT_TYPE_MASK         0x03

extern XScuGic xInterruptController;

int IntInit();
void int_init_task();

#endif
