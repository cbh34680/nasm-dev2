#include <ncurses.h>
#include <locale.h>
#include <stdlib.h>
#include <string.h>

#include <termios.h>
#include <unistd.h>



extern int part1to7();
static int my_getch();
static int my_test();

int main(int argc, char** argv, char** envp)
{


    // https://c-for-dummies.com/ncurses/source_code/

    //my_getch();
    //my_test();

    return EXIT_SUCCESS;
}

static int my_getch()
{
    printf("put any key>");

    struct termios old, new;
    tcgetattr(STDIN_FILENO, &old);

    new = old;
    new.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &new);

    char c;
    read(STDIN_FILENO, &c, sizeof(c));

    tcsetattr(STDIN_FILENO, TCSANOW, &old);
}

static int my_test()
{
    initscr();

    printw("LINES=%d, COLS=%d\n", LINES, COLS);

    if (!has_colors()) {
        endwin();
        puts("!has_colors");
        return 1;
    }

    start_color();
    use_default_colors();
    init_pair(1, COLOR_RED, -1);        // 背景色(-1) を使うには use_default_colors() の呼び出しが必要

    attron(COLOR_PAIR(1));
    addstr("RED");
    refresh();
    getch();

    move(1, 0);
    delch();
    refresh();
    getch();

    attroff(COLOR_PAIR(1));

    endwin();
    return 0;
}
