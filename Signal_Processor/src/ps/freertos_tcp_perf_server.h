 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 

#ifndef __FREERTOS_TCP_SERVER_APP_H_
#define __FREERTOS_TCP_SERVER_APP_H_

#include "lwipopts.h"
#include "lwip/tcp.h"
#include "lwip/ip_addr.h"
#include "lwip/inet.h"
#include "lwip/sockets.h"
#include "lwip/sys.h"
#include "xil_printf.h"

 
enum {
	KCONV_UNIT,
	KCONV_KILO,
	KCONV_MEGA,
	KCONV_GIGA,
};

 
const char kLabel[] =
{
	' ',
	'K',
	'M',
	'G'
};

 
enum measure_t {
	BYTES,
	SPEED
};

 
enum report_type {
	 
	INTER_REPORT,
	 
	TCP_DONE_SERVER,
	 
	TCP_ABORTED_REMOTE
};

struct interim_report {
	u64_t start_time;
	u64_t last_report_time;
	u32_t total_bytes;
};

struct perf_stats {
	u8_t client_id;
	u64_t start_time;
	u64_t total_bytes;
	struct interim_report i_report;
};

#define RECV_BUF_SIZE 1500

#define TCP_SERVER_THREAD_STACKSIZE 2048

 
#define TCP_CONN_PORT 5001

 
#define INTERIM_REPORT_INTERVAL 5

#endif  
