class SIZE {
    cx : i32
    cy : i32

    __New(cx := 0, cy := 0) {
        this.cx := cx
        this.cy := cy
    }
}

; TODO
class ImageList {
    __New(Args*) {
        Ptr := IL_Create(Args*)
        this.DefineProp("Ptr", { Get: (Instance) => Ptr })
    }

    Add(Args*) {
        IL_Add(this.Ptr, Args*)
        return this
    }

    __Item[Index] {
        get {
            if (!IsInteger(Index)) {
                throw TypeError("Expected an Integer",, Type(Index))
            }
            return DllCall("ImageList_GetIcon",
                           "Ptr", this,
                           "Int", Index - 1,
                           "UInt", 0)
        }
        set {

        }
    }

    __Enum(ArgSize) {

    }
}

class NMBCDROPDOWN {
    hdr      : NMHDR
    rcButton : RECT
}

class NMBCHOTITEM {
    hdr     : NMHDR
    dwFlags : HotItemChange
}

class HotItemChange {
    Value : u32
    __New(Value) {
        this.Value := Value
    }

    Mouse          => !!(this.Value  & HotItemChange.Mouse)
    ArrowKeys      => !!(this.Value  & HotItemChange.ArrowKeys)
    Accelerator    => !!(this.Value  & HotItemChange.Accelerator)
    DupAccelerator => !!(this.Value  & HotItemChange.DupAccelerator)
    Entering       => !!(this.Value  & HotItemChange.Entering)
    Leaving        => !!(this.Value  & HotItemChange.Leaving)
    Reselect       => !!(this.Value  & HotItemChange.Reselect)
    LMouse         => !!(this.Value  & HotItemChange.LMouse)
    ToggleDropDown => !!(this.Value  & HotItemChange.ToggleDropDown)

    static Other          => 0x0000
    static Mouse          => 0x0001
    static ArrowKeys      => 0x0002
    static Accelerator    => 0x0004
    static DupAccelerator => 0x0008
    static Entering       => 0x0010
    static Leaving        => 0x0020
    static Reselect       => 0x0040
    static LMouse         => 0x0080
    static ToggleDropDown => 0x0100
}

class HDITEM {
    mask       : u32
    cxy        : i32
    pszText    : uptr
    hbm        : uptr
    cchTextMax : i32
    fmt        : i32
    lParam     : uPtr
    iImage     : i32
    iOrder     : i32
    type       : u32
    pvFilter   : uPtr
}

class NMHDR {
    hwndFrom : uptr
    idFrom   : uptr
    code     : i32
}

class NMCUSTOMDRAW {
    hdr         : NMHDR
    dwDrawStage : u32
    hdc         : uptr
    rc          : RECT
    dwItemSpec  : uptr
    uItemState  : u32
    lItemlParam : iptr
}

class NMSEARCHWEB {
    hdr             : NMHDR
    entrypoint      : i32
    hasQueryText    : i32
    invokeSucceeded : i32
}

class POINTL {
    x : i32
    y : i32

    __New(x := 0, y := 0) {
        this.x := x
        this.y := y
    }
}

class PAINTSTRUCT {
    hdc         : uPtr
    fErase      : i32
    rcPaint     : RECT
    fRestore    : i32
    fIncUpdate  : i32
    rgbReserved : 32
}

class BUTTON_IMAGELIST {
    himl   : uPtr
    margin : RECT
    uAlign : u32

    ImageList(IList) {
        if (IsObject(IList)) {
            IList := IList.Ptr
        }
        this.himl := IList
        return this
    }

    AlignLeft() {
        this.uAlign := BUTTON_IMAGELIST.Alignment.Left
        return this
    }

    AlignRight() {
        this.uAlign := BUTTON_IMAGELIST.Alignment.Right
        return this
    }

    AlignTop() {
        this.uAlign := BUTTON_IMAGELIST.Alignment.Top
        return this
    }

    AlignBottom() {
        this.uAlign := BUTTON_IMAGELIST.Alignment.Bottom
        return this
    }

    AlignCenter() {
        this.uAlign := BUTTON_IMAGELIST.Alignment.Center
        return this
    }

    class Alignment {
        static Left   => 0x0000
        static Right  => 0x0001
        static Top    => 0x0002
        static Bottom => 0x0003
        static Center => 0x0004
    }
}

class BUTTON_SPLITINFO {
    mask        : u32
    himlGlyph   : uPtr
    uSplitStyle : u32
    size        : SIZE

    ImageList(IList) {
        this.mask        &= ~this.Flags.Glyph
        this.mask        |=  this.Flags.Image
        this.uSplitStyle |= this.Style.Image
        if (IsObject(IList)) {
            IList := IList.Ptr
        }
        this.himlGlyph := IList
        return this
    }

    ; TODO do I need this?
    Glyph(Gph) {
        this.mask        &= ~this.Flags.Image
        this.mask        |=  this.Flags.Glyph
        this.uSplitStyle |= this.Style.Image
        if (IsObject(Gph)) {
            Gph := Gph.Ptr
        }
        this.himlGlyph := Gph
        return this
    }

    NoSplit() {
        this.mask        |= this.Flags.Style
        this.uSplitStyle |= this.Style.NoSplit
        return this
    }

    Stretch() {
        this.mask        |= this.Flags.Style
        this.uSplitStyle |= this.Style.Stretch
        return this
    }

    AlignLeft() {
        this.mask        |= this.Flags.Style
        this.uSplitStyle |= this.Style.AlignLeft
        return this
    }

    ImageSize(Sz_or_cx, cy?) {
        this.mask |= this.Flags.Size
        if (!IsSet(cy)) {
            if (!(Sz_or_cx is SIZE)) {
                throw TypeError("Expected a SIZE",, Type(Sz_or_cx))
            }
            Sz := Sz_or_cx
        } else {
            Sz := SIZE(Sz_or_cx, cy)
        }
        this.size.cx := Sz.cx
        this.size.cy := Sz.cy
        return this
    }

    Flags => BUTTON_SPLITINFO.Flags

    class Flags {
        static Glyph => 0x0001
        static Image => 0x0002
        static Style => 0x0004
        static Size  => 0x0008
    }

    Style => BUTTON_SPLITINFO.Style

    class Style {
        static NoSplit   => 0x0001
        static Stretch   => 0x0002
        static AlignLeft => 0x0004
        static Image     => 0x0008
    }
}

class DRAGLISTINFO {
    uNotification : i32
    hWnd          : uPtr
    ptCursor      : POINT
}

class POINT {
    x : i32
    y : i32

    ToString() => "Point { x = " . this.x . "; y = " .  this.y . "}"
}