global sepia_asm
extern sepia_matrix

section .text

sepia_asm:
  movaps xmm0, [sepia_matrix]
  ret
