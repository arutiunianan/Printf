global AnishkinPrintf       ; делаем метку метку _start видимой извне

extern WriteFile        ; подключем функцию WriteFile
extern GetStdHandle     ; подключем функцию GetStdHandle

%macro check_buff 0
        push rax
        call buff_len
        cmp rax, 511d
        jge .clear_buff
        jmp .check_buff_end

.clear_buff:
        call write_buff
        mov rsi, buff

.check_buff_end:
        pop rax
%endmacro

%macro check_spec_sym 2
    cmp r10b, %1
    je %2
%endmacro

section .data   ; секция данных

buff            db 512d DUP(0)

section .text       ; объявление секции кода
AnishkinPrintf:
    push rbp
    
    mov rsi, buff   ; fill_buff(buff, rsp + 8)
    ;mov r12, rsp
    ;add r12, 8
    call fill_buff

    call buff_len   ; write_buff(buff_len - 1)
    dec rax
    call write_buff

    pop rbp
    ret             ; выход из программы


fill_buff:

        xor r11, r11            ; r11 = 0 (args filled count)

.check:
        mov r10b, [rcx]

        cmp r10b, '%'           ; if ([rcx] == '%') .get_type_code
        je .get_type_code

        cmp r10b, 0             ; else if ([rcx] != '\0') .exit
        je .exit

.copy_char:                     ; else
        mov [rsi], r10b         ; buff[i] = [rsi]
        inc rsi
        inc rcx
        check_buff              ; check buff's count
        jmp .check

.get_type_code:
        inc rcx
        call fill_spec_sym      ; fill buff with arg

        inc r11
        inc rsi
        inc rcx
        jmp .check

.exit:
        ret


fill_spec_sym:

        xor r10, r10            ; r10 = 0

        mov r10b, [rcx]         ; r10b = buffer[i]

        check_spec_sym 'c', fill_char
        check_spec_sym 'd', fill_dec
        check_spec_sym 'x', fill_hex
        check_spec_sym 's', fill_str
        check_spec_sym '%', fill_percent
        jmp spec_sym_table_exit


fill_char:
        sub rbp, 1
        mov al, byte [rbp]
        mov byte [rsi], al
        check_buff
        jmp spec_sym_table_exit
fill_dec:
        sub rbp, 4
        ;call read_dec
        mov eax, dword [rbp]
        mov dword [rsi], eax
        inc rsi
        check_buff
        jmp spec_sym_table_exit
fill_hex:
        sub rbp, 4
        mov eax, dword [rbp]
        mov dword [rsi], eax
        inc rsi
        check_buff
        jmp spec_sym_table_exit
fill_str:
        sub rbp, 8
        mov rax, qword [rbp]
        mov qword [rsi], rax
        inc rsi
        check_buff
        jmp spec_sym_table_exit
fill_percent:
        sub rbp, 1
        mov byte [rsi], '?'
        inc rsi
        check_buff
        jmp spec_sym_table_exit

spec_sym_table_exit:
        ret


;read_dec:


write_buff:
        push rdx
        push rcx
        push r8
        push r9

        mov r8, rax
        mov rdx, buff

        sub rsp, 40                    
        mov rcx, -11                   
        call GetStdHandle              

        mov rcx, rax

        xor r9, r9
        mov qword [rsp + 32], 0
        call WriteFile
        add rsp, 40

        pop r9
        pop r8
        pop rcx
        pop rdx

        ret
buff_len:
        push rsi
        push rdi

        mov rdi, buff
        sub rsi, rdi

        mov rax, rsi

        pop rdi
        pop rsi
        ret