#include <stdio.h>
#include <time.h>
#include <unistd.h>
#include <pwd.h>

int main(void) {
    time_t now = time(NULL);
    struct tm *tm = localtime(&now);
    struct passwd *pw = getpwuid(getuid());
    
    printf("#define SLIMEIX_VERSION \"0.1.0\"\n");
    printf("#define SLIMEIX_COMPILE_TIME \"%02d:%02d:%02d\"\n", 
           tm->tm_hour, tm->tm_min, tm->tm_sec);
    printf("#define SLIMEIX_COMPILE_DATE \"%04d-%02d-%02d\"\n",
           tm->tm_year + 1900, tm->tm_mon + 1, tm->tm_mday);
    printf("#define SLIMEIX_COMPILE_BY \"%s\"\n", pw ? pw->pw_name : "unknown");
    
    char hostname[256];
    if (gethostname(hostname, sizeof(hostname)) == 0)
        printf("#define SLIMEIX_COMPILE_HOST \"%s\"\n", hostname);
    else
        printf("#define SLIMEIX_COMPILE_HOST \"unknown\"\n");
    
    return 0;
} 