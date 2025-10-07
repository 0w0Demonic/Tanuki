#Requires AutoHotkey v2.0

#Include <AhkWin32Projection\Windows\Win32\UI\Controls\PROPSHEETPAGEW>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>

Page := PROPSHEETPAGEW.FromObject({
    dwSize: PROPSHEETPAGEW.sizeof,
    dwFlags: Controls.PSP_USETITLE | Controls.PSP_HASHELP,
    hInstance: A_ScriptHwnd,
    pfnDlgProc: CallbackCreate(Callback),
    pszTitle: "Example Page",
    lParam: 0
})

Callback() {

}