 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

 

#include "udp_perf_server.h"
#include "globalvar.h"
#include "bram.h"
#include "pl_uartlite.h"
#include "emmc.h"
#include "dataprocess.h"

extern struct netif server_netif;
static struct perf_stats server;

static struct sockaddr_in clientaddr;


 
#define REPORT_INTERVAL_TIME (INTERIM_REPORT_INTERVAL * 1000)

int udp_packet_send(u8 *send_buf,int length);

void print_app_header_udp(void)
{
	xil_printf("UDP server listening on port %d\r\n",
			UDP_CONN_PORT);
	xil_printf("On Host: Run $iperf -c %s -i %d -t 300 -u -b <bandwidth>\r\n",
			inet_ntoa(server_netif.ip_addr),
			INTERIM_REPORT_INTERVAL);

}

static void print_udp_conn_stats(struct sockaddr_in from)
{
	xil_printf("[%3d] local %s port %d connected with ",
			server.client_id, inet_ntoa(server_netif.ip_addr),
			UDP_CONN_PORT);

	xil_printf("%s port %d\r\n", inet_ntoa(from.sin_addr),
			ntohs(from.sin_port));

	xil_printf("[ ID] Interval\t     Transfer     Bandwidth\t");
	xil_printf("    Lost/Total Datagrams\n\r");
}

static void stats_buffer(char* outString,
		double data, enum measure_t type)
{
	int conv = KCONV_UNIT;
	const char *format;
	double unit = 1024.0;

	if (type == SPEED)
		unit = 1000.0;

	while (data >= unit && conv <= KCONV_GIGA) {
		data /= unit;
		conv++;
	}

	 
	if (data < 9.995) {  
		format = "%4.2f %c";  
	} else if (data < 99.95) {  
		format = "%4.1f %c";  
	} else {
		format = "%4.0f %c";  
	}
	sprintf(outString, format, data, kLabel2[conv]);
}


 
static void udp_conn_report(u64_t diff,
		enum report_type report_type)
{
	u64_t total_len, cnt_datagrams, cnt_dropped_datagrams, total_packets;
	u32_t cnt_out_of_order_datagrams;
	double duration, bandwidth = 0;
	char data[16], perf[16], time[64], drop[64];

	if (report_type == INTER_REPORT) {
		total_len = server.i_report.total_bytes;
		cnt_datagrams = server.i_report.cnt_datagrams;
		cnt_dropped_datagrams = server.i_report.cnt_dropped_datagrams;
	} else {
		server.i_report.last_report_time = 0;
		total_len = server.total_bytes;
		cnt_datagrams = server.cnt_datagrams;
		cnt_dropped_datagrams = server.cnt_dropped_datagrams;
		cnt_out_of_order_datagrams = server.cnt_out_of_order_datagrams;
	}

	total_packets = cnt_datagrams + cnt_dropped_datagrams;
	 
 
 
	duration = diff / 1000.0;  
	if (duration)
		bandwidth = (total_len / duration) * 8.0;

	stats_buffer(data, total_len, BYTES);
	stats_buffer(perf, bandwidth, SPEED);
	 
 
 
 
	sprintf(time, "%4.1f-%4.1f sec",
			(double)server.i_report.last_report_time,
			(double)(server.i_report.last_report_time + duration));
	sprintf(drop, "%4llu/%5llu (%.2g%%)", cnt_dropped_datagrams,
			total_packets,
			(100.0 * cnt_dropped_datagrams)/total_packets);
	xil_printf("[%3d] %s  %sBytes  %sbits/sec  %s\n\r", server.client_id,
			time, data, perf, drop);

	if (report_type == INTER_REPORT) {
		server.i_report.last_report_time += duration;
	} else if ((report_type != INTER_REPORT) && cnt_out_of_order_datagrams) {
		xil_printf("[%3d] %s  %u datagrams received out-of-order\n\r",
				server.client_id, time,
				cnt_out_of_order_datagrams);
	}
}


static void reset_stats(void)
{
	server.client_id++;
	 
	server.start_time = sys_now();
	server.end_time = 0;  
	server.total_bytes = 0;
	server.cnt_datagrams = 0;
	server.cnt_dropped_datagrams = 0;
	server.cnt_out_of_order_datagrams = 0;
	server.expected_datagram_id = 0;

	 
	server.i_report.start_time = 0;
	server.i_report.total_bytes = 0;
	server.i_report.cnt_datagrams = 0;
	server.i_report.cnt_dropped_datagrams = 0;
	server.i_report.last_report_time = 0;
}

int hasdone = 0; 
char * ipstr;
 
static void udp_recv_perf_traffic(int sock)
{
	int count;
	u8 recv_buf[UDP_RECV_BUFSIZE];
	struct sockaddr_in from;
	socklen_t fromlen = sizeof(from);
	int i=0;
	u32 paramters;
	u16 paramaddr = 0;
	int packlen = 0;
	int res=0;
	u16 cmdType;
	int length; 
	int freq_res = 0;
	while (1)
	{
		if((count = lwip_recvfrom(sock, recv_buf, UDP_RECV_BUFSIZE, 0,
				(struct sockaddr *)&from, &fromlen)) <= 0)
		{
			continue;
		}

		clientaddr = from;
		hasdone = 1;
		ipstr = inet_ntoa(clientaddr.sin_addr);


		 
		if((u8)recv_buf[0]== 0xEB && ((u8)recv_buf[2] == 0xA0 || (u8)recv_buf[2] == 0xA1 || (u8)recv_buf[2] == 0xA2 ||  (u8)recv_buf[2] == 0xA3))
		{
			 
			packlen = recv_buf[1]+1;
			UartLite485Send(recv_buf,packlen);
			if((u8)recv_buf[2] == 0xA0)
			{
				 
				freq_res = recv_buf[3];
				while(freq_res>>=1)
				{
					FreqCode ^= freq_res;
				}
			}
		}

		 
		if((u8)recv_buf[0] == 0xAB && (u8)recv_buf[1] == 0x90)
		{
			paramaddr = recv_buf[4]<<8 | recv_buf[5];

			paramters = recv_buf[6] << 24 |
						recv_buf[7] << 16 |
						recv_buf[8] << 8  |
						recv_buf[9];

			res = 0;

			cmdType = recv_buf[4]<<8 | recv_buf[5];
			length = (recv_buf[2]<<8 | recv_buf[3]) +7;

			BramParamSetToPL_32(paramaddr,paramters);

			if(cmdType == 0xF4)
			{
				radarparams.farbeishu = paramters;
			}
			if(cmdType == 0xF8)
			{
				radarparams.nearbeishu = paramters;
			}
			if(cmdType == 0x000C) 
			{
				initialparamsettask();
			}

			if(paramaddr == 0x0070)  
			{
				radarparams.adcdelay = paramters;
			}

			if(paramaddr == 0x005C) 
			{
				radarparams.rfmodulationwidth = paramters;
			}

			if(paramaddr == 0x00FC) 
			{
				if(paramters==0x01) 
				{
					 
					noPulseCompressCmdSet();
					BramParamSetToPL_32(paramaddr,paramters);
					paramaddr = 0x0008;
					paramters = 0xFFFFFFFF;
					BramParamSetToPL_32(paramaddr,paramters);
				}
				else if(paramters==0x02) 
				{
					 
					BramParamSetToPL_32(paramaddr,paramters);
					paramaddr = 0x0008;
					paramters = 0x0;
					BramParamSetToPL_32(paramaddr,paramters);
					PulseCompressCmdSet();
				}
			}

			 
			if(cmdType!=0x04 &&    
			   cmdType!=0x08 &&    
			   cmdType!=0x0C       
				                   )
			{
				 
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

				if(cmdType == 0x0014)  
				{
					res = EmmcParamFileWrite(cmdType,recv_buf,length);
				}

				if(radarstate.emmcparamd == 1)  
				{
					res = EmmcParamFileWrite(cmdType,recv_buf,length);
				}
				else if(radarstate.emmcparamd == 0)
				{
					res = 0;
				}
			}
			 
			if(res == 0)
			{
				udp_packet_send(recv_buf,count);
			}
			else  
			{
				recv_buf[4] = 0;
				recv_buf[5] = 0;
				udp_packet_send(recv_buf,length);
			}

			if(cmdType == 0x00FC)  
			{
				if(paramters == 0x01)  
				{
					for(i=0;i<4;i++)
					{
						refre[i] = 0;
						refim[i] = 0;
					}
				}
			}

			 
			 
			 
			 
		}

		 
		if((u8)recv_buf[0] == 0xAC && (u8)recv_buf[1] == 0x80)
		{
			cmdType = recv_buf[4]<<8 | recv_buf[5];
			if(cmdType == 0xFF11)  
			{
				xSemaphoreGive(xSemaphoreTarSend);
			}
			else if(cmdType == 0xFF12)  
			{
				g_MeasStarTrans = 1;
			}
			else if(cmdType == 0xFF13)  
			{
				g_MeasStarTrans = 0;
			}
		}

		 
		if((u8)recv_buf[0] == 0xAF && (u8)recv_buf[1] == 0xB0)
		{
			int recvsize = count;
			pstestflag = recv_buf[2];
			for(int i=0;i<recvsize;i++)
			{
				recvpstestbuff[i] = recv_buf[i];
			}
			udp_packet_send(recv_buf,count);
		}
		 
		if((u8)recv_buf[0] == 0xAF && (u8)recv_buf[1] == 0xB1)
		{
			bjmode = recv_buf[2];
			udp_packet_send(recv_buf,count);
		}
		 
		if((u8)recv_buf[0] == 0xAF && (u8)recv_buf[1] == 0xB2)
		{
			g_emmcpramatoPL = recv_buf[2];
			radarstate.emmcparamd = g_emmcpramatoPL&0xff;
			udp_packet_send(recv_buf,count);
		}
		 
		if((u8)recv_buf[0] == 0xAF && (u8)recv_buf[1] == 0xB3)
		{
			xSemaphoreGive(xSemaphoreReadEmmcParam);
		}
		 
		if((u8)recv_buf[0] == 0xAF && (u8)recv_buf[1] == 0xB4)
		{
			 
			float ft[8];
			for(int i=0;i<8;i++)
			{
				u32 temp;
				memcpy(&temp,recv_buf+2+i*4,4);
				temp = ntohl(temp);
				memcpy(&ft[i],&temp,4);
			}
			for(int i=0;i<4;i++)
			{
				FeederPhaseComp_1[i] = ft[i]/180*PI;
				FeederPhaseComp_2[i] = ft[i+4]/180*PI;
			}

			if(radarstate.emmcparamd == 1)  
			{
				cmdType = 0xAFB4;
				res = EmmcParamFileWrite(cmdType,recv_buf,34);

				 
				if(res == 0)
				{
					udp_packet_send(recv_buf,34);
				}
				else  
				{
					recv_buf[2] = 0;
					recv_buf[3] = 0;
					recv_buf[4] = 0;
					recv_buf[5] = 0;
					recv_buf[6] = 0;
					udp_packet_send(recv_buf,34);
				}
			}
			else  
			{
				recv_buf[2] = 1;
				recv_buf[3] = 1;
				recv_buf[4] = 1;
				recv_buf[5] = 1;
				recv_buf[6] = 1;
				udp_packet_send(recv_buf,34);
			}
		}
	}
}

void start_application_udp(void)
{
	err_t err;
	int sock;
	struct sockaddr_in addr;

	if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
		xil_printf("UDP server: Error creating Socket\r\n");
		return;
	}

	memset(&addr, 0, sizeof(struct sockaddr_in));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(UDP_CONN_PORT);
	addr.sin_addr.s_addr = htonl(INADDR_ANY);

	err = bind(sock, (struct sockaddr *)&addr, sizeof(addr));
	if (err != ERR_OK) {
		xil_printf("UDP server: Error on bind: %d\r\n", err);
		close(sock);
		return;
	}

	udp_recv_perf_traffic(sock);
}

 
int udp_packet_send(u8 *send_buf,int length)
{
	int sock;
	int count;
	socklen_t len = sizeof(clientaddr);

	if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
		xil_printf("UDP server: Error creating Socket\r\n");
		return -1;
	}

	clientaddr.sin_port = htons(UDP_CONN_PORT);

	count = lwip_sendto(sock, send_buf, length, 0,
								(struct sockaddr *)&clientaddr, len);

	close(sock);
	if(count < 0)
		return -1;



	return 0;
}
 
int udp_packet_send_custom(u8 *send_buf,int length)
{
	int sock;
	int count;
	err_t err;
	struct sockaddr_in addr;

	memset(&addr, 0, sizeof(struct sockaddr_in));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(UDP_CONN_PORT);

	if(hasdone == 0)
		addr.sin_addr.s_addr = inet_addr(UDP_SERVER_IP_ADDRESS);
	else
		addr.sin_addr.s_addr = inet_addr(ipstr);

	socklen_t len = sizeof(addr);

	if ((sock = socket(AF_INET, SOCK_DGRAM, 0)) < 0) {
		xil_printf("UDP server: Error creating Socket\r\n");
		return -1;
	}
	err = connect(sock, (struct sockaddr *)&addr, sizeof(addr));
	if (err != ERR_OK) {
		xil_printf("UDP client: Error on connect: %d\r\n", err);
		close(sock);
		return -1;
	}
	count = lwip_sendto(sock, send_buf, length, 0,
								(struct sockaddr *)&addr, len);
	close(sock);
	if(count < 0)
		return -1;

	return 0;
}

 
void UdpSendtoUPMTask()
{
	for(;;)
	{
		udp_packet_send_custom(UpMState,100);
		vTaskDelay(pdMS_TO_TICKS(1000)); 
	}
}
 
void UdpSendtoUPMeasTask()
{
	for(;;)
	{
		if(xSemaphoreTake(xSemaphoreMeasSend,portMAX_DELAY)==pdTRUE)
		{
			udp_packet_send_custom(UpMeasSend,1320); 
		}
	}
}

