[org 0x1000]

dw 0x55aa; 读取成功标志

mov si, loading
call print

; xchg bx, bx; 设置断点

; 内存检测
detect_memory:
    ; 将 ebx 置为 0
    xor ebx, ebx

    ; es:di 结构体的缓存位置
    mov ax, 0
    mov es, ax
    mov edi, ards_buffer

    mov edx, 0x534d4150; 固定签名

; 开始检测
.next:
    mov eax, 0xe820; 子功能号
    mov ecx, 20; ards 结构体的大小(字节)
    int 0x15; 调用 0x15 系统功能

    ; 如果CF 置位，表示出错
    jc error

    ; 将缓存指针指向下一个结构体
    add di, cx

    ; 将结构体数量加一 
    inc word [ards_count]

    cmp ebx, 0
    jnz .next

    mov si, detecting
    call print

    jmp prepare_protected_mode; 跳转到准备进入保护模式中

    ; xchg bx, bx

;     mov cx, [ards_count]
;     mov si, 0
;
; .show:
;     mov eax, [ards_buffer + si]
;     mov ebx, [ards_buffer + si + 8]
;     mov edx, [ards_buffer + si + 16]
;     add si, 20
;     xchg bx, bx
;     loop .show

; 准备进入保护模式
prepare_protected_mode:
    ; xchg bx, bx
    cli;关闭中断
    ; 打开A20线,可以访问1M以外内存
    in al, 0x92
    or al, 0b10
    out 0x92, al

    lgdt [gdt_ptr]
    ; 启动保护模式
    mov eax, cr0
    or eax, 1
    mov cr0, eax

    ; 用跳转来刷新缓存来启用保护模式
    jmp dword code_selector:protect_mode



; 打印字符串
print:
    mov ah, 0x0e ; 功能号为0x0e
    .printchar:
        mov al, [si]
        cmp al, 0
        jz .done
        int 0x10
        inc si
        jmp .printchar
    .done:
        ret


[bits 32]
protect_mode:
    ; xchg bx, bx
    mov ax, data_selector
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    
    mov esp, 0x10000; 修改栈顶

    mov edi, 0x10000
    mov ecx, 10
    mov bl, 200

    ; 读入内核
    call read_disk

    jmp dword code_selector:0x10000

    ud2; 出错


; 读取扇区函数,使用LBA28方式读取
read_disk:
    ; 读取扇区数，端口为0x1f2
    mov dx, 0x1f2
    mov al, bl
    out dx, al

    ; 要读取的扇区号
    mov dx, 0x1f3
    mov al, cl; 0~7
    out dx, al

    mov dx, 0x1f4
    shr ecx, 8
    mov al, cl; 8～15
    out dx, al

    mov dx, 0x1f5
    shr ecx, 8
    mov al, cl; 16～23
    out dx, al

    mov dx, 0x1f6
    shr ecx, 8
    and cl, 0b1111; 只保留后4位，也就是LBA28方式扇区号的24～27这4位
    mov al, 0b1110_0000; 3个1分别表示 固定为1、LBA方式、固定为1、主盘
    or al, cl
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20; 读硬盘
    out dx, al

    ; 获取读取扇区数量，以备循环读取
    xor ecx, ecx
    mov cl, bl; 循环次数为扇区数量

    ; 开始读取
    .read:
        push cx
        call .waits; 检测磁盘是否繁忙
        call .readsec; 磁盘准备就绪，开始读取一个扇区数据
        pop cx
        loop .read
        ret

    .waits:
        mov dx, 0x1f7
        .check:
            in al, dx;从0x1f7端口中获得磁盘状态
            jmp $+2; 延迟
            jmp $+2
            jmp $+2
            and al, 0b1000_1000; 保留第3位和第7位, 分别表示数据是否准备就绪和磁盘是否繁忙
            cmp al, 0b0000_1000; 数据就绪，磁盘不忙
            jnz .check; 一直检测
        ret

    .readsec:
        mov dx, 0x1f0; 读写端口
        mov cx, 256; 每次读取一个字，总共读取512字节
        .readword:
            in ax, dx; 从端口中读取一个字
            jmp $+2; 延迟
            jmp $+2
            jmp $+2
            mov [edi], ax; 数据读取到指定内存位置,这里是0x1000
            add edi, 2
            loop .readword
        ret

code_selector equ (1 << 3)
data_selector equ (2 << 3)

memory_base equ 0
memory_limit equ ((1024 * 1024 * 1024 * 4) / (1024 * 4)) - 1

gdt_ptr:
    dw (gdt_end - gdt_base) - 1
    dd gdt_base
gdt_base:
    dd 0, 0; NULL 描述符
gdt_code:
    dw memory_limit & 0xffff; 段界限0~15位
    dw memory_base & 0xffff; 段基地址0~15位
    db (memory_base >> 16) & 0xff; 段基地址16~23
    ; p_dpl_s_x_c/e_r/w_a
    ; 是否在内存中(1位)_DPL(2位)_代码段和数据段/系统段(1位)_段类型(4位)
    db 0b_1_00_1_1_0_1_0
    ; 粒度_32/16位_64位扩展标志_available_段界限(4位)
    db 0b_1_1_0_0_0000 | (memory_limit >> 16) & 0xf
    db (memory_base >> 24) & 0xff

gdt_data:
    dw memory_limit & 0xffff; 段界限0~15位
    dw memory_base & 0xffff; 段基地址
    db (memory_base >> 16) & 0xff
    ; p_dpl_s_x_c/e_r/w_a
    ; 是否在内存中(1位)_DPL(2位)_代码段和数据段/系统段(1位)_段类型(4位)
    db 0b_1_00_1_0_0_1_0
    ; 粒度_32/16位_64位扩展标志_available_段界限(4位)
    db 0b_1_1_0_0_0000 | (memory_limit >> 16) & 0xf
    db (memory_base >> 24) & 0xff
gdt_end:
    
loading:
    db "Loading Cnix", 10, 13, 0
detecting:
    db "Detecting Memory Success...", 10, 13, 0

error:
    mov si, .msg
    call print
    hlt
    jmp $
    .msg db "Loading Error", 10, 13, 0


ards_count:
    dw 0
ards_buffer:
    
