global AnishkinPrintf   ;making the _start label visible from the outside

extern WriteFile        ;connect the WriteFile function
extern GetStdHandle     ;connect the GetStdHandle function

;----------MACROS----------
;macros for checking is buffer size bigger than sheet size(512), if more then the buffer prints
%macro check_buff 0
        push rax
        call BuffLen
        cmp rax, 511d
        jge .clear_buff
        jmp .check_buff_end

.clear_buff:
        call WriteBuff
        mov rsi, buff

.check_buff_end:
        pop rax
%endmacro

;compares a special character
%macro check_spec_sym 2
    cmp r10b, %1
    je %2
%endmacro
;--------------------------------

;----------DATA-SECTION----------
section .data   

buff            db 512d DUP(0)
num_buff        db 20  DUP(0)

hex_alf        db '0123456789ABCDEF'
;--------------------------------

;----------CODE-SECTION----------
section .text
AnishkinPrintf:

    push rbp
    
    mov rsi, buff   
    call FillBuff     ;FillBuff(buff)

    call BuffLen   
    call WriteBuff    ;WriteBuff(BuffLen)

    pop rbp
    ret               ;exiting the program


;-------------------------
; FillBuff
;
; Fills the buffer with the entered characters 
; and replaces special characters with percentages
;
; Entry: RSI - Address of buff
; Destr: RSI - Address of characters buff
;        RCX - Address of entered characters
;        R10 - Entered character
; Exit:  -
;-------------------------

FillBuff:
.check:
        mov r10b, [rcx]

        cmp r10b, '%'           ;if ([rcx] == '%') .get_type_code
        je .get_type_code

        cmp r10b, 0             ;else if ([rcx] != '\0') .exit
        je .exit

.copy_char:                     ;else
        mov [rsi], r10b         ;buff[i] = [rsi]
        inc rsi
        inc rcx
        check_buff              ;check buff's count
        jmp .check

.get_type_code:
        inc rcx
        call FillSpecSym      ;fill buff with arg

        inc rsi
        inc rcx
        jmp .check

.exit:
        ret

;-------------------------
; FillSpecSym
;
; Determines which special character is entered. 
; Inserts characters into the buffer depending on the special character
;
; Entry: RSI - Address of characters buffer
;        RCX - Address of entered characters
; Destr: RSI - Address of characters buffer
;        RCX - Address of entered characters
;        R10 - Spec Symbol
;        RBP - The address of the symbol to replace
;        RAX - The symbol to replace
;        RBX - It is used only in the case of special characters for dec, hex and str
;              (if the special character is %d, then rbx = 0, 
;               if %h, then rbx = address to the array with the hex alphabet, 
;               if %s rbx = address to the character of the entered string)
; Exit:  -
;-------------------------
FillSpecSym:

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
        mov eax, dword [rbp]

        push r11
        mov rbx, 0
        call ReadDec
        call ReverseStr
        pop r11
        
        check_buff
        jmp spec_sym_table_exit
fill_hex:
        sub rbp, 4
        mov eax, dword [rbp]

        push r11
        mov rbx, hex_alf
        call ReadDec
        call ReverseStr
        pop r11
        
        check_buff
        jmp spec_sym_table_exit
fill_str:
        sub rbp, 8
        mov rbx, qword [rbp]
        mov al, byte [rbx]

.loop_body:
        mov byte [rsi], al
        inc rsi
        inc rbx
        check_buff

.loop_cond:
        mov al, byte [rbx]
        cmp al, 0
        jne .loop_body

        dec rsi
        jmp spec_sym_table_exit
fill_percent:
        sub rbp, 1
        mov byte [rsi], '?'
        inc rsi
        check_buff
        jmp spec_sym_table_exit

spec_sym_table_exit:
        ret

;-------------------------
; ReadDec
;
; Writes the numbers to an array
;
; Entry: RAX - Number
; Destr: RAX - Number
;        RDI - Array of numbers
;        R11 - Digits count
;        R10 - Divider
; Exit:  R11 - Digits count
;        RDI - Array of numbers
;-------------------------
ReadDec:
        xor r11, r11            ;r11 - digits count

        mov rdi, num_buff       ;rsi - buff for write digit(then buff will reverse)
        xor r10, r10
        mov r10, 10d            ;r10 is divider

.while_cond:
        cmp rax, 0              ;while (num != 0) .while_body
        jne .while_body

        dec rdi                 ;else ReverseStr(num_buff, digits count)
        mov r10, r11

        ret

.while_body:
        inc r11                 ;digits count++
        xor rdx, rdx

        idiv r10                ;dl = num % 10
        mov byte [rdi], dl      ;num_buff[i] = dl

        inc rdi
        jmp .while_cond

;-------------------------
; ReverseStr
;
; Converts numbers to their ASCII codes and 
; writes an inverted array to a buffer
;
; Entry: R11 - Digits count
;        RDI - Array of number's ASCII codes
;        
; Destr: RAX - Number's ASCII code
;        R10 - Number in array
;        RBX - If the special character is %d, then rbx = 0, 
;              if %h, then rbx = address to the array with the hex alphabet
;        RDI - Array of number's ASCII codes
;        RSI - Address of characters buffer
;        R11 - Digits count
;        
; Exit:  -
;-------------------------
ReverseStr:

        cmp r10, 0
        je .end

        mov byte al, [rdi]
        cmp rbx, 0
        jne .hex_part

.dec_part:
        add al, 30h
        jmp .put_in_buf
.hex_part:
        xlat

.put_in_buf:
        mov byte [rsi], al

        inc rsi
        check_buff
        dec rdi
        dec r10
        call ReverseStr

.end:
        ret

;-------------------------
; WriteBuff
;
; Prints the buffer
;
; Entry: RAX - Buffer size
; Destr: 
; Exit:  -
;-------------------------
WriteBuff:
        push rdx
        push rcx
        push r8
        push r9

        mov r8, rax
        mov rdx, buff

        sub rsp, 40          ;allocate memory in stack
        mov rcx, -11         ;STD_OUTPUT
        call GetStdHandle    ;GetStdHandle(STD_OUTPUT)    
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

;-------------------------
; WriteBuff
;
; Counts the number of characters in the buffer
;
; Entry: RSI - Сurrent address in the buffer
; Destr: RDI - Adress of buffer
;        RAX - Buffer size
; Exit:  RAX - Buffer size
;-------------------------

BuffLen:
        push rsi
        push rdi

        mov rdi, buff
        sub rsi, rdi

        mov rax, rsi

        pop rdi
        pop rsi
        ret
;--------------------------------