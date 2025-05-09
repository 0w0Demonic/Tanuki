// https://www.github.com/0w0Demonic/Tanuki
// - windowProc2.c
#include <windows.h>

#define WM_TANUKIMESSAGE 0x3CCC

HWND hAhkScript = NULL;
LONG_PTR prevWndProc = (LONG_PTR)NULL;
HWND g_hTarget = NULL;

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
    // TODO
    if (reason == DLL_PROCESS_DETACH) {
        if (g_hTarget) {
            SetWindowLongPtr(g_hTarget, GWLP_WNDPROC, prevWndProc);
        }
    }
    return TRUE;
}

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    // TODO handle WM_DESTROY and WM_NCDESTROY?

    HGLOBAL hGlobal = GlobalAlloc(GMEM_MOVEABLE | GMEM_SHARE,
                                  sizeof(TanukiMessage));

    TanukiMessage* pMsg = (TanukiMessage*)GlobalLock(hGlobal);
    pMsg->msg     = msg;
    pMsg->wParam  = wParam;
    pMsg->lParam  = lParam;
    pMsg->lResult = 0;
    pMsg->handled = FALSE;
    GlobalUnlock(hGlobal);

    SendMessage(hAhkScript, WM_TANUKIMESSAGE, (WPARAM)hwnd, (LPARAM)hGlobal);
    if (pMsg->handled) {
        return pMsg->lResult;
    }
    GlobalFree(hGlobal);

    return DefWindowProc(hwnd, msg, wParam, lParam);
}

__declspec(dllexport)
void init(InitData *data) {
    hAhkScript = data->hAhkScript;
    g_hTarget = data->hTarget;
    prevWndProc = SetWindowLongPtr(g_hTarget, GWLP_WNDPROC, (LONG_PTR)WndProc);
}