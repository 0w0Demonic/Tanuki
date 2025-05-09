#Requires AutoHotkey v2
#Include "%A_LineFile%/../tanuki.ahk"
#Include <AquaHotkeyX>

g := Gui()

Pb := g.AddCommandLink(, "Download free RAM",
            "We speeding up your PC with this one 🔥")

LB := g.AddListBox("r4")

LB.IsDragList := true
LB.OnDragBegin((LbControl, Point) {
    ToolTip(String(Point))
    return true
})

LB.Add(Array(
    "Hello, world?",
    "Light's are on",
    "But no one's home",
    "Enough's enough",
    "Find your pearl",
    "And fall in love",
    "With a girl <3"))

Rad := g.AddRadio(unset, "Click me?")

g.Show()

esc:: {
    ExitApp()
}


class GuiProxy {

}

class TanukiMessage {
    msg     : u32
    wParam  : uPtr
    lParam  : uPtr
    result  : uPtr
    handled : i32
}

class Injector extends DLL {
    static FilePath => A_LineFile "/../injector2.dll"

    static TypeSignatures => {
        Inject: "Ptr, Ptr, Str"
    }
}

WM_TANUKIMESSAGE := 0x3CCC
EditControl := WinGetID("ahk_exe notepad.exe")

OnMessage(WM_TANUKIMESSAGE, (wParam, lParam, Msg, Hwnd) {
    p := DllCall("GlobalLock", "Ptr", lParam)
    Info := StructFromPtr(TanukiMessage, p)
    ToolTip(Info.wParam)
    DllCall("GlobalUnlock", "Ptr", lParam)
})

WindowProcDll := A_LineFile . "/../windowProc2.dll"
Injector.Inject(EditControl, A_ScriptHwnd, WindowProcDll)