// https://www.github.com/0w0Demonic/Tanuki
// - windowProc2.c
#include <windows.h>

#define WM_TANUKIMESSAGE 0x3CCC

HWND hAhkScript = NULL;

typedef struct {
    HWND hTarget;
    HWND hAhkScript;
} InitData;

typedef struct {
    UINT msg;
    WPARAM wParam;
    LPARAM lParam;
    LRESULT lResult;
    BOOL handled;
} TanukiMessage, *lpTanukiMessage;

BOOL APIENTRY DllMain(HMODULE hModule, DWORD reason, WPARAM wParam, LPARAM lParam)
{
    if (reason == DLL_PROCESS_ATTACH) {
        DisableThreadLibraryCalls(hModule);
    }
    return TRUE;
}

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    HGLOBAL hGlobal = GlobalAlloc(GHND, sizeof(TanukiMessage));
    TanukiMessage* pMsg = (TanukiMessage*)GlobalLock(hGlobal);

    TanukiMessage m = { msg, wParam, lParam, 0, FALSE };

    GlobalUnlock(hGlobal);
    SendMessage(hAhkScript, WM_TANUKIMESSAGE, (WPARAM)hwnd, (LPARAM)hGlobal);
    GlobalFree(hGlobal);

    if (m.handled) {
        return m.lResult;
    }

    return DefWindowProc(hwnd, msg, wParam, lParam);
}

__declspec(dllexport)
LONG_PTR init(InitData *data) {
    hAhkScript = data->hAhkScript;
    return SetWindowLongPtr(data->hTarget, GWLP_WNDPROC, (LONG_PTR)WndProc);
}