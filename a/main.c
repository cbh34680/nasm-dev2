#include <stdio.h>
#include <stdlib.h>

extern void print_hello(void);

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

    return EXIT_SUCCESS;
}
