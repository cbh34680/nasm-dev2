#include <stdio.h>
#include <inttypes.h>
#include <stddef.h>
#include <stdlib.h>
#include <pthread.h>

static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
static pthread_cond_t cond = PTHREAD_COND_INITIALIZER;
static int go = 0;

/*
#include <stdatomic.h>
_Atomic*/
static int g_count = 0;

#if 0
pthread_mutex_t m_count = PTHREAD_MUTEX_INITIALIZER;

static void lock_count()
{
    pthread_mutex_lock(&m_count);
}

static void unlock_count()
{
    pthread_mutex_unlock(&m_count);
}

#else
// Test-and-Test-and-Set
extern void lock_count();
extern void unlock_count();

#endif


static void* worker(void* arg)
{
    pthread_mutex_lock(&mutex);
    while (!go) {
        pthread_cond_wait(&cond, &mutex);
    }
    pthread_mutex_unlock(&mutex);

    for (int i=0; i<100000; ++i) {
        lock_count();
        ++g_count;
        unlock_count();
    }

    return NULL;
}

void test_thread()
{
    pthread_t t[10];

    for (int i=0; i<(sizeof(t) / sizeof(t[0])); ++i) {
        pthread_create(&t[i], NULL, worker, NULL);
    }

    pthread_mutex_lock(&mutex);
    go = 1;
    pthread_cond_broadcast(&cond);
    pthread_mutex_unlock(&mutex);

    for (int i=0; i<(sizeof(t) / sizeof(t[0])); ++i) {
        pthread_join(t[i], NULL);
    }

    printf("count=%d\n", g_count);

    puts("leave test_thread()");
}
