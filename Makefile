CC = gcc
CFLAGS = -std=c89 -pedantic-errors -fPIE # -Wall -Werror
AS = nasm
ASFLAGS = -f elf64

default: build

clean:
	rm -rf out

build: out/sepia_sse.asm.o out/main.c.o out/image.c.o out/bmp.c.o
	$(CC) $(CFLAGS) out/*.o -o out/lab8

out/sepia_sse.asm.o: src/sepia_sse.asm
	mkdir -p out
	$(AS) $(ASFLAGS) src/sepia_sse.asm -o out/sepia_sse.asm.o

out/%.o: src/%
	mkdir -p out
	$(CC) $(CFLAGS) src/$* -c -o out/$*.o
