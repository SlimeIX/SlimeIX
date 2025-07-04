#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/sysmacros.h>

#define BOOT0_MAX_SIZE 510
#define BOOT1_SECTORS 16
#define KERNEL_MAX_SIZE (512 * 1024)  // 512KB max

void die(const char *str) {
    fprintf(stderr, "%s\n", str);
    exit(1);
}

void usage(void) {
    die("Usage: build boot0 boot1 kernel [rootdev] [> image]");
}

int main(int argc, char **argv) {
    int fd, i, c;
    char buf[512];
    struct stat sb;
    char major_root = 0, minor_root = 0;
    
    if (argc < 4 || argc > 5)
        usage();
    
    if (argc == 5) {
        if (!strcmp(argv[4], "CURRENT")) {
            if (stat("/", &sb)) {
                perror("/");
                die("Couldn't stat /");
            }
            major_root = major(sb.st_dev);
            minor_root = minor(sb.st_dev);
        } else if (strcmp(argv[4], "FLOPPY")) {
            if (stat(argv[4], &sb)) {
                perror(argv[4]);
                die("Couldn't stat root device");
            }
            major_root = major(sb.st_rdev);
            minor_root = minor(sb.st_rdev);
        }
    }
    fprintf(stderr, "Root device is (%d, %d)\n", major_root, minor_root);
    
    if ((fd = open(argv[1], O_RDONLY)) < 0)
        die("Cannot open boot0");
    
    if (read(fd, buf, 512) != 512)
        die("Cannot read boot0");
    
    for (i = 0; i < BOOT0_MAX_SIZE; i++) {
        if (buf[i] == 0) break;
    }
    if (i >= BOOT0_MAX_SIZE)
        die("Boot0 exceeds 510 bytes");
    
    if (*(unsigned short*)(buf + 510) != 0xAA55)
        die("Boot0 missing signature (0xAA55)");
    
    buf[508] = minor_root;
    buf[509] = major_root;
    
    fprintf(stderr, "Boot0: %d bytes\n", i);
    
    if (write(1, buf, 512) != 512)
        die("Cannot write boot0");
    close(fd);
    
    if ((fd = open(argv[2], O_RDONLY)) < 0)
        die("Cannot open boot1");
    
    for (i = 0; i < BOOT1_SECTORS; i++) {
        if (read(fd, buf, 512) != 512)
            die("Cannot read boot1");
        if (write(1, buf, 512) != 512)
            die("Cannot write boot1");
    }
    close(fd);
    fprintf(stderr, "Boot1: %d sectors\n", BOOT1_SECTORS);
    
    if ((fd = open(argv[3], O_RDONLY)) < 0)
        die("Cannot open kernel");
    
    i = 0;
    while ((c = read(fd, buf, 512)) > 0) {
        if (write(1, buf, c) != c)
            die("Cannot write kernel");
        i += c;
    }
    close(fd);
    
    if (i > KERNEL_MAX_SIZE)
        die("Kernel too large");
    
    fprintf(stderr, "Kernel: %d bytes\n", i);
    fprintf(stderr, "Image: %d bytes total\n", 512 + BOOT1_SECTORS * 512 + i);
    
    return 0;
} 