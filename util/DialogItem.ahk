#Include <AquaHotkey>
#Include <Tanuki\util\AppendableBuffer>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\DLGTEMPLATE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\DLGITEMTEMPLATE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\WINDOW_STYLE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\WINDOW_STYLE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\Apis>

/**
 * A dialog item.
 * 
 * This is a variable-size buffer class.
 * Use the `Build()` method to correctly write the fields into memory.
 */
class DialogItem extends AppendableBuffer {
    ; load all of the struct members as properties
    static __New() => AquaHotkey.ApplyMixin(this, DLGITEMTEMPLATE)

    /**
     * Creates a new dialog item, initializing the window style with
     * `WS_CHILD`, `WS_VISIBLE` and `WS_TABSTOP`.
     */
    __New() {
        super.__New(DLGTEMPLATE.sizeof, 0)
        this.style := WINDOW_STYLE.WS_CHILD
                    | WINDOW_STYLE.WS_VISIBLE
                    | WINDOW_STYLE.WS_TABSTOP
    }

    /**
     * Sets the window style and extended window style.
     * 
     * @param   {Integer}  Style    the new style
     * @param   {Integer}  ExStyle  the new extended style
     * @returns {this}
     */
    Style(Style, ExStyle := 0) {
        this.style := Style
        this.dwExtendedStyle := ExStyle
        return this
    }

    /**
     * Sets the position of the dialog control (upper-left corner).
     * 
     * @param   {Integer}  x  upper left corner x (in dialog units)
     * @param   {Integer}  y  upper left corner y (in dialog units)
     * @returns {this}
     */
    Position(x, y) {
        this.x := x
        this.y := y
        return this
    }

    /**
     * Sets the size of the dialog control.
     * 
     * @param   {Integer}  Width   the width in dialog units
     * @param   {Integer}  Height  the height in dialog units
     * @returns {this}
     */
    Size(Width, Height) {
        this.cx := Width
        this.cy := Height
        return this
    }

    /**
     * Sets the control ID for the dialog control. This is required if the
     * control requires interaction.
     * 
     * @param   {Integer}  Id  control ID to be used
     * @returns {this}
     */
    ControlId(Id) {
        this.id := Id
        return this
    }

    /**
     * Sets the type of the control. This field *must* be set.
     * 
     * You can use one of the six static constructors (`static Button()`, etc.)
     * to set this field automatically along with appropriate style flags.
     * 
     * @param   {Integer/String}  ControlType  the type of control
     * @returns {this}
     */
    ControlType(ControlType) {
        this.IsBuilt := false
        if (!(ControlType is String) && !IsInteger(ControlType)) {
            throw TypeError("Expected a String or UShort",, Type(ControlType))
        }
        return this.DefineProp("__ControlType", {
            Value: (ControlType is String)
                    ? ControlType
                    : ControlType & 0xFFFF
        })
    }

    /**
     * Sets the initial text or resource identifier of the control.
     * 
     * @param   {Integer/String}  Text  initial text or resource identifier
     * @returns {this}
     */
    Text(Text) {
        this.IsBuilt := false
        if (!(Text is String)) {
            throw TypeError("Expected a String",, Type(Text))
        }
        return this.DefineProp("__Text", { Value: Text })
    }

    /**
     * Sets additional raw data. which is used as `lParam` in `WM_CREATE`
     * when the dialog control is created. This method creates a defensive
     * copy of the memory pointed to.
     * 
     * @param   {Buffer/Integer}  Mem   pointer to the data
     * @param   {Integer?}        Size  the size in bytes
     * @returns {this}
     */
    Data(Mem, Size := Mem.Size) {
        this.IsBuilt := false
        if (!IsInteger(Mem) && (!IsObject(Mem) || !HasProp(Mem, "Ptr"))) {
            throw TypeError("Expected a pointer or Buffer object",,
                            Type(Mem))
        }
        Buf := Buffer(Size & 0xFFFF, 0) ; max size is 0xFFFF

        ; copy data
        Loop (Size & 0xFFFF) {
            Offset := A_Index - 1
            Num := NumGet(Mem, Offset, "UChar")
            NumPut("UChar", Num, Mem, Offset)
        }
        return this.DefineProp("__Data", { Value: Buf })
    }

    /**
     * Indicates whether the fields have been properly written into the buffer.
     */
    IsBuilt := false

    /**
     * Writes the additional fields into the buffer.
     * 
     * Before building, the control class has to be specified using the
     * `ControlType` method, otherwise an error is thrown.
     * 
     * @returns {this}
     */
    Build() {
        if (this.IsBuilt) {
            return this.Size
        }

        Offset := DLGTEMPLATE.sizeof

        ; window class
        switch {
            case (!HasProp(this, "__ControlType")):
                throw UnsetError("Requires a window class")
            case (this.__ControlType is String):
                this.AppendString(this.__ControlType)
            case (this.__ControlType is Integer):
                this.AppendUShort(0xFFFF).AppendUShort(this.__ControlType)
            default:
                throw TypeError("Expected an Integer or String",,
                                Type(this.__ControlType))
        }

        ; title
        switch {
            case (!HasProp(this, "__Text")):
                this.AppendUShort(0)
            case (this.__Text is String):
                this.AppendString(this.__Text)
            case (this.__Text is Integer):
                this.AppendUShort(0xFFFF).AppendUShort(this.__Text)
        }

        ; data
        if (HasProp(this, "__Data") && (this.__Data is Buffer)) {
            Buf := this.__Data
            this.AppendUShort(Buf.Size).AppendData(Buf.Ptr)
        } else {
            this.AppendUShort(0)
        }

        this.IsBuilt := true
        return Offset
    }

    /**
     * Creates a new dialog button.
     * 
     * @returns {DialogItem}
     */
    static Button() {
        Dlg := DialogItem()
        Dlg.style |= WindowsAndMessaging.BS_PUSHBUTTON
        return Dlg.ControlType(0x0080)
    }

    ; TODO do the rest
}