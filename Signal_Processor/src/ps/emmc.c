#include "emmc.h"
#include "bram.h"

 
static char ParametersFileName[32] = "Test.bin";
static char *EMMC_File;


static FIL fil;		 
 

u8 DestinationAddress[256] __attribute__ ((aligned(32)));
 

static char FileName[32] = "Test.bin";
static char *EMMC_File;

#define PARAMSNUMS    57
 
uint16_t CMDTYPE[PARAMSNUMS]={
0x0014,
0x0018,
0x001C,
0x0020,
0x0024,
0x0028,
0x002C,
0x0030,
0x0034,
0x0038,
0x003C,
0x0040,
0x0044,
0x0048,
0x004C,
0x0050,
0x0054,
0x0058,
0x005C,
0x0060,
0x0064,
0x0068,
0x006C,
0x0070,
0x0074,
0x0078,
0x007C,
0x0080,
0x0084,
0x0088,
0x008C,
0x0090,
 
 
0x009C,
0x00A0,
0x00A4,
 
 
0x00B0,
0x00B4,
0x00B8,
0x00BC,
0x00C0,
0x00C4,
0x00C8,
0x00CC,
0x00D0,
0x00D4,
0x00D8,
0x00DC,
0x00E0,
0x00E4,
0x00E8,
0x00EC,
0x00F0,
0x00F4,
0x00F8,
 
0x0100,
0x0104,
0x0108
};

static FATFS g_fatfs;
int g_emmcMounted = 0;

FRESULT Emmc_EnsureMounted()
{
	FRESULT fr;
	BYTE work[FF_MAX_SS];
	if(g_emmcMounted)
	{
		return FR_OK;
	}

	fr = f_mount(&g_fatfs,"0:/",1);
	if(fr == FR_OK)
	{
		g_emmcMounted = 1;
	}
	else
	{
		if(fr == FR_NO_FILESYSTEM)
		{
			 
			fr = f_mkfs("0:/", FM_FAT32, 0, work, sizeof work);
			if (fr != FR_OK) {
				return XST_FAILURE;
			}
		}
		g_emmcMounted = 0;
	}

	return fr;
}


 
 
int EmmcParamFileWrite(uint16_t cmdType,uint8_t*data,uint32_t size)
{
	FRESULT Res;
	FIL file;
	char filename[32];
	uint32_t bytes_written;
	uint32_t bytes_read;
	BYTE work[FF_MAX_SS];
	int i=0;
	uint8_t readbuff[100];
	snprintf(filename,sizeof(filename),"%d.bin",cmdType);

	TCHAR *Path = "0:/";

	Res = Emmc_EnsureMounted();

	if(Res!=FR_OK)
	{
		return 1;
	}

	Res = f_open(&file, filename, FA_CREATE_ALWAYS | FA_WRITE | FA_READ);
	if (Res!=FR_OK)
	{
		if(Res == FR_NO_FILESYSTEM)
		{
			 
			Res = f_mkfs(Path, FM_FAT32, 0, work, sizeof work);
			if (Res != FR_OK) {
				return XST_FAILURE;
			}
		}
		else
		{
			return Res;
		}
	}

	Res = f_lseek(&file, 0);
	if (Res!=FR_OK)
	{
		return Res;
	}

	Res = f_write(&file, data, size,&bytes_written);
	if (Res!=FR_OK || bytes_written!=size)
	{
		f_close(&file);
		return (Res!=FR_OK)?Res:FR_DISK_ERR;
	}

	Res = f_lseek(&file, 0);
	if (Res)
	{
		return XST_FAILURE;
	}


	Res = f_read(&file,readbuff,size,&bytes_read);
	if (Res!=FR_OK || size!=bytes_read)
	{
		f_close(&file);
		return (Res!=FR_OK)?Res:FR_DISK_ERR;
	}
	 
	for(i=0;i<size;i++)
	{
		if(readbuff[i] != data[i])
		{
			f_close(&file);
			return FR_DISK_ERR;
		}
	}

	f_close(&file);
	return Res;
}

 
int EmmcParamFileReadAndToPL(uint16_t cmdType)
{
	FRESULT Res;
	FIL file;
	 
	char filename[32];
	uint8_t readbuff[30];
	uint32_t bytes_read,filesize,paramters;
	uint16_t paramaddr;

	snprintf(filename,sizeof(filename),"%d.bin",cmdType);

	Res = Emmc_EnsureMounted();
	if(Res!=FR_OK)
	{
		return 1;
	}
	Res = f_open(&file, filename,FA_READ);
	if (Res!=FR_OK)
	{
		return Res;
	}

	filesize = f_size(&file);
	if(filesize>30)
	{
		return XST_FAILURE;
	}

	Res = f_read(&file,readbuff,filesize,&bytes_read);
	if (Res!=FR_OK || filesize!=bytes_read)
	{
		f_close(&file);
		return (Res!=FR_OK)?Res:FR_DISK_ERR;
	}

	f_close(&file);

	 
	if(readbuff[0] == 0xAB && readbuff[1] == 0x90)
	{
		paramaddr = readbuff[4]<<8 | readbuff[5];

		paramters = readbuff[6] << 24 |
					readbuff[7] << 16 |
					readbuff[8] << 8  |
					readbuff[9];

		if(paramaddr == 0x0070)  
		{
			radarparams.adcdelay = paramters;
		}
		else if(paramaddr == 0x005C) 
		{
			radarparams.rfmodulationwidth = paramters;
		}

		BramParamSetToPL_32(paramaddr,paramters);

		 
		switch(cmdType)
		{
			case 0x14:  
				FreqCode = paramters;
				break;
			case 0xC8: 
				g_tp_near = paramters/250e6;
				break;
			case 0xCC: 
				g_tr_near = paramters/250e6;
				break;
			case 0xE8: 
				g_tp_far = paramters/250e6;
				break;
			case 0xEC: 
				g_tr_far = paramters/250e6;
				break;
		}
	}
	else
	{
		return XST_FAILURE;
	}

	return Res;
}

 
int EmmcParamFileRead(uint16_t cmdType,uint8_t *readbuff)
{
	FRESULT Res;
	FIL file;
	char filename[32];
	uint32_t bytes_read,filesize,paramters;
	uint16_t paramaddr;

	snprintf(filename,sizeof(filename),"%d.bin",cmdType);

	Res = Emmc_EnsureMounted();
	if(Res!=FR_OK)
	{
		return 1;
	}
	Res = f_open(&file, filename,FA_READ);
	if (Res!=FR_OK)
	{
		return Res;
	}

	filesize = f_size(&file);
	if(filesize>100)
	{
		return XST_FAILURE;
	}

	Res = f_read(&file,readbuff,filesize,&bytes_read);
	if (Res!=FR_OK || filesize!=bytes_read)
	{
		f_close(&file);
		return (Res!=FR_OK)?Res:FR_DISK_ERR;
	}

	f_close(&file);

	if(readbuff[0] == 0xAB && readbuff[1] == 0x90)
	{
		paramaddr = readbuff[4]<<8 | readbuff[5];

		paramters = readbuff[6] << 24 |
					readbuff[7] << 16 |
					readbuff[8] << 8  |
					readbuff[9];

		if(paramaddr == 0x0070)  
		{
			radarparams.adcdelay = paramters;
		}
		else if(paramaddr == 0x005C) 
		{
			radarparams.rfmodulationwidth = paramters;
		}
	}
	else if(readbuff[0] == 0xAF && readbuff[1] == 0xB4)
	{

	}
	else
	{
		return XST_FAILURE;
	}

	return Res;
}

 
int EmmcReadAndWriteParameters(u8 *SourceAddress)
{
	FRESULT Res;
	UINT NumBytesRead;
	UINT NumBytesWritten;
	u32 BuffCnt;
	BYTE work[FF_MAX_SS];
	u32 FileSize = (8*1024);

 
 
 
 
 
 
 
 

	 
 
 
 
	 
 
 
 
 

	 
 
 
 
 
 
	EMMC_File = (char *)ParametersFileName;

	Res = f_open(&fil, EMMC_File, FA_CREATE_ALWAYS | FA_WRITE | FA_READ);
	if (Res) {
		return XST_FAILURE;
	}

	 
 
 
	Res = f_lseek(&fil, 0);
	if (Res) {
		return XST_FAILURE;
	}

	 
 
 
	Res = f_write(&fil, (const void*)SourceAddress, FileSize,
			&NumBytesWritten);
	if (Res) {
		return XST_FAILURE;
	}

	 
 
 
	Res = f_lseek(&fil, 0);
	if (Res) {
		return XST_FAILURE;
	}


	 
 
 
	Res = f_read(&fil, (void*)DestinationAddress, FileSize,
			&NumBytesRead);
	if (Res) {
		return XST_FAILURE;
	}


	 
 
 
	for(BuffCnt = 0; BuffCnt < FileSize; BuffCnt++){
		if(SourceAddress[BuffCnt] != DestinationAddress[BuffCnt]){
			return XST_FAILURE;
		}
	}

	 
 
 
	Res = f_close(&fil);
	if (Res) {
		return XST_FAILURE;
	}

	return XST_SUCCESS;
}

int firstwritetarfile = -1;

 
static uint8_t buffer[8192];
int EmmcWriteTargetFile(uint16_t cmdType,uint8_t*data,uint32_t size )
{
	FRESULT res;
	FIL file;
	uint32_t bw;
	uint32_t write_size;
	uint32_t total_written = 0;
	char filename[32];

	uint32_t TOTAL_SIZE = size;
	snprintf(filename,sizeof(filename),"%d.bin",cmdType);

 
 
 
 
 
 
 
 

	if(firstwritetarfile == -1)
	{
		firstwritetarfile = 1;
	}

	if(firstwritetarfile == 1)
	{
		res = f_open(&file,filename,FA_CREATE_ALWAYS | FA_WRITE);
		firstwritetarfile = 0;
		int filesize = f_size(&file);
		if(filesize!=0)
		{
			xil_printf("error");
		}
	}
	else
	{
		res = f_open(&file,filename,FA_OPEN_ALWAYS | FA_WRITE); 
	}

	if (res != FR_OK)
	{
		return res;
	}

	 
	if(TarStoreCntCum>29400000)
	{
		f_lseek(&file,0);
		TarStoreCntCum = 0;
	}
	else
	{
		int seekindex = TarStoreCntCum-size;
		f_lseek(&file,seekindex);
	}

	while(total_written<TOTAL_SIZE)
	{
		if(TOTAL_SIZE-total_written<WRITE_CHUNK)
		{
			write_size = TOTAL_SIZE-total_written;
		}
		else
		{
			write_size = WRITE_CHUNK;
		}

		for(uint32_t i=0;i<write_size;i++)
		{
			buffer[i] = data[i+total_written];
		}
		res = f_write(&file,buffer,write_size,&bw);

		if (res!=FR_OK || bw != write_size)
		{
			f_close(&file);
			return res;
		}

		 
	 

		total_written+=bw;
	}

	f_close(&file);

	return res;
}


 
void EmmcWriteTargetDataTask()
{
	uint16_t cmdType = 0xFF11;

	for(;;)
	{
		if(xSemaphoreTake(xSemaphoreTarStore,portMAX_DELAY)==pdTRUE)
		{
			EmmcWriteTargetFile(cmdType,TargetStorebuff,TargetStoreCnt);
			TargetStoreCnt = 0;
		}
	}
}

 
int EmmcReadTargetData(uint32_t *fileSize)
{
	FRESULT Res;
	FIL file;
 
	char filename[32];

	uint32_t bytes_read,filesize;

	uint16_t cmdType = 0xFF11;

	snprintf(filename,sizeof(filename),"%d.bin",cmdType);

 
 
 
 
 
 
 

	Res = f_open(&file, filename,FA_READ);
	if (Res!=FR_OK)
	{
		return Res;
	}

	filesize = f_size(&file);

	fileSize[0] = filesize;

	Res = f_read(&file,TargetReadbuff,filesize,&bytes_read);
	if (Res!=FR_OK || filesize!=bytes_read)
	{
		f_close(&file);
		return (Res!=FR_OK)?Res:FR_DISK_ERR;
	}

	f_close(&file);

	return Res;
}
u8 g_sendbuf[1500];
 
void SendTargetDataTask()
{
	FRESULT Res;
	uint32_t fileSize[1];
	int sendtimes = 24000;
	volatile int offset = 0;
	for(;;)
	{
		if(xSemaphoreTake(xSemaphoreTarSend,portMAX_DELAY)==pdTRUE)
		{
			Res = EmmcReadTargetData(fileSize);

			if(Res!=FR_OK)  
			{
				u8 sendbuf[5]={0x7F,0x37,0x00,0x01,0xFF};
				udp_packet_send(sendbuf,5);
			}
			else
			{
				offset = 0;
				sendtimes = fileSize[0]/1225+1;
				for(int i=0;i<sendtimes;i++)  
				{
					memcpy(g_sendbuf,TargetReadbuff+offset,1225);
					offset= offset+1225;
					udp_packet_send(g_sendbuf,1225);
					usleep(130);
				}
			}
		}
	}
}


 
void noPulseCompressCmdSet()
{
	u16 paramaddr;
	u32 paramters;
	 
	paramaddr = 0x0108;
	paramters = 0x00000000;
	BramParamSetToPL_32(paramaddr,paramters);

	 
	paramaddr = 0x0070;
	paramters = radarparams.adcdelay+radarparams.rfmodulationwidth;
	BramParamSetToPL_32(paramaddr,paramters);
}

 
void PulseCompressCmdSet()
{
	u16 paramaddr;
	u32 paramters;

	paramaddr = 0x0108;
	paramters = 0xFFFFFFFF;
	BramParamSetToPL_32(paramaddr,paramters);

	 
	paramaddr = 0x0070;
	paramters = radarparams.adcdelay;
	BramParamSetToPL_32(paramaddr,paramters);
}


int g_emmcpramatoPL = 0;
 
void initialparamsettask()
{
	uint16_t cmdType;
	int i= 0;
	u8 send_buff[10];
	u8 readbuff[100];
	FRESULT Res;
	bool right=TRUE;

	send_buff[0] = 0xAB;
	send_buff[1] = 0x90;
	send_buff[2] = 0x00;  
	send_buff[3] = 0x00;  

	while(1)
	{
		if(radarstate.workdone == 1)
		{
			for(i=0;i<PARAMSNUMS;i++)
			{
				cmdType = CMDTYPE[i];
				Res = EmmcParamFileReadAndToPL(cmdType);
				if(Res !=FR_OK)
				{
					send_buff[4] = cmdType>>8 & 0xff;
					send_buff[5] = cmdType & 0xff;
					send_buff[6] = 0xff;                  
					udp_packet_send_custom(send_buff,7);  
					right = FALSE;
				}
			}

			cmdType = 0xAFB4;
			Res = EmmcParamFileRead(cmdType,readbuff);
			if(Res == FR_OK)
			{
				float ft[8];
				for(int i=0;i<8;i++)
				{
					u32 temp;
					memcpy(&temp,readbuff+2+i*4,4);
					temp = ntohl(temp);
					memcpy(&ft[i],&temp,4);
				}
				for(int i=0;i<4;i++)
				{
					FeederPhaseComp_1[i] = ft[i]/180*PI;
					FeederPhaseComp_2[i] = ft[i+4]/180*PI;
				}
				udp_packet_send_custom(readbuff,34);
			}

			if(right)
			{
				 
				send_buff[4] = 0xAA;
				send_buff[5] = 0xAA;
				send_buff[6] = 0x00;
				udp_packet_send_custom(send_buff,7);

				 
				noPulseCompressCmdSet();

				 
				uint16_t paramaddr = 0x0008;
				uint32_t paramters = 0xFFFFFFFF;
				BramParamSetToPL_32(paramaddr,paramters);

				 
				paramaddr = 0x00FC;
				paramters = 0x01;
				BramParamSetToPL_32(paramaddr,paramters);

				vTaskDelay(pdMS_TO_TICKS(10000)); 

				paramaddr = 0x00FC;
				paramters = 0x02;
				BramParamSetToPL_32(paramaddr,paramters);

				PulseCompressCmdSet();
			}

			break;
		}
		else
		{
			vTaskDelay(pdMS_TO_TICKS(15000)); 
		}
	}
}



 
volatile int pcnts = 0;
void readEmmcParamTask()
{
	int i=0;
	uint16_t cmdType = 0;
	FRESULT Res;
	u8 send_buff[100];
	uint8_t readbuff[100];

	send_buff[0] = 0xAB;
	send_buff[1] = 0x90;
	send_buff[2] = 0x00;  
	send_buff[3] = 0x00;  

	for(;;)
	{
		if(xSemaphoreTake(xSemaphoreReadEmmcParam,portMAX_DELAY)==pdTRUE)
		{
			for(i=0;i<PARAMSNUMS;i++)
			{
				cmdType = CMDTYPE[i];
				Res = EmmcParamFileRead(cmdType,readbuff);
				if(Res !=FR_OK)
				{
					send_buff[4] = cmdType>>8 & 0xff;
					send_buff[5] = cmdType & 0xff;
					send_buff[6] = 0xff;                  
					udp_packet_send_custom(send_buff,7);  
				}
				else
				{
					udp_packet_send_custom(readbuff,30);
					pcnts++;
				}
			}
			cmdType = 0xAFB4;
			Res = EmmcParamFileRead(cmdType,readbuff);
			if(Res == FR_OK)
			{
				float ft[8];
				for(int i=0;i<8;i++)
				{
					u32 temp;
					memcpy(&temp,readbuff+2+i*4,4);
					temp = ntohl(temp);
					memcpy(&ft[i],&temp,4);
				}
				for(int i=0;i<4;i++)
				{
					FeederPhaseComp_1[i] = ft[i]/180*PI;
					FeederPhaseComp_2[i] = ft[i+4]/180*PI;
				}

				udp_packet_send_custom(readbuff,34);
			}
			else  
			{
				readbuff[2] = 2;
				readbuff[3] = 2;
				readbuff[4] = 2;
				readbuff[5] = 2;
				readbuff[6] = 2;
				udp_packet_send_custom(readbuff,34);
			}

		}
	}
}

