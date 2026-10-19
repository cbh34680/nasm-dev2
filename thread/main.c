#include <stdio.h>
#include <inttypes.h>
#include <stddef.h>
#include <stdlib.h>
#include <pthread.h>

static void test_memory();
extern void test_thread();
extern void test_sem();

int main(void)
{
    test_memory();
    //test_thread();
    test_sem();

    return EXIT_SUCCESS;
}

struct data_t
{
    int i;
    short s;
    char c[2];
    long l;
    char ss[32];
};

struct data_t gendata(int i)
{
    struct data_t data = { .i=i, .l=101, .ss="abc" };
    return data;
}

static void test_memory()
{
    extern void print_hello(void);
    extern void print_data(const void*, size_t);

    char x;
    int y;
    double z;

    ptrdiff_t xy = (char*)&x - (char*)&y;
    ptrdiff_t yz = (char*)&y - (char*)&z;

    struct data_t data = gendata(50);

    print_hello();
    print_data("abcde", 6);
    puts("");

    void* a = malloc(33);
    void* b = malloc(1);
    ptrdiff_t c = (char*)b - (char*)a;

    printf("HEAP: a=%p b=%p b-a=%" PRIxPTR "\n", a, b, c);
    printf("main=%p\n", (void*)main);
    printf("STACK: x=%p y=%p z=%p\n", &x, &y, &z);
    printf("STACK: x-y=%" PRIxPTR " y-z=%" PRIxPTR "\n", xy, yz);

    free(a);
    free(b);
}
