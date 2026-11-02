#include "pl_uartlite.h"

XUartLite UartLite0;
XUartLite UartLite1;
XUartLite UartLite2;

 


struct RF485State rf485state;

 
 
 
 
int UartLiteInit()
{
	int Status;
	Status = XUartLite_Initialize(&UartLite0,XPAR_UARTLITE_0_DEVICE_ID);
	if (Status != XST_SUCCESS)
	{
		xil_printf("UARTLite0 initialization failed\r\n");
		return XST_FAILURE;
	}
 
 
 
 
 
 
 
 
 
 
 
 

	xil_printf("initialize command dispatcher successfully\r\n");
	return XST_SUCCESS;
}


 
void UartLite485SendTask()
{
	for(;;)
	{
		u8 sendbuff[5];
		sendbuff[0] = 0xEB;
		sendbuff[1] = 0x04;
		sendbuff[2] = 0xA1;
		sendbuff[3] = 0x00;
		sendbuff[4] = 0x5B;

		UartLite485Send(sendbuff,5);

		vTaskDelay(pdMS_TO_TICKS(10000)); 
	}

}



 
void UartLite485RecvTask()
{
	int recvbytes = 0;
	u8 recvbuff[10];
	for(;;)
	{
		recvbuff[recvbytes] = XUartLite_RecvByte(UartLite0.RegBaseAddress);
		if(recvbuff[0] == 0xEB)
		{
			recvbytes++;
			if(recvbuff[1] == 0x04 || recvbuff[1] == 0x05)   
			{
				if(recvbytes>=5)
				{
					udp_packet_send(recvbuff,5);  
					recvbytes = 0;
				}
			}
			else if(recvbuff[1] == 0x06)  
			{
				if(recvbytes>=7)
				{
					udp_packet_send(recvbuff,7);  
					recvbytes = 0;

					u8 lock_bit = (recvbuff[3] == 0x00) ? 1 : 0;
					u8 power_bit = 1;
					int8_t temp = (int8_t)recvbuff[5];
					u8 temp_bit = (temp >= -30 && temp <= 65) ? 1 : 0;

					 
					RFState = ((lock_bit << 2) | (power_bit << 1) | temp_bit) & 0x07;

					rf485state.lockindic = recvbuff[3];
					rf485state.power= recvbuff[4];
					rf485state.temp= recvbuff[5];
				}
			}
		}
	}
}

 
void UartLite485Send(u8 *buff,int length)
{
	 
	Gpio485RFSendState();

	XUartLite_Send(&UartLite0,buff,length);
	while(XUartLite_IsSending(&UartLite0)){}

	 
	Gpio485RFRecvState();
}

 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
