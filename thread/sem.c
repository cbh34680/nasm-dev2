#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <stdbool.h>
#include <semaphore.h>
#include <unistd.h>
#include <time.h>

static sem_t sem;
static _Atomic int semval[5] = { 0 };

static pthread_mutex_t start_mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t start_cond = PTHREAD_COND_INITIALIZER;
static _Bool go = false;

static void* worker(void* arg)
{
    const int worker_id = (int)(intptr_t)arg;

    pthread_mutex_lock(&start_mutex);
    while (!go) {
        pthread_cond_wait(&start_cond, &start_mutex);
    }
    printf("worker_id=%d\n", worker_id);
    pthread_mutex_unlock(&start_mutex);

    for (int i=0; i<10; ++i) {
        sem_wait(&sem);

        int val;
        sem_getvalue(&sem, &val);
        semval[val]++;
        sleep(1);

        sem_post(&sem);
    }

    return NULL;
}

void test_sem()
{
    time_t s = time(NULL);
    sem_init(&sem, 0, 4);

    pthread_t t[10];

    for (int i=0; i<(sizeof(t) / sizeof(t[0])); ++i) {
        pthread_create(&t[i], NULL, worker, (void*)(intptr_t)i);
    }

    pthread_mutex_lock(&start_mutex);
    go = true;
    pthread_cond_broadcast(&start_cond);
    pthread_mutex_unlock(&start_mutex);

    for (int i=0; i<(sizeof(t) / sizeof(t[0])); ++i) {
        pthread_join(t[i], NULL);
    }

    sem_destroy(&sem);

    for (int i=0; i<(sizeof(semval)/sizeof(semval[0])); ++i) {
        printf("semval[%d]=%d\n", i, semval[i]);
    }

    printf("time=%ld\n", time(NULL) - s);
}
