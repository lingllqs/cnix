#ifndef CNIX_STDARG_H
#define CNIX_STDARG_H

typedef char* va_list;

// 函数参数是从右往左依次压入栈中，这里ap指向倒数第二个压入栈中的地址
#define va_start(ap, v) (ap = (va_list)&v + sizeof(char *)) 
// 
#define va_arg(ap, t) (*(t *)((ap += sizeof(char *)) - sizeof(char *)))
#define va_end(ap) (ap = (va_list)0)

#endif
