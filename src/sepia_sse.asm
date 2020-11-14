global sepia_asm
; extern sepia_matrix

section .text

; rdi -- адрес матрицы
; rsi -- адрес буфера
; rdx -- размер буфера
sepia_asm:
    ; rsi указывает на начало блока из 4 пикселей, который обрабатываем
    mov rcx, rdx
  .processing_loop:
    mov rax, [rsi+0] ; r1 g1 b1 r2
    mov r9, rax
    mov r10, rax
    mov r11, rax
    mov r12, rax
    and r9, 0xFF00
    and r10, 0xFF
    and r11, 0xFF00
    and r12, 0xFF0000
    shr r9, 16
    shr r11, 8
    shr r12, 16
    or r10, r9

    mov rax, [rsi+4] ; g2 b2 r3 g3
    mov r9, rax
    mov r13, rax
    mov r14, rax
    mov r15, rax
    mov rax, 0xFF000000 ; не влезает в immediate
    and r9, 0xFF
    and r13, 0xFF00
    and r14, 0xFF0000
    and r15, rax
    shl r9, 8
    shr r15, 8
    or r11, r9
    or r12, r13
    or r10, r14
    or r11, r15

    mov rax, [rsi+8] ; b3 r4 g4 b4
    mov r9, rax
    mov r13, rax
    mov r14, rax
    mov r15, rax
    mov rax, 0xFF000000 ; не влезает в immediate
    and r9, 0xFF
    and r13, 0xFF00
    and r14, 0xFF0000
    and r15, rax
    shl r9, 16
    shl r13, 16
    shl r14, 8
    or r12, r9
    or r10, r13
    or r11, r14
    or r12, r15

    ; r10 -- r1 r2 r3 r4
    ; r11 -- g1 g2 g3 g4
    ; r12 -- b1 b2 b3 b4

    movq xmm0, r10
    movq xmm1, r11
    movq xmm2, r12
    pxor xmm3, xmm3

    punpcklbw xmm0, xmm3
    punpcklbw xmm1, xmm3
    punpcklbw xmm2, xmm3

    punpcklwd xmm0, xmm3
    punpcklwd xmm1, xmm3
    punpcklwd xmm2, xmm3

    cvtdq2ps xmm0, xmm0 ; r1-4
    cvtdq2ps xmm1, xmm1 ; g1-4
    cvtdq2ps xmm2, xmm2 ; b1-4

    ; Арифметика

    ; Загрузка строки
    mov r13, [rdi+0]
    mov r14, [rdi+4]
    mov r15, [rdi+8]

    movq xmm3, r13
    movq xmm4, r14
    movq xmm5, r15

    punpckldq xmm3, xmm3
    punpckldq xmm4, xmm4
    punpckldq xmm5, xmm5

    punpcklqdq xmm3, xmm3
    punpcklqdq xmm4, xmm4
    punpcklqdq xmm5, xmm5

    ; Перемножение
    mulps xmm3, xmm0
    mulps xmm4, xmm1
    mulps xmm5, xmm2

    ; Сохранение результата
    movq xmm6, xmm3
    addps xmm6, xmm4
    addps xmm6, xmm5

    ; Загрузка строки
    mov r13, [rdi+12]
    mov r14, [rdi+16]
    mov r15, [rdi+20]

    movq xmm4, r13
    movq xmm5, r14
    movq xmm6, r15

    punpckldq xmm4, xmm4
    punpckldq xmm5, xmm5
    punpckldq xmm6, xmm6

    punpcklqdq xmm4, xmm4
    punpcklqdq xmm5, xmm5
    punpcklqdq xmm6, xmm6

    ; Перемножение
    mulps xmm4, xmm0
    mulps xmm5, xmm1
    mulps xmm6, xmm2

    ; Сохранение результата
    addps xmm4, xmm5
    addps xmm4, xmm6

    ; Загрузка строки
    mov r13, [rdi+24]
    mov r14, [rdi+28]
    mov r15, [rdi+32]

    movq xmm5, r13
    movq xmm6, r14
    movq xmm7, r15

    punpckldq xmm5, xmm5
    punpckldq xmm6, xmm6
    punpckldq xmm7, xmm7

    punpcklqdq xmm5, xmm5
    punpcklqdq xmm6, xmm6
    punpcklqdq xmm7, xmm7

    ; Перемножение
    mulps xmm5, xmm0
    mulps xmm6, xmm1
    mulps xmm7, xmm2

    ; Сохранение результата
    addps xmm5, xmm6
    addps xmm5, xmm7

    ; Результаты в xmm3-5
    cvtps2dq xmm3, xmm3
    cvtps2dq xmm4, xmm4
    cvtps2dq xmm5, xmm5

    packusdw xmm3, xmm3
    packusdw xmm4, xmm4
    packusdw xmm5, xmm5

    packuswb xmm3, xmm3
    packuswb xmm4, xmm4
    packuswb xmm5, xmm5

    movq r10, xmm3 ; r1 r2 r3 r4
    movq r11, xmm4 ; g1 g2 g3 g4
    movq r12, xmm5 ; b1 b2 b3 b4

    ; Упаковка
    mov rax, r10
    mov r13, r11
    mov r14, r12
    mov r15, r10
    and rax, 0xFF
    and r13, 0xFF
    and r14, 0xFF
    and r15, 0xFF00
    shl r13, 8
    shl r14, 16
    shl r15, 16
    or r14, r15
    or rax, r13
    or rax, r14
    mov [rsi+4], rax ; r1 g1 b1 r2

    mov rax, r11
    mov r13, r12
    mov r14, r10
    mov r15, r11
    and rax, 0xFF00
    and r13, 0xFF00
    and r14, 0xFF0000
    and r15, 0xFF0000
    shr rax, 8
    shl r15, 8
    or r14, r15
    or rax, r13
    or rax, r14
    mov [rsi+0], rax ; g2 b2 r3 g3

    mov rax, r12
    mov r13, r10
    mov r14, r11
    mov r15, r12
    shr rax, 16
    shr r13, 16
    shr r14, 8
    mov r9, 0xFF000000 ; не влезает в immediate
    and rax, 0xFF
    and r13, 0xFF00
    and r14, 0xFF0000
    and r15, r9
    or r14, r15
    or rax, r13
    or rax, r14
    mov [rsi+8], rax ; b3 r4 g4 b4
%ifdef NOT_DEFINED
%endif

    add rsi, 12
    dec rcx
    jnz .processing_loop
    ret
