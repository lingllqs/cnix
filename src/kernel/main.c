extern console_init();
extern gdt_init();
extern interrupt_init();
extern clock_init();
extern task_init();
extern hang();


void kernel_init()
{
    console_init();
    gdt_init();
    interrupt_init();
    clock_init();
    task_init();


    asm volatile("sti");
    hang();
}
