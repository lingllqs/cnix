	.file	"hello.c"        # 文件名
	.text                    # 代码段
	.globl	message          # 导出message
	.data                    # 数据段
	.align 4                 # 四个字节对齐
	.type	message, @object # 类型
	.size	message, 13      # 大小

message:
	.string	"hello world\n"
	.globl	buf
	.bss # 未初始化数据段
	.align 32
	.type	buf, @object
	.size	buf, 1024

buf:
	.zero	1024
	.section	.rodata # 只读数据段

.LC0: # Literal Constant 字面常量
	.string	"%s"
	.text
	.globl	main
	.type	main, @function

main:
	pushl	$message # 将message地址压入栈中
	pushl	$.LC0
	call	printf   # 调用printf函数
	addl	$8, %esp # 恢复栈
	movl	$0, %eax # 函数返回值
	ret              # 函数返回
	.size	main, .-main
	.section	.note.GNU-stack,"",@progbits# 标记栈不可运行
