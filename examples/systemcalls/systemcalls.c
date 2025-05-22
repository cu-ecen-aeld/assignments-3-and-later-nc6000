#include "systemcalls.h"
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <stdarg.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <fcntl.h>

bool do_system(const char *cmd)
{
    if (cmd == NULL) {
        fprintf(stderr, "do_system error: command is NULL\n");
        return false;
    }

    int ret = system(cmd);
    if (ret == -1) {
        perror("do_system error: system() call failed");
        return false;
    }
    if (!WIFEXITED(ret) || WEXITSTATUS(ret) != 0) {
        fprintf(stderr, "do_system error: command exited with status %d\n", WEXITSTATUS(ret));
        return false;
    }
    return true;
}

bool do_exec(int count, ...)
{
    if (count < 1) {
        fprintf(stderr, "do_exec error: no command specified (count=%d)\n", count);
        return false;
    }

    va_list args;
    va_start(args, count);
    
    char * command[count + 1];
    for (int i = 0; i < count; i++)
    {
        command[i] = va_arg(args, char *);
        if (command[i] == NULL) {
            fprintf(stderr, "do_exec error: argument %d is NULL\n", i);
            va_end(args);
            return false;
        }
    }
    command[count] = NULL;
    va_end(args);

    pid_t pid = fork();

    if (pid == -1)
    {
        perror("do_exec error: fork failed");
        return false;
    }
    else if (pid == 0)
    {
        execv(command[0], command);
        perror("do_exec error: execv failed");
        exit(EXIT_FAILURE);
    }
    else
    {
        int status;
        if (waitpid(pid, &status, 0) == -1)
        {
            perror("do_exec error: waitpid failed");
            return false;
        }

        if (!WIFEXITED(status)) {
            fprintf(stderr, "do_exec error: child did not exit normally\n");
            return false;
        }
        if (WEXITSTATUS(status) != 0) {
            fprintf(stderr, "do_exec error: child exited with status %d\n", WEXITSTATUS(status));
            return false;
        }

        return true;
    }
}

bool do_exec_redirect(const char *outputfile, int count, ...)
{
    if (outputfile == NULL) {
        fprintf(stderr, "do_exec_redirect error: outputfile is NULL\n");
        return false;
    }
    if (count < 1) {
        fprintf(stderr, "do_exec_redirect error: no command specified (count=%d)\n", count);
        return false;
    }

    va_list args;
    va_start(args, count);
    
    char * command[count + 1];
    for (int i = 0; i < count; i++)
    {
        command[i] = va_arg(args, char *);
        if (command[i] == NULL) {
            fprintf(stderr, "do_exec_redirect error: argument %d is NULL\n", i);
            va_end(args);
            return false;
        }
    }
    command[count] = NULL;
    va_end(args);

    pid_t pid = fork();

    if (pid == -1)
    {
        perror("do_exec_redirect error: fork failed");
        return false;
    }
    else if (pid == 0)
    {
        int fd = open(outputfile, O_WRONLY | O_CREAT | O_TRUNC, 0644);
        if (fd < 0)
        {
            perror("do_exec_redirect error: open failed");
            exit(EXIT_FAILURE);
        }

        if (dup2(fd, STDOUT_FILENO) < 0)
        {
            perror("do_exec_redirect error: dup2 failed");
            close(fd);
            exit(EXIT_FAILURE);
        }

        close(fd);
        execv(command[0], command);
        perror("do_exec_redirect error: execv failed");
        exit(EXIT_FAILURE);
    }
    else
    {
        int status;
        if (waitpid(pid, &status, 0) == -1)
        {
            perror("do_exec_redirect error: waitpid failed");
            return false;
        }

        if (!WIFEXITED(status)) {
            fprintf(stderr, "do_exec_redirect error: child did not exit normally\n");
            return false;
        }
        if (WEXITSTATUS(status) != 0) {
            fprintf(stderr, "do_exec_redirect error: child exited with status %d\n", WEXITSTATUS(status));
            return false;
        }

        return true;
    }sys
}

