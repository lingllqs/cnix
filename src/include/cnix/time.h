#ifndef CNIX_TIME_H
#define CNIX_TIME_H

#include <cnix/types.h>

typedef struct tm
{
    int tm_sec;
    int tm_min;
    int tm_hour;
    int tm_mday;
    int tm_mon;
    int tm_year;
    int tm_wday;
    int tm_yday;
    int tm_isdst; // 夏令时标记
} tm;


void time_read_bcd(tm *time);
void time_read(tm *time);
time_t mktime(tm *time);


#endif
