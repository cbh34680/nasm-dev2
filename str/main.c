#include <stdio.h>
#include <stdlib.h>

static void test_asm();
extern void mset1();
extern void mset5();
extern void mset2();
extern void mset3(char*, size_t);
extern void mset4(int*, size_t);

extern void scan1();

int main(void)
{
    //mset1();
    //mset5();
    //mset2();

    char buf[16] = { 0 };
    //mset3(buf, sizeof buf);

    int ibuf[16] = { 0 };
    //mset4(ibuf, sizeof ibuf / sizeof ibuf[0]);

    scan1();

    //test_asm();

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
