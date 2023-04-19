[bits 32]

section .text; 代码段

global inb ; 导出inb
inb:
    push ebp
    mov ebp, esp

    xor eax, eax
    mov edx, [ebp+8]; port端口
    in al, dx; 将端口号dx的8bit输入al

    jmp $+2
    jmp $+2
    jmp $+2

    leave
    ret

global outb ; 导出outb
outb:
    push ebp
    mov ebp, esp

    xor eax, eax
    mov edx, [ebp+8]; port端口
    mov eax, [ebp+12]; value
    out dx, al

    jmp $+2
    jmp $+2
    jmp $+2

    leave
    ret



global inw ; 导出inb
inw:
    push ebp
    mov ebp, esp

    xor eax, eax
    mov edx, [ebp+8]; port端口
    in ax, dx; 将端口号dx的8bit输入al

    jmp $+2
    jmp $+2
    jmp $+2

    leave
    ret



global outw ; 导出inb
outw:
    push ebp
    mov ebp, esp

    xor eax, eax
    mov edx, [ebp+8]; port端口
    mov eax, [ebp+12]; value
    out dx, ax

    jmp $+2
    jmp $+2
    jmp $+2

    leave
    ret



