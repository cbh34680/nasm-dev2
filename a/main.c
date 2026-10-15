#include <stdio.h>
#include <stdlib.h>

static void test_asm();

int main(void)
{
    test_asm();

    return EXIT_SUCCESS;
}

static void test_asm()
{
    int i;

    __asm__ volatile("mov %%ebx, %0\n"
        : "=r"(i)
        :
        :
    );

    __asm__ volatile("" : : "r"(i));

    printf("%d\n", i);
}
