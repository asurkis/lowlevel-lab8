global sepia_asm
; extern sepia_matrix

section .text

%xdefine REFORMAT_SIZE (4 * 12)
%xdefine MATRIX_SIZE (4 * 4 * 3 * 3)
%xdefine STACK_SIZE (REFORMAT_SIZE + MATRIX_SIZE)

; rdi -- адрес матрицы
; rsi -- адрес буфера
; rdx -- размер буфера
sepia_asm:
    sub rsp, STACK_SIZE

    mov rcx, REFORMAT_SIZE / 8
  .zero_loop:
    mov qword [rsp + 8*rcx - 8], 0
    loop .zero_loop

    ; rcx идет по половинкам float'ов в матрице
    ; с шагом 2 (т.е. по одному float'у)
    mov rcx, MATRIX_SIZE / 2
  .matrix_copy_loop:
    mov eax, [rdi + 2*rcx - 4]
    mov [rsp + 8*rcx + (REFORMAT_SIZE - 4)], eax
    mov [rsp + 8*rcx + (REFORMAT_SIZE + 0)], eax
    mov [rsp + 8*rcx + (REFORMAT_SIZE + 4)], eax
    mov [rsp + 8*rcx + (REFORMAT_SIZE + 8)], eax
    dec rcx
    loop .matrix_copy_loop

    ; [rsp; rsp + REFORMAT_SIZE) -- для преобразования байтов
    ; [rsp + REFORMAT_SIZE ; rsp + REFORMAT_SIZE + MATRIX_SIZE) -- для матрицы

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
    anx r12, 0xFF0000
    shr r9, 16
    shr r11, 8
    shr r12, 16
    or r10, r9

    mov rax, [rsi+4] ; g2 b2 r3 g3
    mov r9, rax
    mov r13, rax
    mov r14, rax
    mov r15, rax
    and r9, 0xFF
    and r13, 0xFF00
    and r14, 0xFF0000
    and r15, 0xFF000000
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
    and r9, 0xFF
    and r13, 0xFF00
    and r14, 0xFF0000
    and r15, 0xFF000000
    shl r9, 16
    shl r13, 16
    shl r14, 8
    or r12, r9
    or r10, r13
    or r11, r14
    or r12, r15

    movq xmm0, r10
    movq xmm1, r11
    movq xmm2, r12

    punpcklbw xmm0, xmm0
    punpcklbw xmm1, xmm1
    punpcklbw xmm2, xmm2

    add rsi, 12
    dec rcx
    jnz .processing_loop
    add rsp, STACK_SIZE
    ret


;    mov r10d, [rsi+0] ; r1 g1 b1 r2
;    mov r11d, [rsi+4] ; g2 b2 r3 g3
;    mov r12d, [rsi+8] ; b3 r4 g4 b4
;
;    movq xmm0, r10
;    movq xmm1, r11
;    movq xmm2, r12
;
;    ; r1 (-48 ;  +0) r2 (-44 ;  +4) r3 (-40 ;  +8) r4 (-36 ; +12)
;    ; g1 (-32 ; +16) g2 (-28 ; +20) g3 (-24 ; +24) g4 (-20 ; +28)
;    ; b1 (-16 ; +32) b2 (-12 ; +36) b3 ( -8 ; +40) b4 ( -4 ; +44)
;
;    mov [rsp+ 0], r10b ; r1
;    mov [rsp+20], r11b ; g2
;    mov [rsp+40], r12b ; b3
;
;    shr r10, 8
;    shr r11, 8
;    shr r12, 8
;
;    mov [rsp+16], r10b ; g1
;    mov [rsp+36], r11b ; b2
;    mov [rsp+12], r12b ; r4
;
;    shr r10, 8
;    shr r11, 8
;    shr r12, 8
;
;    mov [rsp+32], r10b ; b1
;    mov [rsp+ 8], r11b ; r3
;    mov [rsp+28], r12b ; g4
;
;    shr r10, 8
;    shr r11, 8
;    shr r12, 8
;
;    mov [rsp+ 4], r10b ; r2
;    mov [rsp+24], r11b ; g3
;    mov [rsp+44], r12b ; b4
;
;    ; Закончили запись в стек в правильном порядке
;    ; Загружаем в SSE регистры
;    movaps xmm0, [rsp+ 0] ; r1, r2, r3, r4
;    movaps xmm1, [rsp+16] ; g1, g2, g3, g4
;    movaps xmm2, [rsp+32] ; b1, b2, b3, b4
;    cvtdq2ps xmm0, xmm0
;    cvtdq2ps xmm1, xmm1
;    cvtdq2ps xmm2, xmm2
;
;    ; Арифметика
;
;    movaps xmm3, xmm0
;    movaps xmm4, xmm1
;    movaps xmm5, xmm2
;    mulps xmm3, [rsp + (REFORMAT_SIZE + 4 * 4 * 0)]
;    mulps xmm4, [rsp + (REFORMAT_SIZE + 4 * 4 * 1)]
;    mulps xmm5, [rsp + (REFORMAT_SIZE + 4 * 4 * 2)]
;    ;

