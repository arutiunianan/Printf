global AnishkinPrintf       ; делаем метку метку _start видимой извне

extern WriteFile        ; подключем функцию WriteFile
extern GetStdHandle     ; подключем функцию GetStdHandle

section .data   ; секция данных

section .text       ; объявление секции кода
AnishkinPrintf:
    push rbp
    
    ;mov eax, dword ss:[rbp - 4],
    ;push rax
    ;pop rax

    mov rsi, buff   ; fill_buff(buff, rsp + 8)
    ;mov r12, rsp
    ;add r12, 8
    call fill_buff

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