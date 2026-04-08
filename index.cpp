#include <windows.h>

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    // TEXT() ensures strings are compatible with both Unicode and ANSI builds
    MessageBox(NULL, TEXT("GUI made with me"), TEXT("Banana App"), MB_OK | MB_ICONINFORMATION);
    return 0;
}
