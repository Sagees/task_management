#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <time.h>

static void cur_time(void) {
	/* represent current time */
	time_t t = time(NULL);
	char cur_T[10]; char sys_d[20];
	struct tm tm = *localtime(&t);
	/*printf("%d:%d:%d\n",
 		//tm.tm_year+1900, tm.tm_mon+1, tm.tm_mday,
 		tm.tm_hour, tm.tm_min, tm.tm_sec);*/
	sprintf(cur_T, "%d:%d:%d\n", tm.tm_hour,tm.tm_min, tm.tm_sec);
	strcpy(sys_d, "echo \"");
	strcat(sys_d,cur_T);
	strcat(sys_d, "\"");
	system(sys_d);
}

int main() {
	int cnt = 60;
	while (cnt--) {
		usleep(500000);
		cur_time();
		system("procrank | grep TOTAL | awk '{print ($1/1024)}'");
		printf("\n");
	}
	return 0;
}	