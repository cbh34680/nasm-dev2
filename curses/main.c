#include <ncurses.h>
#include <locale.h>
#include <stdlib.h>
#include <string.h>

#include <termios.h>
#include <unistd.h>

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

static int f0001_box()
{
	/* start Ncurses */
	initscr();

	box(stdscr,'*','*');
	refresh();
	getch();

	/* clean-up */
	endwin();

    printf("Ncurses version %d.%d.%d\n",
			NCURSES_VERSION_MAJOR,
			NCURSES_VERSION_MINOR,
			NCURSES_VERSION_PATCH
		  );

	return 0;
}

static int f0101_goodbye()
{
    initscr();
    addstr("Goodbye, cruel world!");
    refresh();
    getch();

    endwin();
    return 0;
}

static int f0202_add1()
{
    char text[] = "Greetings from Ncurses!";
    char *t;

    initscr();          /* initialize NCurses */
    t = text;           /* initialize the pointer */

    while(*t)           /* loop through the string */
    {
        addch(*t);      /* one char to output */
        t++;            /* increment the pointer */
        refresh();      /* update the screen */
        napms(100);     /* delay .1 sec */
    }
    getch();            /* wait here */

    endwin();           /* clean up NCurses */
    return(0);
}

static int f0203_add2()
{
    char t1[] = "Shall I compare thee";
    char t2[] = " to a summer's day?";

    initscr();
    addstr(t1);     /* add the first string */
    addstr(t2);     /* add the second string */
    refresh();      /* display the result */
    getch();        /* wait */

    endwin();
    return(0);
}

static int f0204_add3()
{
    char t1[] = "Shall I compare thee";
    char t2[] = " to a summer's day?";

    initscr();
    addstr(t1);     /* add the first string */
    addstr(t2);     /* add the second string */
    move(2,0);      /* row 3, column 1 */
    addstr("Though art more lovely...");
    refresh();      /* display the result */
    getch();        /* wait */

    endwin();
    return(0);
}

static int f0205_yoda()
{
    int yoda = 874;
    int ss = 65;

    initscr();
    printw("Yoda is %d years old\n",yoda);
    printw("He has collected %d years",yoda-ss);
    printw(" of Social Security.");
    refresh();
    getch();

    endwin();
    return 0;
}

static int f0206_typewriter()
{
    int ch;

    initscr();
    addstr("Type a few lines of text\n");
    addstr("Press ~ to quit\n");
    refresh();

    while( (ch = getch()) != '~')
        ;

    endwin();
    return 0;
}

static int f0207_yourname()
{
    char first[16];
    char last[16];

    initscr();
    addstr("What is your first name? ");
    refresh();
    getnstr(first,15);

    addstr("What is your last name? ");
    refresh();
    getnstr(last,15);

    printw("Pleased to meet you, %s %s!",first,last);
    refresh();
    getch();

    endwin();
    return 0;
}

static int f0208_sushi()
{
    int pieces;
    const float uni = 4.5;

    initscr();

    addstr("SUSHI BAR");
    move(2,0);
    printw("We have Uni today for $%.2f.\n",uni);
    addstr("How many pieces would you like? ");
    refresh();

    scanw("%d",&pieces);
    printw("You want %d pieces?\n",pieces);
    printw("That will be $%.2f!",uni*(float)pieces);
    refresh();
    getch();

    endwin();
    return 0;
}

static int f0301_twinkle()
{
    initscr();

    attron(A_BOLD);
    addstr("Twinkle, twinkle little star\n");
    attron(A_BLINK);
    addstr("How I wonder what you are.\n");
    attroff(A_BOLD);
    addstr("Up above the world so high,\n");
    addstr("Like a diamond in the sky.\n");
    attrset(A_NORMAL);
    addstr("Twinkle, twinkle little star\n");
    addstr("How I wonder what you are.\n");
    refresh();
    getch();

    endwin();
    return 0;
}

#define COUNT 5

static int f0302_annoy()
{
    char text[COUNT][10] = {
        "Do", "you", "find", "this", "silly?"
    };
    int a,b;

    initscr();

    for(a=0;a<COUNT;a++)
    {
        for(b=0;b<COUNT;b++)
        {
            if(b==a) attrset(A_BOLD | A_UNDERLINE);
            printw("%s",text[b]);
            if(b==a) attroff(A_BOLD | A_UNDERLINE);
            addch(' ');
        }
        addstr("\b\n");
    }
    refresh();
    getch();

    endwin();
    return 0;
}

#undef COUNT

static int f0303_fcolortest()
{
    initscr();

/* test for color ability of the terminal */
    if(!has_colors())
    {
        endwin();   /* exit Ncurses */
        puts("Terminal cannot do colors");
        return 1;
    }

/* initialize Ncurses colors */
    if(start_color() != OK)
    {
        endwin();
        puts("Unable to start colors.");
        return 1;
    }

/* colors are okay; continue */
    printw("Colors initialized.\n");
    printw("%d colors available.\n",COLORS);
    printw("%d color pairs.",COLOR_PAIRS);
    refresh();
    getch();

    endwin();
    return 0;
}

int f0304_yellowred()
{
    initscr();
    start_color();
    init_pair(1,COLOR_YELLOW,COLOR_RED);
    addstr("Normal text\n");
    attrset(COLOR_PAIR(1) | A_BOLD);
    addstr("Colored text. Wee!\n");
    attrset(A_NORMAL);
    addstr("Back to normal.");
    refresh();
    getch();

    endwin();
    return 0;
}

int f0305_colorful()
{
    initscr();
    start_color();
    init_pair(1,COLOR_BLACK,COLOR_RED);
    init_pair(2,COLOR_YELLOW,COLOR_BLACK);
    attrset(COLOR_PAIR(1));     /* black on red */
    addstr("I am Mr. Black!\n");
    attrset(COLOR_PAIR(2));     /* yellow on black */
    addstr("I am Mr. Yellow!\n");
    attrset(COLOR_PAIR(1) | A_BOLD);    /* +bold */
    addstr("I'm feeling bold!\n");
    attrset(COLOR_PAIR(2) | A_BOLD);;   /* +bold */
    addstr("Me too!");
    refresh();
    getch();

    endwin();
    return 0;
}

int f0306_bgcolor1()
{
    initscr();

    start_color();
    init_pair(1,COLOR_WHITE,COLOR_BLUE);
    //bkgd(COLOR_PAIR(1));
    bkgd(COLOR_PAIR(1) | '.');
    addstr("So this is what a color screen looks like?\n");
    refresh();
    getch();

    endwin();
    return 0;
}

int f0307_bgcolor2()
{
    initscr();

    start_color();
    init_pair(1,COLOR_WHITE,COLOR_BLUE);
    init_pair(2,COLOR_GREEN,COLOR_WHITE);
    init_pair(3,COLOR_RED,COLOR_GREEN);
    bkgd(COLOR_PAIR(1));
    addstr("I think that I shall never see\n");
    addstr("a color screen as pretty as thee.\n");
    addstr("For seasons may change\n");
    addstr("and storms may thunder;\n");
    addstr("But color text shall always wonder.");
    refresh();
    getch();

    bkgd(COLOR_PAIR(2));
    refresh();
    getch();

    bkgd(COLOR_PAIR(3));
    refresh();
    getch();

    endwin();
    return 0;
}

int f0308_notice()
{
    initscr();

    addstr("Attention!\n");
    beep();
    refresh();
    getch();
    addstr("I said, ATTENTION!\n");
    flash();
    refresh();
    getch();
    endwin();
    return 0;
}

int f0401_screensize()
{
    int x,y;

    initscr();

    getmaxyx(stdscr,y,x);
    printw("Window size is %d rows, %d columns.\n",y,x);
    refresh();
    getch();

    endwin();
    return 0;
}

int f0402_stdscrsize()
{
    initscr();

    printw("Window size is %d rows, %d columns.\n",LINES,COLS);
    refresh();
    getch();

    endwin();
    return 0;
}

int f0403_corners1()
{
    int rows, cols;

    initscr();
    getmaxyx(stdscr, rows, cols);
    rows--;
    cols--;

    move(0,0);          /* 左上隅 */
    addch('*');
    refresh();
    napms(500);         /* 0.5秒間一時停止 */

    move(0,cols);       /* 右上隅 */
    addch('*');
    refresh();
    napms(500);

    move(rows,0);       /* 左下隅 */
    addch('*');
    refresh();
    napms(500);

    move(rows,cols);    /* 右下隅 */
    addch('*');
    refresh();
    getch();

    endwin();
    return 0;
}

int f0404_corners2()
{
    int rows, cols;

    initscr();
    getmaxyx(stdscr, rows, cols);
    rows--;
    cols--;
    mvaddch(0,0,'*');       /* 左上隅 */
    refresh();
    napms(500);             /* 0.5秒間一時停止 */

    mvaddch(0,cols,'*');    /* 右上隅 */
    refresh();
    napms(500);

    mvaddch(rows,0,'*');    /* 左下隅 */
    refresh();
    napms(500);

    mvaddch(rows,cols,'*'); /* 右下隅 */
    refresh();

    getch();

    endwin();
    return 0;
}

void center(int row, char *title)
{
    int len,indent,y,width;

    getmaxyx(stdscr,y,width);   /* 画面の幅を取得 */

    len = strlen(title);        /* タイトルの長さを取得 */
    indent = width - len;       /* それを画面の幅から引く */
    indent /= 2;                /* 結果を2つに割る */

    mvaddstr(row,indent,title);
    refresh();
}

int f0405_center()
{
    initscr();

    center(1, "Penguin Soccer Finals");
    center(5, "Cattle Dung Samples from Temecula");
    center(7, "Catatonic Theater");
    center(9, "Why Do Ions Hate Each Other?");
    getch();

    endwin();
    return 0;
}

#define COL1 5
#define COL2 38

int f0406_mydata()
{
    initscr();

    mvprintw(5,COL1,"%30s","Your name:");
    mvprintw(5,COL2,"%-30s","Art Grockmeister");

    mvprintw(7,COL1,"%30s","Your company:");
    mvprintw(7,COL2,"%-30s","Sterling/Worbletyme");

    mvprintw(9,COL1,"%30s","Position:");
    mvprintw(9,COL2, "%-30s", "Grand Duke of Finance");

    mvprintw(11,COL1, "%30s", "Date hired:");
    mvprintw(11,COL2, "%-30s", "October 19, 1993");
    refresh();
    getch();

    endwin();
    return 0;
}

#undef COL1
#undef COL2

int f0407_cursor()
{
    char ch='\0';   /* ch を NULL に初期化 */
    int row,col;

    initscr();

    addstr("Type some text; '~' to end:\n");
    refresh();

    while((ch=getch()) != '~')
        ;

    getyx(stdscr,row,col);
    printw("\n\nThe cursor was at row %d, column %d\n",row,col);
    printw("when you stopped typing.");
    refresh();
    getch();

    endwin();
    return 0;
}

int f0501_hamlet1()
{
    char Ham1[] = "To be, or not to be: that is the question:\n";
    char Ham2[] = "Whether 'tis nobler in the mind to suffer\n";
    char Ham3[] = "The slings and arrows of outrageous fortune,\n";
    char Ham4[] = "Or to take arms against a sea of troubles,\n";
    char Ham5[] = "And by opposing end them?\n";

    initscr();

    addstr(Ham1);
    addstr(Ham3);
    addstr(Ham5);
    refresh();
    getch();

    endwin();
    return 0;
}

int f0502_hamlet2()
{
    char Ham1[] = "To be, or not to be: that is the question:\n";
    char Ham2[] = "Whether 'tis nobler in the mind to suffer\n";
    char Ham3[] = "The slings and arrows of outrageous fortune,\n";
    char Ham4[] = "Or to take arms against a sea of troubles,\n";
    char Ham5[] = "And by opposing end them?\n";

    initscr();

    addstr(Ham1);
    addstr(Ham3);
    addstr(Ham5);
    refresh();
    getch();          /* キー押下を待つ */

    move(1,0);        /* カーソルを配置 */
    insertln();       /* 空白行を挿入し、テキストを下にスクロール */
    addstr(Ham2);     /* 挿入する行 */
    refresh();
    getch();          /* キー押下を待つ */

    endwin();
    return 0;
}

int f0503_hamlet3()
{
    char Ham1[] = "To be, or not to be: that is the question:\n";
    char Ham2[] = "Whether 'tis nobler in the mind to suffer\n";
    char Ham3[] = "The slings and arrows of outrageous fortune,\n";
    char Ham4[] = "Or to take arms against a sea of troubles,\n";
    char Ham5[] = "And by opposing end them?\n";

    initscr();

    addstr(Ham1);
    addstr(Ham3);
    addstr(Ham5);
    refresh();
    getch();

    move(1,0);        /* カーソルを配置 */
    insertln();       /* 空白行を挿入し、テキストを下にスクロール */
    addstr(Ham2);     /* 挿入する行 */
    refresh();
    getch();

    move(3,0);
    insertln();       /* 4行目に空白行を挿入 */
    addstr(Ham4);     /* 4行目を追加 */
    refresh();
    getch();

    endwin();
    return 0;
}

int f0504_marquee1()
{
    char text[] = "Stock Market Swells! DOW tops 15,000!";
    char *t;
    int len;

    initscr();

    len = strlen(text);
    t = text;      /* ポインタを初期化 */
    while(len)
    {
        move(5,5);              /* 常に同じ場所に挿入 */
        insch(*(t+len-1));      /* 文字列を逆から処理 */
        refresh();
        napms(100);             /* 0.1秒遅延 */
        len--;
    }
    getch();

    endwin();
    return 0;
}

void fill(void)
{
    int a,x,y;

    getmaxyx(stdscr,y,x);
    for(a=0;a<y;a++)
        addstr("A B C D E F G H I J K L M N O P Q R S T U V W X Y Z\n");
}

int f0505_marquee2()
{
    char text[] = "Stock Market Swells! DOW tops 15,000!";
    char *t;
    int len;

    initscr();
    fill();
    refresh();
    napms(1000);

    len = strlen(text);
    t = text;      /* ポインタを初期化 */
    while(len)
    {
        move(5,5);              /* 常に同じ場所に挿入 */
        insch(*(t+len-1));      /* 文字列を逆から処理 */
        refresh();
        napms(100);             /* 0.1秒遅延 */
        len--;
    }
    getch();
    endwin();
    return 0;
}

int f0506_hamlet4()
{
    char Ham1[] = "To be, or not to be: that is the question:\n";
    char Ham2[] = "Whether 'tis nobler in the mind to suffer\n";
    char Ham3[] = "The slings and arrows of outrageous fortune,\n";
    char Ham4[] = "Or to take arms against a sea of troubles,\n";
    char Ham5[] = "And by opposing end them?\n";

    initscr();

    addstr(Ham1);
    addstr(Ham2);
    addstr(Ham3);
    addstr(Ham4);
    addstr(Ham5);
    refresh();
    getch();          /* キー押下を待つ */

    move(1,0);        /* 削除する行に移動 */
    deleteln();       /* 削除して逆スクロール */
    refresh();
    getch();          /* キー押下を待つ */

    endwin();
    return 0;
}

int f0507_hamlet5()
{
    char Ham1[] = "To be, or not to be: that is the question:\n";
    char Ham2[] = "Whether 'tis nobler in the mind to suffer\n";
    char Ham3[] = "The slings and arrows of outrageous fortune,\n";
    char Ham4[] = "Or to take arms against a sea of troubles,\n";
    char Ham5[] = "And by opposing end them?\n";
    int c;

    initscr();

    addstr(Ham1);
    addstr(Ham2);
    addstr(Ham3);
    addstr(Ham4);
    addstr(Ham5);
    refresh();
    getch();          /* キー押下を待つ */

    move(2,25);       /* "outrageous" の先頭に移動 */
    for (c = 0;c< 11;c++)
        delch();      /* むしゃむしゃ！ */
    refresh();
    getch();          /* キー押下を待つ */

    endwin();
    return 0;
}

int f0508_hamlet6()
{
    char Ham1[] = "To be, or not to be: that is the question:\n";
    char Ham2[] = "Whether 'tis nobler in the mind to suffer\n";
    char Ham3[] = "The slings and arrows of outrageous fortune,\n";
    char Ham4[] = "Or to take arms against a sea of troubles,\n";
    char Ham5[] = "And by opposing end them?\n";
    char *ob = "obnoxious";
    int c;

    initscr();

    addstr(Ham1);
    addstr(Ham2);
    addstr(Ham3);
    addstr(Ham4);
    addstr(Ham5);
    refresh();
    getch();          /* キー押下を待つ */

    /* まず、"outrageous" を削除する */

    move(2,25);       /* "outrageous" の先頭に移動 */
    for (c = 0;c< 10;c++)   /* 10回だけループ */
    {
        delch();      /* むしゃむしゃ！ */
        refresh();    /* 画面を更新（カーソルは動かない） */
        napms(100);   /* 一時停止 */
    }

    /* 次に、"obnoxious" を挿入する */

    move(2,25);       /* カーソルをリセット */
    for (c = 0;c< 9;c++)
    {
        insch(*(ob+8-c));
        refresh();
        napms(100);
    }
    getch();
    endwin();
    return 0;
}

int f0601_blah1()
{
    int c,y,x,cmax;

    initscr();

    getmaxyx(stdscr,y,x);
    cmax = (x*y)/5;
    for (c = 0;c< cmax;c++) addstr("blah ");
    refresh();

    getch();

    endwin();
    return 0;
}

int f0602_blah2()
{
    int c,y,x,cmax;

    initscr();

    getmaxyx(stdscr,y,x);
    cmax = x*y/5;
    for (c = 0;c< cmax;c++) addstr("blah ");
    refresh();
    getch();

    //clear();        /* 画面をクリア */
    erase();
    refresh();      /* これを忘れないで！ */
    getch();

    endwin();
    return 0;
}

int f0603_blah4()
{
    int c,y,x,cmax;

    initscr();

    getmaxyx(stdscr,y,x);
    cmax = (x * y)/5;
    for (c = 0;c< cmax;c++) addstr("blah ");
    refresh();
    getch();

    move(5,20);     /* カーソルを設定 */
    clrtoeol();     /* 行末までクリア */
    refresh();
    getch();

    endwin();
    return 0;
}

int f0604_blah5()
{
    int c,y,x,cmax;

    initscr();

    getmaxyx(stdscr,y,x);
    cmax = (x * y)/5;
    for (c = 0;c< cmax;c++) addstr("blah ");
    refresh();
    getch();

    move(5,20);     /* カーソルを設定 */
    clrtobot();     /* 画面の最後までクリア */
    refresh();
    getch();

    endwin();
    return 0;
}

int f0701_keywait1()
{
    int value = 0;

    initscr();

    addstr("Press any key to begin:\n");
    refresh();
    getch();

    nodelay(stdscr,TRUE);   /* getch() の待機をオフにする */
    addstr("Press any key to stop the insane loop!\n");
    while(getch() == ERR)
    {
        printw("%d\r",value++);
        refresh();
    }

    endwin();
    return 0;
}

static int my_test();
int main(int argc, char** argv, char** envp)
{
    f0701_keywait1();

    //my_test();

    // https://c-for-dummies.com/ncurses/source_code/index.php

    //my_getch();
    //f0001_box();
    //f0101_goodbye();
    //f0202_add1();
    //f0203_add2();
    //f0204_add3();
    //f0205_yoda();
    //f0206_typewriter();
    //f0207_yourname();
    //f0208_sushi();
    //f0301_twinkle();
    //f0302_annoy();
    //f0303_fcolortest();
    //f0304_yellowred();
    //f0305_colorful();
    //f0306_bgcolor1();
    //f0307_bgcolor2();
    //f0308_notice();
    //f0401_screensize();
    //f0402_stdscrsize();
    //f0403_corners1();
    //f0404_corners2();
    //f0405_center();
    //f0406_mydata();
    //f0407_cursor();
    //f0501_hamlet1();
    //f0502_hamlet2();
    //f0503_hamlet3();
    //f0504_marquee1();
    //f0505_marquee2();
    //f0506_hamlet4();
    //f0507_hamlet5();
    //f0508_hamlet6();
    //f0601_blah1();
    //f0602_blah2();
    //f0603_blah4();
    //f0604_blah5();

    return EXIT_SUCCESS;
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
