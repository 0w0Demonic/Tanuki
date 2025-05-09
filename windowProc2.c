// https://www.github.com/0w0Demonic/Tanuki
// - windowProc2.c
#include <windows.h>
#include <stdio.h>

#define WM_TANUKIMESSAGE 0x3CCC

HWND hAhkScript      = NULL;
void* pAhkBuffer     = NULL;

LONG_PTR prevWndProc = (LONG_PTR)NULL;
HWND g_hTarget       = NULL;

typedef struct {
    HWND hTarget;
    HWND hAhkScript;
    void* pBuffer;
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
    if (reason == DLL_PROCESS_DETACH) {
        if (g_hTarget) {
            SetWindowLongPtr(g_hTarget, GWLP_WNDPROC, prevWndProc);
        }
    }
    return TRUE;
}

LRESULT CALLBACK WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    HGLOBAL hGlobal = GlobalAlloc(GMEM_MOVEABLE, sizeof(TanukiMessage));

    TanukiMessage* pMsg = (TanukiMessage*)pAhkBuffer;
    pMsg->msg     = msg;
    pMsg->wParam  = wParam;
    pMsg->lParam  = lParam;
    pMsg->lResult = 0;
    pMsg->handled = FALSE;
    
    SendMessage(hAhkScript, WM_TANUKIMESSAGE, (WPARAM)hwnd, 0);

    LRESULT result = pMsg->lResult;
    BOOL handled = pMsg->handled;

    if (pMsg->handled) {
        return pMsg->lResult;
    }
    return DefWindowProc(hwnd, msg, wParam, lParam);
}

__declspec(dllexport)
void init(InitData *data) {
    hAhkScript = data->hAhkScript;
    g_hTarget = data->hTarget;
    pAhkBuffer = data->pBuffer;
    prevWndProc = SetWindowLongPtr(g_hTarget, GWLP_WNDPROC, (LONG_PTR)WndProc);
}