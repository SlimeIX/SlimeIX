#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

void die(const char *str) {
    fprintf(stderr, "%s\n", str);
    exit(1);
}

int main(int argc, char **argv) {
    int fd, i;
    char buf[512];
    
    if (argc != 4) {
        die("Usage: build boot0 boot1 kernel > image");
    }
    
    // Write boot0 (MBR)
    if ((fd = open(argv[1], O_RDONLY)) < 0)
        die("Cannot open boot0");
    if (read(fd, buf, 512) != 512)
        die("Cannot read boot0");
    if (write(1, buf, 512) != 512)
        die("Cannot write boot0");
    close(fd);
    
    // Write boot1 (16 sectors)
    if ((fd = open(argv[2], O_RDONLY)) < 0)
        die("Cannot open boot1");
    for (i = 0; i < 16; i++) {
        if (read(fd, buf, 512) != 512)
            die("Cannot read boot1");
        if (write(1, buf, 512) != 512)
            die("Cannot write boot1");
    }
    close(fd);
    
    // Write kernel
    if ((fd = open(argv[3], O_RDONLY)) < 0)
        die("Cannot open kernel");
    while ((i = read(fd, buf, 512)) > 0) {
        if (write(1, buf, i) != i)
            die("Cannot write kernel");
    }
    close(fd);
    
    return 0;
} 