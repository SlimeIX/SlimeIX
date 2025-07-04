CC ?= i686-elf-gcc
OBJCOPY ?= objcopy

INCLUDE=-Iinclude
ARCH=-m32

CFLAGS=-std=gnu99 -ffreestanding -O2 -Wall -Wextra $(INCLUDE) $(ARCH)
CFLAGS += -include version.h

LDFLAGS=-T linker.ld -nostdlib -ffreestanding -O2 $(ARCH)

OBJ=boot/start.o boot/random.o kernel/main.o kernel/syscall.o kernel/console.o kernel/gtty.o kernel/version.o mm/init.o lib/string.o

all: kernel.bin boot/boot0.bin boot/boot1.bin slimeix.img

version.h: tools/version
	./tools/version > $@

tools/build: tools/build.c
	$(CC) -o $@ $<

tools/version: tools/version.c
	$(CC) -o $@ $<

%.o: %.S version.h
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.c version.h
	$(CC) $(CFLAGS) -c $< -o $@

kernel.bin: $(OBJ) linker.ld version.h
	$(CC) $(LDFLAGS) $(OBJ) -o $@

boot/boot0.o: boot/boot0.S
	$(CC) $(CFLAGS) -c $< -o $@

boot/boot0.bin: boot/boot0.o
	$(OBJCOPY) -O binary $< $@

boot/boot1.bin: boot/boot1.S
	$(CC) $(CFLAGS) -c $< -o $@.o
	$(OBJCOPY) -O binary $@.o $@

kernel.raw: kernel.bin
	$(OBJCOPY) -O binary $< $@

slimeix.img: tools/build boot/boot0.bin boot/boot1.bin kernel.raw
	tools/build boot/boot0.bin boot/boot1.bin kernel.raw CURRENT > $@

clean:
	rm -f $(OBJ) kernel.bin boot/*.o boot/*.bin tools/build tools/version kernel.raw slimeix.img version.h 