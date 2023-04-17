#include <cnix/cnix.h>

int magic = CNIX_MAGIC;
char message[] = "hello cnix!!!";
char buff[1024];

void kernel_init()
{
    char *video = (char *)0xb8000;
    for (int i = 0; i < sizeof(message); ++i) {
        video[i * 2] = message[i];
    }
}
