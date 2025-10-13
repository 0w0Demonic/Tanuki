#Requires AutoHotkey v2.0

#Include <AquaHotkey>
#Include <Tanuki\wip\AppendableBuffer>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\DLGITEMTEMPLATE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\WINDOW_STYLE>

class DialogItem extends AppendableBuffer
{
    static __New() => AquaHotkey.ApplyMixin(this, DLGITEMTEMPLATE)

    __New() {
        super.__New(DLGITEMTEMPLATE.sizeof, 0)
        this.Style := WINDOW_STYLE.WS_VISIBLE | WINDOW_STYLE.WS_CHILD
    }

    Style(Style, ExStyle := 0) {
        this.style := Style
        this.dwExtendedStyle := ExStyle
        return this
    }

    Position(x, y) {
        this.x := x
        this.y := y
        return this
    }

    Size(Width, Height) {
        this.cx := Width
        this.cy := Height
        return this
    }

    Id(Id) {
        this.id := Id
        return this
    }

    IsBuilt := false

    __Type {
        get {
            throw UnsetError("unset control type")
        }
    }

    Type(Type) {
        this.IsBuilt := false
        return this.DefineProp("__Type", { Value: Type })
    }

    __Text => ""

    Text(Text) {
        this.IsBuilt := false
        return this.DefineProp("__Text", { Value: Text })
    }

    __Data => Buffer(0, 0)

    Data(Mem, Size := Mem.Size) {
        this.IsBuilt := false
        return this.DefineProp("__Data", { Value: ClipboardAll(Mem, Size) })
    }

    Build() {
        if (this.IsBuilt) {
            return this
        }
        ; immediately after the struct, ignore packing
        this.Pos := (DLGITEMTEMPLATE.sizeof - 2)

        this.AddResource(this.__Type) ; window class / atom
        this.AddResource(this.__Text) ; control text

        ; additional data with length prefix
        this.AddUShort(this.__Data.Size).AddData(this.__Data)
        this.IsBuilt := true
        return this
    }
}