#ifndef CNIX_INTERRUPT_H
#define CNIX_INTERRUPT_H

#include <cnix/types.h>

#define IDT_SIZE 256

#define IRQ_CLOCK 0
#define IRQ_KEYBOARD 1
#define IRQ_CASCADE 2
#define IRQ_SERIAL_2 3
#define IRQ_SERIAL_1 4
#define IRQ_PARALLEL_2 5
#define IRQ_FLOPPY 6
#define IRQ_PARALLEL_1 7
#define IRQ_RTC 8
#define IRQ_REDIRECT 9
#define IRQ_MOUSE 12
#define IRQ_MATH 13
#define IRQ_HARDDISK 14
#define IRQ_HARDDISK2 15

#define IRQ_MASTER_NR 0x20
#define IRQ_SLAVE_NR 0x28

typedef void* handler_t;

typedef struct gate_t
{
    u16 offset0;    // 段内偏移0～15位
    u16 selector;   // 代码段选择子
    u8 reserved;    // 保留不用
    u8 type : 4;    // 类型(中断门/陷阱门)
    u8 segment : 1; // 0 表示系统段
    u8 DPL : 2;     // 使用int指令访问的最低权限
    u8 present : 1; // 是否有效
    u16 offset1;    // 段内偏移16～31位
} _packed gate_t;

void send_eoi(int vector);

void set_interrupt_handler(u32 irq, handler_t handler);
void set_interrupt_mask(u32 irq, bool enable);

bool interrupt_disable();
bool get_interrupt_state();
void set_interrupt_state(bool state);
/* void interrupt_init(); */

#endif
