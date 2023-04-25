#ifndef CNIX_SYSCALL_H
#define CNIX_SYSCALL_H

#include <cnix/types.h>

typedef enum syscall_t
{
    SYS_NR_TEST,
    SYS_NR_YIELD
} syscall_t;

u32 test();
void yield();

#endif
