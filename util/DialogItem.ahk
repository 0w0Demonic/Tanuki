#Include <AquaHotkey>
#Include <Tanuki\util\AppendableBuffer>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\DLGITEMTEMPLATE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\WINDOW_STYLE>

/**
 * A control contained in a dialog box.
 * 
 * Valid dialog items *must* contain a window class, which is set either by
 * using the {@link DialogItem#Type .Type()} method or one of the static
 * constructors, e.g. {@link DialogItem.Text static Text()}.
 * 
 * Use the `Build()` method to correctly write the fields into memory.
 */
class DialogItem extends AppendableBuffer {
    ; load all of the struct members as properties
    static __New() => AquaHotkey.ApplyMixin(this, DLGITEMTEMPLATE)

    /**
     * Available control types. (see {@link DialogItem#Type})
     * 
     * @returns {Object}
     */
    static Type => {
        Button:    0x0080,
        Edit:      0x0081,
        Static:    0x0082,
        ListBox:   0x0083,
        ScrollBar: 0x0084,
        ComboBox:  0x0085
    }

    /**
     * Creates a simple button.
     * 
     * @param   {String?}   Text     the text to be displayed
     * @param   {Boolean?}  Default  whether the button is used as default
     * @returns {DialogItem}
     */
    static Button(Text := "", Default := false) {
        Ctl := this().Text(Text).Type(DialogItem.Type.Button)
        Ctl.style |= WINDOW_STYLE.WS_TABSTOP

        if (Default) {
            Ctl.style |= WindowsAndMessaging.BS_DEFPUSHBUTTON
        } else {
            Ctl.style |= WindowsAndMessaging.BS_PUSHBUTTON
        }
        return Ctl
    }

    /**
     * Creates a simple text control.
     * 
     * @param   {String}  Text  the text to be displayed in the control
     * @returns {DialogItem}
     */
    static Text(Text) => this.Text(Text).Type(DialogItem.Type.Static)

    /**
     * Whether the dialog item has been properly written into the buffer.
     * {@link DialogItem#Build}
     * 
     * @returns {Boolean}
     */
    IsBuilt := false

    /**
     * Creates a new `DialogItem`, initializing its style with `WS_CHILD` and
     * `WS_VISIBLE`.
     */
    __New() {
        super.__New(DLGITEMTEMPLATE.sizeof, 0)
        this.Style := WINDOW_STYLE.WS_VISIBLE | WINDOW_STYLE.WS_CHILD
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
    Id(Id) {
        this.id := Id
        return this
    }

    /**
     * Default control type. Accessing this property throws an error.
     */
    __Type {
        get {
            throw UnsetError("unset control type")
        }
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
    Type(Type) {
        this.IsBuilt := false
        return this.DefineProp("__Type", { Value: Type })
    }

    /**
     * Default control text (empty string).
     * 
     * @returns {String}
     */
    __Text => ""

    /**
     * Sets the initial text or resource identifier of the control.
     * 
     * @param   {Integer/String}  Text  initial text or resource identifier
     * @returns {this}
     */
    Text(Text) {
        this.IsBuilt := false
        return this.DefineProp("__Text", { Value: Text })
    }

    /**
     * Default empty data creation array.
     * 
     * @returns {Buffer}
     */
    __Data => Buffer(0, 0)

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
        return this.DefineProp("__Data", { Value: ClipboardAll(Mem, Size) })
    }

    /**
     * Writes the additional fields into the buffer.
     * 
     * Before building, the control class has to be specified using the
     * `ControlType` method, otherwise an error is thrown.
     * 
     * @returns {this}
     */
    Build() {
        AddResource(Res := "") {
            if (Res is Integer) {
                this.AddUShort(0xFFFF).AddUShort(Res & 0xFFFF)
            } else {
                this.AddString(Res)
            }
        }

        if (this.IsBuilt) {
            return this
        }
        ; immediately after the struct, ignore packing
        this.Pos := (DLGITEMTEMPLATE.sizeof - 2)

        AddResource(this.__Type) ; window class / atom
        AddResource(this.__Text) ; control text

        this.AddUShort(this.__Data.Size).AddData(this.__Data)
        this.IsBuilt := true
        return this
    }
}
