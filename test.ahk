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
        Inject: "Ptr, Ptr, Str, Ptr"
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
        Buf := TanukiMessage()
        Ptr := ObjGetDataSize(Buf)

        this.DefineProp("Ptr", { Get: (Instance) => Ptr })
        this.DefineProp("Buf", { Get: (Instance) => Buf })

        Result := InjectorDLL.Inject(TargetHwnd, A_ScriptHwnd,
                        Subclass.DllPath, Ptr)

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
        this.DefineProp("__Delete", {
            Call: (Instance) => OnMessage(Subclass.MsgNumber, Callback, false)
        })

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
        this.Messages[MsgNumber, Callback]
    }

    MsgHandler(*) {
        MsgNumber := this.Buf.Msg
        Callback := this.RegisteredMessages[MsgNumber]
        if (!Callback) {
            return
        }

        Result := Callback(this.Buf.wParam, this.Buf.lParam)
        if (Result == "" || Result == Subclass.DoDefault) {
            return
        }

        this.Buf.Result  := Result
        this.Buf.Handled := true
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

