// https://www.github.com/0w0Demonic/Tanuki
// - injector.c
#include <windows.h>
#include <stdio.h>

#define INJECT_SUCCESS           0
#define INJECT_ERR_OPENPROCESS   1
#define INJECT_ERR_ALLOC         2
#define INJECT_ERR_WRITE         3
#define INJECT_ERR_THREAD        4
#define INJECT_ERR_DLL_NOT_FOUND 5
#define INJECT_ERR_GETPROC       6

BOOL callRemote(HANDLE hProcess, FARPROC fn, void* hData, size_t reqSize);

typedef struct {
    HWND ahkScript;
    DWORD threadId;
} InitProcData;

/* Injects a window procedure into an external application, forwarding
   all of its messages to the given AutoHotkey script (known by Hwnd). */
__declspec(dllexport)
int inject(HWND   targetHwnd,
           HWND   ahkScriptHwnd,
           LPWSTR dllPath)
{
    // find process ID of the targeted HWND and try to open it.
    DWORD targetPID;
    DWORD threadId = GetWindowThreadProcessId(targetHwnd, &targetPID);
    HANDLE hProcess = OpenProcess(PROCESS_ALL_ACCESS, FALSE, targetPID);
    if (!hProcess) {
        return INJECT_ERR_OPENPROCESS;
    }

    size_t dllSize = (wcslen(dllPath) + 1) * sizeof(WCHAR);
    if (!callRemote(hProcess, (FARPROC)LoadLibraryW, dllPath, dllSize)) {
        CloseHandle(hProcess);
        return INJECT_ERR_THREAD;
    }

    HMODULE hLocalDll = LoadLibraryW(dllPath);
    if (!hLocalDll) {
        CloseHandle(hProcess);
        return INJECT_ERR_DLL_NOT_FOUND;
    }

    FARPROC SetAhkCallback = GetProcAddress(hLocalDll, "InitProc");
    if (!SetAhkCallback) {
        FreeLibrary(hLocalDll);
        CloseHandle(hProcess);
        return INJECT_ERR_GETPROC;
    }

    InitProcData data = { ahkScriptHwnd, threadId };
    BOOL ok = callRemote(hProcess, SetAhkCallback, &data, sizeof(InitProcData));
    FreeLibrary(hLocalDll);
    CloseHandle(hProcess);
    return (ok) ? INJECT_SUCCESS : INJECT_ERR_THREAD;
}

/* calls a function from a remote thread owned by a given process,
   with one available parameter. */
BOOL callRemote(HANDLE hProcess, FARPROC fn, void* hData, size_t reqSize)
{
    BOOL success = FALSE;
    void* pRemote = VirtualAllocEx(hProcess, NULL, reqSize, MEM_COMMIT, PAGE_READWRITE);
    if (!pRemote) {
        return FALSE;
    }

    if (WriteProcessMemory(hProcess, pRemote, hData, reqSize, NULL)) {
        HANDLE hThread = CreateRemoteThread(hProcess, NULL, 0,
                (LPTHREAD_START_ROUTINE)fn, pRemote, 0, NULL);
        if (hThread) {
            WaitForSingleObject(hThread, INFINITE);
            CloseHandle(hThread);
            success = TRUE;
        }
    }

    VirtualFreeEx(hProcess, pRemote, 0, MEM_RELEASE);
    return success;
}