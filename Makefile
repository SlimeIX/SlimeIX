CC ?= i686-elf-gcc
OBJCOPY ?= objcopy

INCLUDE=-Iinclude
ARCH=-m32

CFLAGS=-std=gnu99 -ffreestanding -O2 -Wall -Wextra $(INCLUDE) $(ARCH)
LDFLAGS=-T linker.ld -nostdlib -ffreestanding -O2 $(ARCH)

OBJ=boot/start.o boot/random.o kernel/main.o kernel/syscall.o mm/init.o lib/string.o

all: kernel.bin boot/boot0.bin

%.o: %.S
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

kernel.bin: $(OBJ) linker.ld
	$(CC) $(LDFLAGS) $(OBJ) -o $@

# boot sector
boot/boot0.o: boot/boot0.S
	$(CC) $(CFLAGS) -c $< -o $@

boot/boot0.bin: boot/boot0.o
	$(OBJCOPY) -O binary $< $@

clean:
	rm -f $(OBJ) kernel.bin 