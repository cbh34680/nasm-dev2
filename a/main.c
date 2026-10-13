#include <stdio.h>
#include <stdlib.h>

extern void print_hello(void);
extern void print_data(const void*, size_t);

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

int main(void)
{
    struct data_t data = gendata(50);

    print_hello();
    print_data("abcde", 6);
    puts("");

    void* a = malloc(33);
    void* b = malloc(1);

    printf("%lu %lu %lu\n", a, b, b - a);

    return EXIT_SUCCESS;
}
