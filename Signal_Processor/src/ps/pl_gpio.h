#ifndef PL_GPIO_H
#define PL_GPIO_H

#include "xparameters.h"
#include "xscugic.h"
#include "freertos.h"
#include "xgpio.h"
#include "xgpiops.h"
#include "globalvar.h"


void GpioPLInit();
void Gpio485RFRecvState();
void Gpio485RFSendState();

#endif
