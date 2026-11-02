#include "pl_gpio.h"

XGpio Gpio;
XGpioPs GpioPs;
 
 
 
 
 
 
 
 
 
 
void GpioPLInit()
{
	int XStatus;
	XStatus = XGpio_Initialize(&Gpio,XPAR_AXI_GPIO_0_DEVICE_ID);
	if(XStatus!=XST_SUCCESS)
	{
		printf("GPIO INIT FAILED \n\r");
		return;
	}
	XGpio_SetDataDirection(&Gpio,1,0x0); 
}

void delay(int times)
{
	volatile int i;
	for(i=0;i<times;i++)
	{}
}


 
 
void Gpio485RFSendState()
{
	int valread = 0;

	valread = XGpio_DiscreteRead(&Gpio,1);
	valread = (valread & ~0x03) | 0x03;

	XGpio_DiscreteWrite(&Gpio , 1 , valread);
	delay(500);
}

 
 
void Gpio485RFRecvState()
{
	int valread = 0;

	valread = XGpio_DiscreteRead(&Gpio,1);
	valread = valread & 0xfffc;

	XGpio_DiscreteWrite(&Gpio , 1 , valread);
}

