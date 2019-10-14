#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#define CPUSTAT "/proc/stat"

//int user, nice, sys, idle, iowait, irq, softirq, steal, guest, gnice = 0;

int mode, cores;


float* cpu_usage_per(void) {
	int i=0; float total, total_idle;
	float *res = (float*) malloc(sizeof(float)*32);
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

int main() {
	int cnt = 20; int j;
	float diff_i, diff_t, per; float * prev;
	FILE *pFile = fopen("cpulog.txt", "w");
	if (cnt >0) prev = cpu_usage_per();
	while (--cnt) {
		sleep(1);
		float *cur = cpu_usage_per();
		for (j=0; j<2*cores; j++) {
			diff_i = cur[j] - prev[j];
			diff_t = cur[j+1] - prev[j+1]; 
			// printf("i : %f t: %f \n", prev[j], prev[j+1]);
			per = ((diff_t-diff_i)/diff_t)*100;
			 ++j;

			if (j/2 == 0)
			{
				fprintf(pFile,"MAIN CPU : %.4f \n", per);
			}
			else {
				fprintf(pFile, "CPU %d : %.4f \n",(j-1)/2,per);
			}
		}
		fprintf(pFile,"\n");
		prev = cur;
	}
	fclose(pFile);
	return 0;
}