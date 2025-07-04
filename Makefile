CC ?= i686-elf-gcc

INCLUDE=-Iinclude
ARCH=-m32

CFLAGS=-std=gnu99 -ffreestanding -O2 -Wall -Wextra $(INCLUDE) $(ARCH)
LDFLAGS=-T linker.ld -nostdlib -ffreestanding -O2 $(ARCH)

OBJ=boot/start.o boot/random.o kernel/main.o kernel/syscall.o mm/init.o lib/string.o

all: kernel.bin

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

kernel.bin: $(OBJ) linker.ld
	$(CC) $(LDFLAGS) $(OBJ) -o $@

clean:
	rm -f $(OBJ) kernel.bin 