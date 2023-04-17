[org 0x7c00]

; 设置屏幕模式为文本模式
mov ax, 3
int 0x10

; 初始化段寄存器
mov ax, 0
mov ds, ax
mov es, ax
mov ss, ax
mov sp, 0x7c00

; 0xb8000 文本显示器的内存区域
mov si, booting; si指向字符串地址
call print

; xchg bx, bx ; bochs的魔术断点

; jmp error

mov edi, 0x1000; 读取硬盘扇区到此位置
mov ecx, 2; 起始扇区
mov bl, 4; 读取扇区数

; 读取loader
call read_disk; 调用读取函数

cmp word [0x1000], 0x55aa
jnz error

; 跳转到loader中执行
jmp 0:0x1002

; xchg bx, bx; 打断点



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

; 写入硬盘    
; write_disk:
;     ; 读取扇区数，端口为0x1f2
;     mov dx, 0x1f2
;     mov al, bl
;     out dx, al
;
;     ; 要读取的扇区号
;     mov dx, 0x1f3
;     mov al, cl; 0~7
;     out dx, al
;
;     mov dx, 0x1f4
;     shr ecx, 8
;     mov al, cl; 8～15
;     out dx, al
;
;     mov dx, 0x1f5
;     shr ecx, 8
;     mov al, cl; 16～23
;     out dx, al
;
;     mov dx, 0x1f6
;     shr ecx, 8
;     and cl, 0b1111; 只保留后4位，也就是LBA28方式扇区号的24～27这4位
;     mov al, 0b1110_0000; 3个1分别表示 固定为1、LBA方式、固定为1、主盘
;     or al, cl
;     out dx, al
;
;     mov dx, 0x1f7
;     mov al, 0x20; 写硬盘
;     out dx, al
;
;     ; 获取读取扇区数量，以备循环读取
;     xor ecx, ecx
;     mov cl, bl; 循环次数为扇区数量
;
;     ; 开始读取
;     .write:
;         push cx
;         call .writesec; 磁盘准备就绪，开始写一个扇区数据
;         call .waits; 检测磁盘是否繁忙
;         pop cx
;         loop .write
;         ret
;
;     .waits:
;         mov dx, 0x1f7
;         .check:
;             in al, dx;从0x1f7端口中获得磁盘状态
;             jmp $+2; 延迟
;             jmp $+2
;             jmp $+2
;             and al, 0b1000_0000; 保留第3位和第7位, 分别表示数据是否准备就绪和磁盘是否繁忙
;             cmp al, 0b0000_0000; 数据就绪，磁盘不忙
;             jnz .check; 一直检测
;         ret
;
;     .writesec:
;         mov dx, 0x1f0; 读写端口
;         mov cx, 256; 每次读取一个字，总共读取512字节
;         .writeword:
;             mov ax, [edi]
;             out dx, ax; 从端口中读取一个字
;             jmp $+2; 延迟
;             jmp $+2
;             jmp $+2
;             add edi, 2
;             loop .writeword
;         ret

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

; mov ax, 0xb800
; mov ds, ax
; mov byte [0], 'H'


booting:
    db "Booting Cnix", 10, 13, 0 ; \n\r\0 ascii控制字符(换行、回车、字符结束)

error:
    mov si, .msg
    call print
    hlt
    jmp $
    .msg db "Booting Error", 10, 13, 0
; 阻塞
jmp $

; 填充不足512字节为0
times 510 - ($ - $$) db 0

; 主引导扇区标志
db 0x55, 0xaa

