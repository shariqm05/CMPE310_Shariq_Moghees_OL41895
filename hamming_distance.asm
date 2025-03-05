section .data
    newline db 10 ; newline character
    prompt1 db "Enter first string: ", 0
    prompt2 db "Enter second string: ", 0

section .bss
    str1 resb 256; reserve 255 bytes for each string +1 for newline
    str2 resb 256;
    hamming_char resb 1; reserve space for 1 character

    len1 resb 1 ; str length variables
    len2 resb 1

section .text
    global _start
_start:

    ;Prompt for first string
    mov eax, 4 ;sys_write
    mov ebx, 1 ;file descriptor stdout
    mov ecx, prompt1
    mov edx, 21 ;length of mesg
    int 0x80

    ;input processing for str1
    mov eax, 3 ;sys_read
    mov ebx, 0 ;stdin
    mov ecx, str1
    mov edx, 256 ;max characters +1 for newline
    int 0x80; kernel

    ;Calculate len1
    lea ecx, [str1]
    call calc_len
    mov [len1], al ;store length in len1

    ;Prompt for second string
    mov eax, 4 ;sys_write
    mov ebx, 1 ;file descriptor stdout
    mov ecx, prompt2
    mov edx, 21 ;length of msg2
    int 0x80

    ;input processing for str2
    mov eax, 3 ;sys_read
    mov ebx, 0 ;stdin
    mov ecx, str2
    mov edx, 256 ;max characters +1 for newline
    int 0x80; kernel

    ;Calculate len2
    lea ecx, [str2]
    call calc_len
    mov [len2], al ;store length in len2

    ;Compare len1 and len2 and truncate longer one
    mov al, [len1]
    mov bl, [len2]
    cmp al, bl ;compare both
    jbe use_len1 ;len 1 is shorter
    movzx ecx, bl ;len 2 ia shorter
    jmp len_set

use_len1:
    movzx ecx, al

len_set:
    ; Initialize pointers to strings
    mov esi, str1
    mov edi, str2

    ; Zero out hamming distance counter
    xor ebx, ebx

compare_loop:
    ; Load a character from each string
    mov al, [esi]
    mov dl, [edi]

    ; XOR to find differing bits
    xor al, dl
    
    ; zero out edx
    xor edx, edx

count_bits:
    shr al, 1  ; shift right, moving lowest bit into CF
    adc dl, 0 ; add CF to dl
    test al, al ; check if byte is empty (no 1s left)
    jnz count_bits ; loop unitl byte is empty

    ; Add result to overall Hamming Distance (in ebx)
    add ebx, edx

    ; Move to next characters by incrementing char pointers
    inc esi
    inc edi
    loop compare_loop

    ; Convert final Hamming Distance to ASCII ('0' + distance)
    add bl, '0'

    ; Store ASCII character in reserved space
    mov [hamming_char], bl

    ; print
    mov eax, 4 ;sys_write
    mov ebx, 1 ;file descriptor stdout
    mov ecx, hamming_char
    mov edx, 1 ;length (1 byte for one number)
    int 0x80

    ; Exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80

calc_len:
    xor eax, eax ;zero out
len_loop:
    cmp byte [ecx+eax], 10
    je len_done 
    inc eax 
    cmp eax, 255
    je len_done
    jmp len_loop ;repeat for next character
len_done:
    ret

    
