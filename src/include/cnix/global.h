#ifndef CNIX_GLOBAL_H
#define CNIX_GLOBAL_H

#include <cnix/types.h>

#define GDT_SIZE 128

// 全局描述符GDT
typedef struct descriptor_t
{
    unsigned short limit_low;
    unsigned int base_low : 24;
    unsigned char type : 4;
    unsigned char segment : 1;
    unsigned char DPL : 2;
    unsigned char present : 1;
    unsigned char limit_high : 4;
    unsigned char available : 1;
    unsigned char long_mode : 1;
    unsigned char big : 1;
    unsigned char granularity : 1;
    unsigned char base_high;
} _packed descriptor_t;

// 段选择子
typedef struct selector_t
{
    u8 RPL : 2;
    u8 TI : 1;
    u16 index : 13;
} selector_t;

// 全局描述符表指针
typedef struct pointer_t
{
    u16 limit;
    u32 base;
} _packed pointer_t;

// 初始化gdt
void gdt_init();

#endif
