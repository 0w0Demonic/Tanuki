/**
 * 
 */
class RECT {
    Left   : i32
    Top    : i32
    Right  : i32
    Bottom : i32

    __New(Left := 0, Top := 0, Right := 0, Bottom := 0) {
        this.Left   := Left
        this.Top    := Top
        this.Right  := Right
        this.Bottom := Bottom
    }

    Copy() {
        Rc := RECT()
        if (!DllCall("CopyRect", RECT, Rc, RECT, this)) {
            throw Error("Unable to copy RECT")
        }
        return Rc
    }

    static CopyFrom(Rc) {
        if (IsInteger(Rc)) {
            Rc := StructFromPtr(RECT, Rc)
        }
        if (!(Rc is RECT)) {
            throw TypeError("Expected a RECT",, Type(Rc))
        }
        ; TODO
    }

    TrimSystemBorder() {
        static cx := SysGet(5)
        static cy := SysGet(6)

        this.Left   += cx
        this.Right  -= cx
        this.Top    += cy
        this.Bottom -= cy
        return this
    }

    static OfClient(Control) {
        if (IsObject(Control)) {
            Control := Control.Hwnd
        }
        if (!IsInteger(Control)) {
            throw TypeError("Expected an Integer",, Type(Control))
        }
        Rc := RECT()
        if (!DllCall("GetClientRect", "Ptr", Control, RECT, Rc)) {
            throw OSError("Unable to retrieve client RECT")
        }
        return Rc
    }

    static OfWindow(Window) {
        if (IsObject(Window)) {
            Window := Window.Hwnd
        }
        if (!IsInteger(Window)) {
            throw TypeError("Expected an Integer",, Type(Window))
        }
        Rc := RECT()
        if (!DllCall("GetWindowRect", "Ptr", Window, RECT, Rc)) {
            throw OSError("Unable to retrieve window RECT")
        }
        return Rc
    }

}