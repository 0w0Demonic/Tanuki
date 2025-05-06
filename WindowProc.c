// https://www.github.com/0w0Demonic/Tanuki
// - WindowProc.c
#include <windows.h>

HHOOK   globalHook = NULL; // the resulting hook procedure
HWND    ahkScript  = NULL; // handle of the AutoHotkey script
HMODULE g_hModule  = NULL; // hModule of this DLL

LRESULT CALLBACK WndProc(int nCode, WPARAM wParam, LPARAM lParam);

/* main entry point of the DLL file. */
BOOL APIENTRY DllMain(HMODULE hModule, DWORD reason, LPVOID lpReserved)
{
    if (reason == DLL_PROCESS_ATTACH) {
        DisableThreadLibraryCalls(hModule);
        g_hModule = hModule;
    }
    else if (reason == DLL_PROCESS_DETACH) {
        if (globalHook) {
            UnhookWindowsHookEx(globalHook);
        }
    }
    return TRUE;
}

typedef struct {
    HWND ahkScript;
    DWORD threadId;
} InitProcData;


LRESULT CALLBACK WindowProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam);

/* Sets the hwnd of the AutoHotkey script to call. */
__declspec(dllexport)
void InitProc(InitProcData* data)
{
    ahkScript = data->ahkScript;
    SetWindowLongPtr(ahkScript, GWLP_WNDPROC, WindowProc);
    //globalHook = SetWindowsHookEx(WH_CALLWNDPROC, WndProc, g_hModule, data->threadId);
}

/* structure which is sent as lParam to the AHK script. */
typedef struct {
    UINT    msg;     // message number
    WPARAM  wParam;  // wParam
    LPARAM  lParam;  // lParam
    LRESULT result;  // result
    BOOL    handled; // TRUE --> DefWindowProc(...)
} TanukiMessage, *lpTanukiMessage;

#define WM_TANUKIMESSAGE 0x3CCC
// TODO use RegisterWindowMessage() instead

LRESULT CALLBACK WindowProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    TanukiMessage m = { msg, wParam, lParam, 0, FALSE };
    SendMessage(ahkScript, WM_TANUKIMESSAGE, 0, 0);
    if (m.handled) {
        return m.result;
    }
    return DefWindowProc(hwnd, msg, wParam, lParam);
}

/* the new window procedure given to the targeted process. */
LRESULT CALLBACK WndProc(int nCode, WPARAM wParam, LPARAM lParam)
{
    if (nCode < 0) {
        // message must be processed by next hook
        return CallNextHookEx(globalHook, nCode, wParam, lParam);
    }

    CWPSTRUCT* p = (CWPSTRUCT*)lParam;
    TanukiMessage m = { p->message, p->wParam, p->lParam, 0, FALSE };

    // wParam - hwnd of the calling window
    // lParam - TanukiMessage struct

    PostMessage(ahkScript, WM_TANUKIMESSAGE, 0, 0);
    // PostMessage(ahkScript, WM_TANUKIMESSAGE, (WPARAM)p->hwnd, (LPARAM)&m);

    if (m.handled) {
        return m.result;
    }

    // call default window procedure if `handled` flag set to `TRUE`
    return CallNextHookEx(globalHook, nCode, wParam, lParam);
}
