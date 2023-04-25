#include <cnix/interrupt.h>
#include <cnix/assert.h>
#include <cnix/debug.h>
#include <cnix/syscall.h>
#include <cnix/task.h>

#define LOGK(fmt, args...) DEBUGK(fmt, ##args)

#define SYSCALL_SIZE 64

handler_t syscall_table[SYSCALL_SIZE];

void syscall_check(u32 nr)
{
    if (nr >= SYSCALL_SIZE)
    {
        panic("syscall nr error!!!");
    }
}

static void sys_default()
{
    panic("syscall not implemented!!!");
}

task_t *task = NULL;

static u32 sys_test()
{
    /* LOGK("syscall test...\n"); */

    if (!task)
    {
        task = running_task();
        task_block(task, NULL, TASK_BLOCKED);
    }
    else
    {
        task_unblock(task);
        task = NULL;
    }
    return 255;
}

extern void task_yield();

void syscall_init()
{
    for (size_t i = 0; i < SYSCALL_SIZE; i++)
    {
        syscall_table[i] = sys_default;
    }

    syscall_table[SYS_NR_TEST] = sys_test;
    syscall_table[SYS_NR_YIELD] = task_yield;
}
