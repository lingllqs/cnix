#include <cnix/global.h>
#include <cnix/string.h>
#include <cnix/debug.h>

descriptor_t gdt[GDT_SIZE];
pointer_t gdt_ptr;

void gdt_init()
{
    DEBUGK("init gdt!!!\n");

    // 将GDTR中的值加载到gdt_ptr中
    asm volatile("sgdt gdt_ptr");

    // 将描述符表拷贝gdt中
    memcpy(&gdt, (void *)gdt_ptr.base, gdt_ptr.limit + 1);

    gdt_ptr.base = (u32)&gdt;
    gdt_ptr.limit = sizeof(gdt) - 1;

    // 将GDTR中的值设置为gdt_ptr的值
    asm volatile("lgdt gdt_ptr\n");
}
