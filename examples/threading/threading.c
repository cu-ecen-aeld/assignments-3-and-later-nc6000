#include "threading.h"
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

void* threadfunc(void* thread_param) {
    struct thread_data* data = (struct thread_data*) thread_param;

    // Initial success = false
    data->thread_complete_success = false;

    // Sleep before locking
    if (data->wait_to_obtain_ms > 0) {
        usleep(data->wait_to_obtain_ms * 1000);  // convert ms to us
    }

    // Lock mutex
    if (pthread_mutex_lock(data->mutex) != 0) {
        return data;
    }

    // Sleep after locking
    if (data->wait_to_release_ms > 0) {
        usleep(data->wait_to_release_ms * 1000);
    }

    // Unlock mutex
    if (pthread_mutex_unlock(data->mutex) != 0) {
        return data;
    }

    // If all operations succeeded
    data->thread_complete_success = true;
    return data;
}

bool start_thread_obtaining_mutex(pthread_t *thread, pthread_mutex_t *mutex,
                                  int wait_to_obtain_ms, int wait_to_release_ms) {
    struct thread_data* data = malloc(sizeof(struct thread_data));
    if (data == NULL) {
        return false;
    }

    data->mutex = mutex;
    data->wait_to_obtain_ms = wait_to_obtain_ms;
    data->wait_to_release_ms = wait_to_release_ms;
    data->thread_complete_success = false;

    int rc = pthread_create(thread, NULL, threadfunc, data);
    if (rc != 0) {
        free(data);
        return false;
    }

    return true;
}

