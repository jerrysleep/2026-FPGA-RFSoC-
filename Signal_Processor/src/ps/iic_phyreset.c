 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

#include <stdio.h>

#include "xparameters.h"
#include "xil_printf.h"

#ifdef XPS_BOARD_ZCU102
#ifdef XPAR_XIICPS_0_DEVICE_ID
#include "xiicps.h"

#define BUF_LEN		10U

#define IOEXPANDER1_ADDR		0x20U

#define IIC_SCLK_RATE_IOEXP		400000

#define CMD_CFG_0_REG		0x06U
#define CMD_OUTPUT_0_REG	0x02U
#define DATA_OUTPUT			0x0U

#define DATA_COMMON_CFG		0xE0U
#define DATA_GT_0000_CFG	0x00U

XIicPs I2c0InstancePtr;

int IicPhyReset(void)
{

	u8 WriteBuffer[BUF_LEN] = {0};
	XIicPs_Config *I2c0CfgPtr;
	int Status = XST_SUCCESS;

	 
	I2c0CfgPtr = XIicPs_LookupConfig(XPAR_XIICPS_0_DEVICE_ID);
	if (I2c0CfgPtr == NULL) {
		Status = XST_FAILURE;
		return Status;
	}

	Status = XIicPs_CfgInitialize(&I2c0InstancePtr, I2c0CfgPtr,
			I2c0CfgPtr->BaseAddress);
	if (Status != XST_SUCCESS) {
		Status = XST_FAILURE;
		return Status;
	}

	 
	XIicPs_SetSClk(&I2c0InstancePtr, IIC_SCLK_RATE_IOEXP);

	 
	WriteBuffer[0] = CMD_CFG_0_REG;
	WriteBuffer[1] = DATA_OUTPUT;
	Status = XIicPs_MasterSendPolled(&I2c0InstancePtr,
			WriteBuffer, 2, IOEXPANDER1_ADDR);
	if (Status != XST_SUCCESS) {
		Status = XST_FAILURE;
		return Status;
	}

	 
	while (XIicPs_BusIsBusy(&I2c0InstancePtr));

	 
 
 
 
 
	WriteBuffer[0] = CMD_OUTPUT_0_REG;
	 
	WriteBuffer[1] = DATA_COMMON_CFG | DATA_GT_0000_CFG;

	 
	Status = XIicPs_MasterSendPolled(&I2c0InstancePtr,
			WriteBuffer, 2, IOEXPANDER1_ADDR);
	if (Status != XST_SUCCESS) {
		Status = XST_FAILURE;
		return Status;
	}

	 
	while (XIicPs_BusIsBusy(&I2c0InstancePtr));

	xil_printf("IIC PHY reset on ZCU102 successful \n\r");
	return Status;
}
#endif
#endif
