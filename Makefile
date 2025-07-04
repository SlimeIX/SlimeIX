CC ?= i686-elf-gcc
OBJCOPY ?= objcopy

INCLUDE=-Iinclude
ARCH=-m32

CFLAGS=-std=gnu99 -ffreestanding -O2 -Wall -Wextra $(INCLUDE) $(ARCH)
LDFLAGS=-T linker.ld -nostdlib -ffreestanding -O2 $(ARCH)

OBJ=boot/start.o boot/random.o kernel/main.o kernel/syscall.o kernel/console.o kernel/gtty.o mm/init.o lib/string.o

all: kernel.bin boot/boot0.bin boot/boot1.bin slimeix.img

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

boot/boot1.bin: boot/boot1.S
	$(CC) $(CFLAGS) -c $< -o $@.o
	$(OBJCOPY) -O binary $@.o $@

kernel.raw: kernel.bin
	$(OBJCOPY) -O binary $< $@

slimeix.img: boot/boot0.bin boot/boot1.bin kernel.raw
	dd if=/dev/zero of=$@ bs=1M count=32 >/dev/null 2>&1
	# write MBR
	dd if=boot/boot0.bin of=$@ conv=notrunc >/dev/null 2>&1
	# write boot1 after MBR (LBA 1..16)
	dd if=boot/boot1.bin of=$@ bs=512 seek=1 conv=notrunc >/dev/null 2>&1
	# write kernel raw after boot1 (start at LBA 17)
	dd if=kernel.raw of=$@ bs=512 seek=17 conv=notrunc >/dev/null 2>&1

clean:
	rm -f $(OBJ) kernel.bin 