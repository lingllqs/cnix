#ifndef CNIX_MEMORY_H
#define CNIX_MEMORY_H

#include <cnix/types.h>

#define PAGE_SIZE 0x1000
#define MEMORY_BASE 0x100000

// 内核页目录索引
#define KERNEL_PAGE_DIR 0x1000

// 内核页表索引
static u32 KERNEL_PAGE_TABLE[] = {0x2000, 0x3000};

typedef struct page_entry_t {
  u8 present : 1;
  u8 write : 1;
  u8 user : 1;
  u8 pwt : 1;
  u8 pcd : 1;
  u8 accessed : 1;
  u8 dirty : 1;
  u8 pat : 1;
  u8 global : 1;
  u8 ignored : 3;
  u32 index : 20;
} _packed page_entry_t;

// 得到cr3寄存器
u32 get_cr3();

// 设置cr3寄存器，参数是页目录的地址
void set_cr3(u32 pde);

// 分配count个连续的内核页
u32 alloc_kpage(u32 count);

// 释放count个连续的内核页
void free_kpage(u32 vaddr, u32 count);

#endif
