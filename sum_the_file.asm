section .data
    ;formatted string vars for reading the ints and printing sum
    scanf_fmt db "%d", 0
    printf_fmt db "Sum is: %d", 10, 0
    count_fmt db "Count Read: %d", 10, 0
    debug_fmt db "Read: %d", 10, 0
    ;puts the file into read mode
    file_mode db "r", 0
    fscanf_err_fmt db "fscanf faile at line %d", 10, 0

section .bss
    count resd 1      ;hold number of ints to read at the loop
    temp resd 1	  ;temp var for input
    file_ptr resd 1	  ;hold file location returned by fopen
    sum resd 1	  ;hold total sum
    arr resd 1000 ;arr to hold intgers from file up to 1000 max
	
section .text
    global main
    extern fopen, fscanf, printf

main:
    push    ebp
    mov     ebp, esp

    mov     eax, [ebp+12]       ;argv pointer
    mov     eax, [eax+4]        ;get argv[1] string
    push    file_mode           ; push "rb"
    push    eax
    call    fopen
    add     esp, 8              ; clean up stack
    mov     [file_ptr], eax     ; save file pointer

    call    ReadCount
    call    ReadIntegers
    call    CalculateSum
    call    PrintSum

    mov     esp, ebp
    pop     ebp
    ret

ReadCount: ;Reads the first line to set the loop (count) var in .bss
    push    count               ; store the first int in count
    push    scanf_fmt           ; "%d"
    push    dword [file_ptr]    ; file ptr
    call    fscanf
    add     esp, 12

    mov     eax, [count]
    push    eax
    push    count_fmt          ; debug print count value
    call    printf
    add     esp, 8

    ret

ReadIntegers: ;loops through with count var to initialize the array
    xor     ebx, ebx            ;zero out index = 0

.loop:
    cmp     ebx, [count]
    jge     .done               ;if i >= count, terminate the loop

    push    temp                ;store in temp
    push    scanf_fmt
    push    dword [file_ptr]
    call    fscanf
    add     esp, 12

    cmp     eax, 1              ;check fscanf success
    jne     .fscanf_fail    	;jump to the fcanf err msg subroutine

    mov     eax, [temp]         ;get val from temp
    mov     [arr+ebx*4], eax    ;store at arr[ebx]

    push    eax                 ;debug print value read
    push    debug_fmt
    call    printf
    add     esp, 8

    inc     ebx                 ;index increment
    jmp     .loop               ;next loop iteration

.fscanf_fail:
    push ebx
    push fscanf_err_fmt
    call printf
    add esp, 8 		;clean stack
    jmp .done

.done:
    ret

CalculateSum: ;Iterate through the array and sum all the integers
    xor     eax, eax            ;sum
    xor     ebx, ebx            ;index

    mov     ecx, [count]        ;loop limit

.loop:
    cmp     ebx, ecx
    jge     .done

    mov     edx, [arr + ebx*4]  ; get arr[ebx]
    add     eax, edx            ; sum += arr[ebx]

    inc     ebx
    jmp     .loop               ;next iteration

.done:
    mov     [sum], eax          ; store result in `sum`
    ret

PrintSum: ;print call to print the sum
    mov     eax, [sum]          ; move value into eax
    push    eax                 ; second arg to printf
    push    printf_fmt          ; formatted string
    call    printf
    add     esp, 8
    ret
