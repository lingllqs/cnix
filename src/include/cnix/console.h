#ifndef CNIX_CONSOLE_H
#define CNIX_CONSOLE_H

#include <cnix/types.h>

void console_init();
void console_clear();
void console_write(char *buf, u32 count);

#endif
