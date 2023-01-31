#define WINVER 0x501
#define _WIN32_WINNT 0x501

#include <windows.h>

int main(int argc, char **argv) {
    FLASHWINFO info = { sizeof(info), GetConsoleWindow(), FLASHW_TIMERNOFG | FLASHW_TRAY, 3, 0 };

    FlashWindowEx(&info);
}
