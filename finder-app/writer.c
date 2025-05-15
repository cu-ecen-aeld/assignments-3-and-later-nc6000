#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <syslog.h>

int main(int argc, char *argv[]) {
    // Open syslog with LOG_USER facility
    openlog("writer", LOG_PID, LOG_USER);

    if (argc != 3) {
        syslog(LOG_ERR, "Exactly two arguments are required: <file> <string>");
        fprintf(stderr, "Usage: writer <file> <string>\n");
        closelog();
        return 1;
    }

    char *writefile = argv[1];
    char *writestr = argv[2];

    // Attempt to open the file for writing
    FILE *fp = fopen(writefile, "w");
    if (fp == NULL) {
        syslog(LOG_ERR, "Error opening file '%s': %s (errno=%d)", writefile, strerror(errno), errno);
        fprintf(stderr, "Custom Error: could not open file '%s'\n", writefile);
        closelog();
        return 1;
    }

    // Write the string to the file
    if (fprintf(fp, "%s", writestr) < 0) {
        syslog(LOG_ERR, "Error writing to file '%s': %s (errno=%d)", writefile, strerror(errno), errno);
        fprintf(stderr, "Custom Error: could not write to file '%s'\n", writefile);
        fclose(fp);
        closelog();
        return 1;
    }

    // Flush and close file
    fclose(fp);

    // Log the successful write to syslog
    syslog(LOG_DEBUG, "Writing '%s' to '%s'", writestr, writefile);
    closelog();

    // Display the messages as requested
    printf("File written: %s\n", writefile);
    printf("String written: %s\n", writestr);

    return 0;
}

