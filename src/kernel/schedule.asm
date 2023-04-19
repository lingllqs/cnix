[bits 32]

section .text

global task_switch
task_switch:
    ; 保存栈帧
    push ebp
    mov ebp, esp

    ; ABI压栈
    push ebx
    push esi
    push edi
    
    mov eax, esp; 栈顶保存到eax
    and eax, 0xfffff000; current

    mov [eax], esp

    mov eax, [ebp + 8]; next
    mov esp, [eax]

    pop edi
    pop esi
    pop ebx
    pop ebp

    ret
