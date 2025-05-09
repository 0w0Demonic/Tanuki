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

class InjectorDLL extends DLL {
    static FilePath => A_LineFile . "/../injector2.dll"

    static TypeSignatures => {
        Inject: "Ptr, Ptr, Str"
    }
}

class Subclass {
    static DllPath   => A_LineFile . "/../windowProc2.dll"
    static MsgNumber => 0x3CCC

    static FromControl(Ctl, WTtl?, WTxt?, ETtl?, ETxt?) {
        Hwnd := ControlGetHwnd(Ctl, WTtl?, WTxt?, ETtl?, ETxt?)
        return this(Hwnd)
    }

    static FromWindow(WTtl?, WTxt?, ETtl?, ETxt?) {
        Hwnd := WinGetId(WTtl?, WTxt?, ETtl?, ETxt?)
        return this(Hwnd)
    }

    __New(TargetHwnd) {
        Result := InjectorDLL.Inject(TargetHwnd, A_ScriptHwnd, Subclass.DllPath)

        switch (Result) {
            case 1: M := "Unable to open process of AutoHotkey script."
            case 2: M := "Unable to allocate virtual memory."
            case 3: M := "Unable to write into process"
            case 4: M := "Unable to create remote thread"
            case 5: M := "Unable to load 'windowProc.dll'"
            case 6: M := "Unable to resolve 'windowProc/init'"
        }

        Callback := ObjBindMethod(this, "MsgHandler")

        this.Messages := CreateMap()
        this.Notifs   := CreateMap()
        this.Commands := CreateMap()

        OnMessage(Subclass.MsgNumber, Callback)

        static CreateMap() {
            M         := Map()
            M.Default := false
            return M
        }
    }

    OnMessage(MsgNumber, Callback) {
        if (!IsInteger(MsgNumber)) {
            throw TypeError("Expected an Integer",, Type(MsgNumber))
        }
        if (!HasMethod(Callback)) {
            throw TypeError("Expected a Function object", Type(Callback))
        }
        this.Messages[MsgNumber] := Callback
    }

    MsgHandler(wParam, lParam, Msg, Hwnd) {
        TanukiMsg := StructFromPtr(TanukiMessage, lParam)

        Callback := this.Messages[Msg]
        if (!Callback) {
            return
        }

        Result := Callback(this, TanukiMsg.wParam, TanukiMsg.lParam)
        if (Result == "" || Result == Subclass.DoDefault) {
            return
        }
        TanukiMsg.Result := Result
        TanukiMsg.Handled := true
    }

    static DoDefault {
        get {
            static _ := Object()
            return _
        }
    }

    __Delete() {
        
    }
}

Notepad := Subclass.FromWindow("ahk_exe notepad.exe")

Notepad.OnMessage(0x20, (EditControl, wParam, lParam) {
    
})


