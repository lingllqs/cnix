#ifndef CNIX_TASK_H
#define CNIX_TASK_H

#include <cnix/types.h>
#include <cnix/list.h>

#define KERNEL_USER 0
#define NORMAL_USER 1

#define TASK_NAME_LEN 16

typedef void target_t();

typedef enum task_state_t
{
    TASK_INIT,
    TASK_RUNNING,
    TASK_READY,
    TASK_BLOCKED,
    TASK_SLEEPING,
    TASK_WAITING,
    TASK_DIED
} task_state_t;

typedef struct task_t
{
    u32 *stack; // 内核栈
    list_node_t node; // 任务阻塞结点
    task_state_t state;
    u32 priority;
    u32 ticks;
    u32 jiffies;
    u32 name[TASK_NAME_LEN];
    u32 uid;
    u32 pde;
    struct bitmap_t *vmap; // 进程虚拟内存位图
    u32 magic;
} task_t;

typedef struct task_frame_t
{
    u32 edi;
    u32 esi;
    u32 ebx;
    u32 ebp;
    void (*eip)(void);
} task_frame_t;

/* void task_init(); */
task_t *running_task();
void schedule();

void task_yield();
void task_block(task_t *task, list_t *blist, task_state_t state);
void task_unblock(task_t *task);

void task_sleep(u32 ms);
void task_wakeup();

#endif
