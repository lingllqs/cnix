#ifndef CNIX_STDIO_H
#define CNIX_STDIO_H

#include <cnix/stdarg.h>

int vsprintf(char *buf, const char *fmt, va_list args);
int sprintf(char *buf, const char *fmt, ...);

#endif
