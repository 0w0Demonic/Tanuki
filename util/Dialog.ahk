#Include <AquaHotkey>
#Include <Tanuki\util\AppendableBuffer>
#Include <Tanuki\util\DialogItem>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\DLGTEMPLATE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\DLGITEMTEMPLATE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\WINDOW_STYLE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>

/**
 * Dimensions and style of a dialog box.
 * 
 * This is a variable-size buffer class.
 * Use the `Build()` method to correctly write the fields into memory.
 */
class Dialog extends AppendableBuffer {
    ; load all of the struct members as properties
    static __New() => AquaHotkey.ApplyMixin(this, DLGTEMPLATE)

    /**
     * Creates a new dialog template, and initializes the style with
     * `WS_CHILD` and `WS_VISIBLE`.
     */
    __New() {
        super.__New(DLGTEMPLATE.sizeof, 0)
        this.style := WINDOW_STYLE.WS_CHILD | WINDOW_STYLE.WS_VISIBLE
    }

    /**
     * Sets the style and extended style of the dialog template.
     * 
     * @param   {Integer}   Style    style
     * @param   {Integer?}  ExStyle  extended style
     * @returns {this}
     */
    Style(Style, ExStyle := 0) {
        this.style := Style
        this.dwExtendedStyle := ExStyle
        return this
    }

    /**
     * Sets the coordinates of the upper-left corner of the dialog box.
     * 
     * @param   {Integer}  x  x coordinate in dialog box units
     * @param   {Integer}  y  y coordinate in dialog box units
     * @returns {this}
     */
    Position(x, y) {
        this.x := x
        this.y := y
        return this
    }

    /**
     * Assigns the default small size of property sheets for the dialog
     * template.
     * 
     * @returns {this}
     */
    Small() {
        this.cx := Controls.PROP_SM_CXDLG
        this.cy := Controls.PROP_SM_CYDLG
        return this
    }

    /**
     * Assigns the default medium size of property sheets for the dialog
     * template.
     * 
     * @returns {this}
     */
    Medium() {
        this.cx := Controls.PROP_MED_CXDLG
        this.cy := Controls.PROP_MED_CYDLG
        return this
    }

    /**
     * Assigns the default large size of property sheets for the dialog
     * template.
     * 
     * @returns {this}
     */
    Large() {
        this.cx := Controls.PROP_LG_CXDLG
        this.cy := Controls.PROP_LG_CYDLG
        return this
    }

    /**
     * Sets the size of the dialog template in dialog box units.
     * 
     * @param   {Integer}  Width   the width in dialog box units
     * @param   {Integer}  Height  the height in dialog box units
     * @returns {this}
     */
    Size(Width, Height) {
        this.cx := Width
        this.cy := Height
        return this
    }

    /**
     * Sets the typeface and point size for the text in the dialog box.
     * 
     * @param   {String}   FontName  name of the typeface
     * @param   {Integer}  FontSize  point size of the font
     * @returns {this}
     */
    Font(FontName, FontSize) {
        this.IsBuilt := false
        if (!(FontName is String)) {
            throw TypeError("Expected a String",, Type(FontName))
        }
        this.DefineProp("__FontName", { Value: FontName })
        this.style |= WindowsAndMessaging.DS_SETFONT
        return this.DefineProp("__FontSize", { Value: FontSize & 0xFFFF })
    }

    /**
     * Sets a custom window class of the dialog box. This can be the ordinal
     * of a predefined system window class, or the name of the class as string.
     * 
     * Otherwise, the predefined dialog box class is used.
     * 
     * @param   {Integer/String}  WindowClass  the window class to be used
     */
    WindowClass(WindowClass) {
        this.IsBuilt := false
        if (WindowClass is String) {
            return this.DefineProp("__WindowClass", { Value: WindowClass })
        }
        return this.DefineProp("__WindowClass", { Value: WindowClass & 0xFFFF })
    }

    /**
     * Lazy init for an array that holds controls.
     * 
     * @returns  {Array<DialogItem>}
     */
    __Controls {
        get {
            Arr := Array()
            this.DefineProp("__Controls", { Value: Arr })
            return Arr
        }
    }

    /**
     * Adds a new dialog control.
     * 
     * @param   {DialogItem}
     */
    Control(Control) {
        this.IsBuilt := false
        if (!(Control is DialogItem)) {
            throw TypeError("Expected a DialogItem",, Type(Control))
        }
        this.__Controls.Push()
        return this
    }

    /**
     * Indicates whether fields are properly written into memory.
     */
    IsBuilt := false

    /**
     * Writes the menu, window class, title, font and controls into memory.
     * 
     * @returns {this}
     */
    Build() {
        if (this.IsBuilt) {
            return this.Size
        }

        this.Offset := DLGITEMTEMPLATE.sizeof

        ; menu
        switch {
            case (!HasProp(this, "__Menu")):
                this.AppendUShort(0)
            case (this.__Menu is String):
                this.AppendString(this.__Menu)
            case (this.__Menu is Integer):
                this.AppendUShort(0xFFFF).AppendUShort(this.__Menu)
            default:
                throw TypeError("Expected an Integer or String",,
                                Type(this.__Menu))
        }

        ; window class
        switch {
            case (!HasProp(this, "__WindowClass")):
                this.AppendUShort(0)
            case (this.__WindowClass is String):
                this.AppendString(this.__WindowClass)
            case (this.__WindowClass is Integer):
                this.AppendUShort(0xFFFF).AppendUShort(this.__WindowClass)
            default:
                throw TypeError("Expected an Integer or String",,
                                Type(this.__WindowClass))
        }

        ; title
        if (HasProp(this, "__Title")) {
            this.AppendString(this.__Title)
        } else {
            this.AppendUShort(0)
        }

        ; font
        if (HasProp(this, "__FontName") && HasProp(this, "__FontSize")) {
            this.AppendUShort(this.__FontSize).AppendString(this.__FontName)
        }

        ; controls
        this.cdit := this.__Controls.Length

        for Ctl in this.__Controls {
            Size := Ctl.Build()
            Mem := Ctl.Ptr
            this.Align(4).AppendData(Mem, Size)
        }

        this.IsBuilt := true
        return this
    }
}