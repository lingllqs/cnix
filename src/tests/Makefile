
CFLAGS:= -m32
CFLAGS+= -Qn                             # gcc 版本信息
# CFLAGS+= -fno-builtin                    # 不需要gcc内置函数 如 memcpy
# CFLAGS+= -nostdinc                       # 不需要标准头文件
CFLAGS+= -fno-pic                        # 不需要位置无关的代码
# CFLAGS+= -fno-pie                        # 不需要位置无关的可执行程序
# CFLAGS+= -nostdlib                       # 不需要标准库
# CFLAGS+= -fno-stack-protector            # 不需要栈保护
CFLAGS+= -fno-asynchronous-unwind-tables # DWARF信息，用于调试，获取异常信息
CFLAGS+= -fomit-frame-pointer            # 不需要栈帧
CFLAGS+= -mpreferred-stack-boundary=2    # 不需要栈对齐
CFLAGS:=$(strip ${CFLAGS})

.PHONY: hello.s
hello.s: hello.c
	gcc $(CFLAGS) -S $< -o $@
