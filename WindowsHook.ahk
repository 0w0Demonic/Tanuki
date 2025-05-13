/**
 * 
 */
class WindowsHook {
    /** File path containing the new window subclass */
    static DllPath => A_LineFile . "/../windowProc2.dll"

    /** Message number used for callbacks to the AHK script */
    static MsgNumber => 0x3CCC

    /** Creates a new window hook from the given GUI control */
    static FromControl(Ctl, WTtl?, WTxt?, ETtl?, ETxt?) {
        Hwnd := ControlGetHwnd(Ctl, WTtl?, WTxt?, ETtl?, ETxt?)
        return this(Hwnd)
    }

    /** Creates a new window hook from the given application */
    static FromWindow(WTtl?, WTxt?, ETtl?, ETxt?) {
        Hwnd := WinGetId(WTtl?, WTxt?, ETtl?, ETxt?)
        return this(Hwnd)
    }

    /** Creates a new window hook from the given HWND */
    __New(TargetHwnd) {
        Hwnd := (IsObject(TargetHwnd)) ? TargetHwnd.Hwnd
                                       : TargetHwnd
        if (!IsInteger(Hwnd)) {
            throw TypeError("Expected an Object or Integer",, Type(Hwnd))
        }

        Result := DllCall(A_LineFile . "\..\injector2.dll\inject", "Ptr", Hwnd,
            "Ptr", A_ScriptHwnd, "Str", WindowsHook.DllPath)

        switch (Result) {
            case 1: Msg := "Unable to open process of AutoHotkey script."
            case 2: Msg := "Unable to allocate virtual memory."
            case 3: Msg := "Unable to write into process"
            case 4: Msg := "Unable to create remote thread"
            case 5: Msg := "Unable to load 'windowProc.dll'"
            case 6: Msg := "Unable to resolve 'windowProc/init'"
        }
        if (Result) {
            throw OSError(Msg)
        }

        Callback := ObjBindMethod(this, "MsgHandler")

        PID := 0
        DllCall("GetWindowThreadProcessId", "Ptr", Hwnd, "UInt*", &PID)
        hProcess := DllCall("OpenProcess", "UInt", 0x10, "Int", false,
                "UInt", PID)
        
        Define("Process", hProcess)
        Define("Messages", CreateMap())
        Define("Commands", CreateMap())
        Define("Notifs", CreateMap())

        OnMessage(WindowsHook.MsgNumber, Callback)

        static CreateMap() {
            M := Map()
            M.Default := false
            return M
        }

        Define(PropName, Value) {
            this.DefineProp(PropName, { Get: (Instance) => Value })
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

    OnNotify(NotifyCode, Callback) {
        if (!IsInteger(NotifyCode)) {
            throw TypeError("Expected an Integer",, Type(NotifyCode))
        }
        if (!HasMethod(Callback)) {
            throw TypeError("Expected a Function object", Type(Callback))
        }
        this.Notifs[NotifyCode] := Callback
    }

    OnCommand(NotifyCode, Callback) {
        if (!IsInteger(NotifyCode)) {
            throw TypeError("Expected an Integer",, Type(NotifyCode))
        }
        if (!HasMethod(Callback)) {
            throw TypeError("Expected a Function object", Type(Callback))
        }
        this.Commands[NotifyCode] := Callback
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

    DoDefault => WindowsHook.DoDefault

    static DoDefault {
        get {
            static _ := Object()
            return _
        }
    }

    __Delete() {
        DllCall("CloseHandle", "Ptr", this.Process)
    }

    ReadObject(StructClass, Ptr) {
        Output := StructClass()
        OutSize := ObjGetDataSize(Output)
        OutPtr := ObjGetDataPtr(Output)
        DllCall("ReadProcessMemory", "Ptr", this.Process, "Ptr", Ptr,
                "Ptr", OutPtr, "UPtr", OutSize, "Ptr", 0)
        return Output
    }
}

class GuiHook extends WindowsHook {
    OnSize(Callback) {
        return this.OnMessage(WM_SIZING := 0x0214, (GuiObj, wParam, lParam) {
            return Callback(GuiObj, wParam, this.ReadObject(RECT, lParam))
        })
    }
}

class TanukiMessage {
    Msg     : u32
    wParam  : uPtr
    lParam  : uPtr
    result  : uPtr
    handled : i32
}