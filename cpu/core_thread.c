#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <math.h>
#include <unistd.h>
#include <time.h>
#define PROCDIR "/proc"
#define CPUSTAT PROCDIR "/stat"

//int user, nice, sys, idle, iowait, irq, softirq, steal, guest, gnice = 0;

int mode, cores;

static void cur_time(void) {
	/* represent current time */
	time_t t = time(NULL);
	struct tm tm = *localtime(&t);
	printf("%d-%d-%d %d:%d:%d\n",
 		tm.tm_year+1900, tm.tm_mon+1, tm.tm_mday,
 		tm.tm_hour, tm.tm_min, tm.tm_sec);
}

float* cpu_usage_per(void) {
	int i=0; float total, total_idle;
	float *res = (float*) malloc(sizeof(float)*32); // when to free?
	FILE *fp = fopen(CPUSTAT, "r");
	if (fp == NULL) return res; // file not exists
	cores = 0;
	while (fgetc(fp) != 'i') {
		total =0, total_idle = 0; // total, total_idle
		mode = 0; // numbering modes
		char buffer[10000];
		fgets(buffer, sizeof(buffer), fp); // one line for each
		char *ptr = strtok(buffer, " ");
		while (mode < 8) { // EXCEPT GUEST MODE
			if ((mode == 4) || (mode == 5)) { // idle
				total += atof(ptr);
				total_idle += atof(ptr);
			}
			else if (mode == 0) {}
			else { // non-idle
				total += atof(ptr);
			}
			++mode;
			ptr = strtok(NULL, " ");

		}
		res[i++] = total_idle;
		res[i++] = total;
		++cores;
	}
	fclose(fp);
	return res;
}

int main(int argc, char *argv[]) {

	/* PID INPUT 
		which input would be better to change in integer format? */
	if (argc >1) { // specific pid input, threads per pid
		int pid = atoi(argv[1]);
		printf("pid = %d\n", pid);
		system("ps aux | grep -E  \"^[[:space:]]+${pid}\""); 
	}


	/* USAGE, THREAD, PER CORE
		do not need any input  */
	else { // cpu usage per core, thread per core
		int flag = 0;
		printf("----------------------------------------------\n");
		printf("Press following number what to represent\n1. CPU USAGE / core\n2. THREADS / core\n");
		printf("----------------------------------------------\n\ninput : ");
		scanf("%d",&flag);
		if (flag == 1) {
			int cnt = 20; int j;
			float diff_i, diff_t, per; float * prev;

			//FILE *pFile = fopen("cpulog.txt", "w");
			if (cnt >0) prev = cpu_usage_per();
			while (--cnt) {
				usleep(500000);
				float *cur = cpu_usage_per();
				cur_time();
				for (j=0; j<2*cores; j++) {
					diff_i = cur[j] - prev[j];
					diff_t = cur[j+1] - prev[j+1]; 
					// printf("i : %f t: %f \n", prev[j], prev[j+1]);
					per = ((diff_t-diff_i)/diff_t)*100; ++j;

					if (isnan(per)) per = 0.0;
					else {/* print cpu usage per core */
						if (j/2 == 0)
						{
							//fprintf(pFile,"MAIN CPU : %.4f \n", per);
							printf("MAIN CPU : %.4f \t", per);
						}
						else {
							//fprintf(pFile, "CPU %d : %.4f \n",(j-1)/2,per);
							printf("CPU %d : %.4f \t",(j-1)/2,per);
						}
					}
				}
				//fprintf(pFile,"\n");
				printf("\n\n");
				prev = cur;
			}
			//fclose(pFile);
		}
		else if (flag == 2) {
			while (1) {
				usleep(500000);
				system("CORENUM=0; ps -eT -o spid,psr,stat,cmd,time | grep -E  \"^[[:space:]][[:digit:]]+[[:space:]][[:digit:]]+${CORENUM}\"");
				printf("\n");
			}
		}
	}
	return 0;
}