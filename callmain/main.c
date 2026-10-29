
extern int c_print_str(const char*);

int main(int argc, char** argv, char** envp)
{
    char** pos = argv;

    while (*pos) {
        c_print_str(*pos);
        ++pos;
    }

    return 10;
}
