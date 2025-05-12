
class WindowsHook {
    class Injector extends DLL {
        static FilePath => A_LineFile . "/../injector2.dll"

        static TypeSignatures => {
            Inject: "Ptr, Ptr, Str"
        }
    }

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
        Result := WindowsHook.Injector.Inject(
                TargetHwnd, A_ScriptHwnd, WindowsHook.DllPath)

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

        OnMessage(WindowsHook.MsgNumber, Callback)

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

        Callback := this.Messages[TanukiMsg.Msg]
        if (!Callback) {
            return
        }

        Result := Callback(this, TanukiMsg.wParam, TanukiMsg.lParam)
        if (Result == "" || Result == WindowsHook.DoDefault) {
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
}

class TanukiMessage {
    msg     : u32
    wParam  : uPtr
    lParam  : uPtr
    result  : uPtr
    handled : i32
}

class GuiHook extends WindowsHook {
    OnSize(Callback) {
        return this.OnMessage(WM_SIZING := 0x0214, Size)

        Size(GuiObj, wParam, lParam) {
            return Callback(GuiObj, wParam, StructFromPtr(RECT, lParam))
        }
    }
}