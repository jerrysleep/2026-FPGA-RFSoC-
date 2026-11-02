 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

#include <sleep.h>
#include "netif/xadapter.h"
#include "platform_config.h"
#include "xil_printf.h"
#include "lwip/init.h"
#include "lwip/inet.h"
#include "stdbool.h"

#include "queue.h"
#include "globalvar.h"
#include "semphr.h"

#include "emmc.h"
#include "pl_interrupt.h"
#include "pl_gpio.h"
#include "pl_uartlite.h"
#include "ps_ttc.h"

#if LWIP_IPV6==1
#include "lwip/ip6_addr.h"
#include "lwip/ip6.h"
#else

#if LWIP_DHCP==1
#include "lwip/dhcp.h"
extern volatile int dhcp_timoutcntr;
err_t dhcp_start(struct netif *netif);
#endif
#define DEFAULT_IP_ADDRESS "192.168.2.101"
#define DEFAULT_IP_MASK "255.255.255.0"
#define DEFAULT_GW_ADDRESS "192.168.2.1"
#endif  

#ifdef XPS_BOARD_ZCU102
#ifdef XPAR_XIICPS_0_DEVICE_ID
int IicPhyReset(void);
#endif
#endif

static int complete_nw_thread;
static sys_thread_t tcp_thread_handle;
static sys_thread_t udp_thread_handle;

void print_app_header_tcp();
void print_app_header_udp();

void start_application_tcp();
void start_application_udp();
void UdpSendtoUPMTask();
void UdpSendtoUPMeasTask();
#define THREAD_STACKSIZE 1024

struct netif server_netif;


QueueHandle_t xQueue = NULL;

static TaskHandle_t xInitTask;
static TaskHandle_t xUgInitTask;
static TaskHandle_t xInitialparamsettask;
static TaskHandle_t xUartLite485SendTask;
static TaskHandle_t xUartLite485RecvTask;
static TaskHandle_t xUdpSendtoUPMTask;
static TaskHandle_t xMoniToDtTask;
static TaskHandle_t xUdpSendtoUPMeasTask;
static TaskHandle_t xEmmcWriteTargetDataTask;
static TaskHandle_t xSendTargetDataTask;

static TaskHandle_t xReadEmmcParamTask;

 
 


SemaphoreHandle_t xSemaphoreTarStore;
SemaphoreHandle_t xSemaphoreTarSend;
 
SemaphoreHandle_t xSemaphoreMeasSend;
SemaphoreHandle_t xSemaphoreReadEmmcParam;


#if LWIP_IPV6==1
static void print_ipv6(char *msg, ip_addr_t *ip)
{
	print(msg);
	xil_printf(" %s\n\r", inet6_ntoa(*ip));
}
#else

static void print_ip(char *msg, ip_addr_t *ip)
{
	xil_printf(msg);
	xil_printf("%d.%d.%d.%d\n\r", ip4_addr1(ip), ip4_addr2(ip),
				ip4_addr3(ip), ip4_addr4(ip));
}

static void print_ip_settings(ip_addr_t *ip, ip_addr_t *mask, ip_addr_t *gw)
{
	print_ip("Board IP:       ", ip);
	print_ip("Netmask :       ", mask);
	print_ip("Gateway :       ", gw);
}

static void assign_default_ip(ip_addr_t *ip, ip_addr_t *mask, ip_addr_t *gw)
{
	int err;

	xil_printf("Configuring default IP %s \r\n", DEFAULT_IP_ADDRESS);

	err = inet_aton(DEFAULT_IP_ADDRESS, ip);
	if(!err)
		xil_printf("Invalid default IP address: %d\r\n", err);

	err = inet_aton(DEFAULT_IP_MASK, mask);
	if(!err)
		xil_printf("Invalid default IP MASK: %d\r\n", err);

	err = inet_aton(DEFAULT_GW_ADDRESS, gw);
	if(!err)
		xil_printf("Invalid default gateway address: %d\r\n", err);
}
#endif  

void network_thread(void *p)
{
#if ((LWIP_IPV6==0) && (LWIP_DHCP==1))
	int mscnt = 0;
#endif

	 
	u8_t mac_ethernet_address[] = { 0x00, 0x0a, 0x35, 0x00, 0x01, 0x02 };

	xil_printf("\n\r\n\r");
	xil_printf("-----lwIP Socket Mode TCP Server Application------\r\n");

	 
	if (!xemac_add(&server_netif, NULL, NULL, NULL, mac_ethernet_address,
		PLATFORM_EMAC_BASEADDR)) {
		xil_printf("Error adding N/W interface\r\n");
		return;
	}

#if LWIP_IPV6==1
	server_netif.ip6_autoconfig_enabled = 1;
	netif_create_ip6_linklocal_address(&server_netif, 1);
	netif_ip6_addr_set_state(&server_netif, 0, IP6_ADDR_VALID);
	print_ipv6("\n\rlink local IPv6 address is:",&server_netif.ip6_addr[0]);
#endif  

	netif_set_default(&server_netif);

	 
	netif_set_up(&server_netif);

	 
	sys_thread_new("xemacif_input_thread",
			(void(*)(void*))xemacif_input_thread, &server_netif,
			THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);

	complete_nw_thread = 1;

	 
	vTaskResume(tcp_thread_handle);

#if ((LWIP_IPV6==0) && (LWIP_DHCP==1))
	dhcp_start(&server_netif);
	while (1) {
		vTaskDelay(DHCP_FINE_TIMER_MSECS / portTICK_RATE_MS);
		dhcp_fine_tmr();
		mscnt += DHCP_FINE_TIMER_MSECS;
		if (mscnt >= DHCP_COARSE_TIMER_SECS*1000) {
			dhcp_coarse_tmr();
			mscnt = 0;
		}
	}
#else
	vTaskDelete(NULL);
#endif
}

void tcp_thread(void *p)
{
#if ((LWIP_IPV6==0) && (LWIP_DHCP==1))
	int mscnt = 0;
#endif

#ifdef XPS_BOARD_ZCU102
	IicPhyReset();
#endif
	 
	lwip_init();

	 
	sys_thread_new("nw_thread", network_thread, NULL,
			THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);

	 
	if (!complete_nw_thread)
		vTaskSuspend(NULL);

#if LWIP_IPV6==0
#if LWIP_DHCP==1
	while (1) {
		vTaskDelay(DHCP_FINE_TIMER_MSECS / portTICK_RATE_MS);
		if (server_netif.ip_addr.addr) {
			xil_printf("DHCP request success\r\n");
			break;
		}
		mscnt += DHCP_FINE_TIMER_MSECS;
		if (mscnt >= 10000) {
			xil_printf("ERROR: DHCP request timed out\r\n");
			assign_default_ip(&(server_netif.ip_addr),
						&(server_netif.netmask),
						&(server_netif.gw));
			break;
		}
	}

#else
	assign_default_ip(&(server_netif.ip_addr), &(server_netif.netmask),
				&(server_netif.gw));
#endif

	print_ip_settings(&(server_netif.ip_addr), &(server_netif.netmask),
				&(server_netif.gw));
#endif  

	xil_printf("\r\n");

	 
	print_app_header_tcp();
	xil_printf("\r\n");

	 
	start_application_tcp();

	vTaskDelete(NULL);
	return;
}


void udp_thread()
{
	 
	print_app_header_udp();
	xil_printf("\r\n");

	 
	start_application_udp();

	 
	vTaskDelete(NULL);
	return;
}

 
void uginittask()
{
	TCHAR *Path = "0:/";
	FRESULT res;
	FATFS fatfs;
	UartLiteInit();  
	GpioPLInit();    

	radarparams.farbeishu=1;
	radarparams.nearbeishu=0;
	radarstate.workdone = 0;
	radarstate.emmcparamd = g_emmcpramatoPL;
}

int main()
{
EE	tcp_thread_handle = sys_thread_new("tcp_thread", tcp_thread, 0,
			THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);
	udp_thread_handle = sys_thread_new("udp_thread", udp_thread, 0,
			THREAD_STACKSIZE, DEFAULT_THREAD_PRIO);

	xSemaphoreTarStore = xSemaphoreCreateBinary();
	xSemaphoreTarSend = xSemaphoreCreateBinary();
	 
	xSemaphoreMeasSend = xSemaphoreCreateBinary();
	xSemaphoreReadEmmcParam = xSemaphoreCreateBinary();

	xTaskCreate(int_init_task,(const char*)"init",configMINIMAL_STACK_SIZE,NULL,tskIDLE_PRIORITY+1,&xInitTask);

	xTaskCreate(uginittask,(const char*)"uginit",configMINIMAL_STACK_SIZE,NULL,tskIDLE_PRIORITY+1,&xUgInitTask);

	xTaskCreate(initialparamsettask,(const char*)"initialparamset",configMINIMAL_STACK_SIZE+2000,NULL,tskIDLE_PRIORITY+1,&xInitialparamsettask);

	xTaskCreate(UartLite485RecvTask,(const char*)"UartLite485Recv",configMINIMAL_STACK_SIZE,NULL,tskIDLE_PRIORITY+1,&xUartLite485RecvTask);

	xTaskCreate(UartLite485SendTask,(const char*)"UartLite485Send",configMINIMAL_STACK_SIZE,NULL,tskIDLE_PRIORITY+1,&xUartLite485SendTask);

	xTaskCreate(UdpSendtoUPMTask,(const char*)"UdpSendtoUPM",configMINIMAL_STACK_SIZE,NULL,tskIDLE_PRIORITY+1,&xUdpSendtoUPMTask);

	xTaskCreate(readEmmcParamTask,(const char*)"readEmmcParamTask",configMINIMAL_STACK_SIZE+1000,NULL,tskIDLE_PRIORITY+1,&xReadEmmcParamTask);

 

	xTaskCreate(UdpSendtoUPMeasTask,(const char*)"UdpSendtoUPMeas",configMINIMAL_STACK_SIZE,NULL,tskIDLE_PRIORITY+3,&xUdpSendtoUPMeasTask);

	xTaskCreate(EmmcWriteTargetDataTask,(const char*)"EmmcWriteTargetData",configMINIMAL_STACK_SIZE*4,NULL,tskIDLE_PRIORITY+1,&xEmmcWriteTargetDataTask);

	xTaskCreate(SendTargetDataTask,(const char*)"SendTargetData",configMINIMAL_STACK_SIZE*3,NULL,tskIDLE_PRIORITY+2,&xSendTargetDataTask);


 
 
 

	vTaskStartScheduler();
	while(1);

	return 0;
}
