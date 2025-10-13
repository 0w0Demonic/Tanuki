#Requires AutoHotkey v2.0

#Include <Alchemy\MapChain>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\NMHDR>

class WindowProcedure {
    static __New() {
        static CreateGetter(Value) => { Get: (_) => Value }

        static Properties := Array("Messages", "Notifications", "Commands")
        static Define := {}.DefineProp

        if (this == WindowProcedure) {
            for Property in Properties {
                Define(this.Prototype, Property, CreateGetter(MapChain.Base()))
            }
        } else {
            for Property in Properties {
                Value := MapChain.Extend(ObjGetBase(this).%Property%)
                Define(this.Prototype, Property, CreateGetter(Value))
            }
        }
    }

    Call(Hwnd, Msg, wParam, lParam) {
        switch (Msg) {
            case WindowsAndMessaging.WM_NOTIFY:
                Header := NMHDR(lParam)
                Index := Header.idFrom << 32 | Header.code
                return (this.Notifications)[Index](Hwnd, lParam)
            case WindowsAndMessaging.WM_COMMAND:
                return (this.Commands)[wParam](Hwnd)
            default:
                return (this.Messages)[Msg](wParam, lParam, Msg, Hwnd)
        }
    }

    OnMessage(Msg, Fn) {
        if (!IsInteger(Msg)) {
            throw TypeError("Expected an Integer",, Type(Msg))
        }
        GetMethod(Fn)
        (this.Messages).Set(Msg, Fn)
        return this
    }

    OnNotify(ControlId, Notif, Fn) {
        if (!IsInteger(Notif)) {
            throw TypeError("Expected an Integer",, Type(Notif))
        }
        GetMethod(Fn)
        (this.Notifications).Set((ControlId << 32) | (Notif & 0xFFFFFFFF), Fn)
        return this
    }

    OnCommand(ControlId, Cmd, Fn) {
        if (!IsInteger(ControlId)) {
            throw TypeError("Expected an Integer",, Type(ControlId))
        }
        if (!IsInteger(Cmd)) {
            throw TypeError("Expected an Integer",, Type(Cmd))
        }
        GetMethod(Fn)
        (this.Commands).Set((Cmd << 16) | (ControlId & 0xFFFF), Fn)
        return this
    }
}

