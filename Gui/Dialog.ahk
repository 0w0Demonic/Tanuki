#Include <AquaHotkey>
#Include <Tanuki\Gui\DialogItem>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\DLGTEMPLATE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\DLGITEMTEMPLATE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\WINDOW_STYLE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>

/**
 * Dimensions and style of a dialog box.
 * 
 * This class is a wrapper around the `DLGTEMPLATE` struct. It uses a
 * variable-sized buffer to specify additional options such as menu,
 * window class, title, font settings and all of its dialog controls.
 * 
 * To ensure that fields have been properly written into memory, you must call
 * `.Build()` first. `PropertySheet#Pages()` does this automatically.
 */
class Dialog extends AppendableBuffer {
    ; load all mappings from `DLGTEMPLATE`
    static __New() => AquaHotkey.ApplyMixin(this, DLGTEMPLATE)

    /**
     * Whether the dialog has been properly written into the buffer.
     * {@link Dialog#Build}
     * 
     * @type {Boolean}
     */
    IsBuilt := false

    /**
     * Creates a new `Dialog`, initializing its window style with `WS_CHILD`
     * and `WS_VISIBLE`.
     */
    __New() {
        super.__New(DLGTEMPLATE.sizeof, 0)
        this.Style := WINDOW_STYLE.WS_CHILD | WINDOW_STYLE.WS_VISIBLE
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
     * Default empty menu.
     * 
     * @returns {String}
     */
    __Menu => ""

    /**
     * Specifies a menu to be used by the dialog.
     * 
     * @param   {Integer/String}  Menu  the menu to be used by the dialog
     * @returns {this}
     */
    Menu(Menu) {
        this.IsBuilt := false
        return this.DefineProp("__Menu", { Value: Menu })
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
     * Default window class (predefined dialog box class).
     * 
     * @returns {String}
     */
    __WindowClass => ""

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
     * All controls contained in the dialog box (lazy init).
     * 
     * @returns {Array}
     */
    __Controls {
        get {
            Arr := Array()
            this.DefineProp("__Controls", { Value: Arr })
            return Arr
        }
    }

    /**
     * Default title of the fialog box (empty string).
     * 
     * @returns {String}
     */
    __Title => ""

    /**
     * Sets the title to be used by the dialog box.
     * 
     * @param   {String}  Title  the title to be used
     * @returns {this}
     */
    Title(Title) {
        if (!(Title is String)) {
            throw TypeError("Expected a String",, Type(Title))
        }
        return this.DefineProp("__Title", { Value: Title })
    }

    /**
     * Sets zero or more controls to be used by the dialog box.
     * 
     * @param   {Array<DialogItem>}  Controls  the controls to be used
     * @returns {this}
     */
    Controls(Controls*) {
        if (!Controls.Length) {
            return this
        }
        this.IsBuilt := false
        for Control in Controls {
            if (!(Control is DialogItem)) {
                throw TypeError("Expected a DialogItem",, Type(Control))
            }
            this.__Controls.Push(Control)
        }
        return this
    }

    /**
     * Builds this dialog by writing its fields into memory.
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
        this.Pos := DLGTEMPLATE.sizeof - 2

        AddResource(this.__Menu)
        AddResource(this.__WindowClass)
        this.AddString(this.__Title)

        ; font
        if (HasProp(this, "__FontName") && HasProp(this, "__FontSize")) {
            this.AddUShort(this.__FontSize).AddString(this.__FontName)
        }

        ; controls
        this.cdit := this.__Controls.Length

        for Ctl in this.__Controls {
            this.Align(4)
            Ctl.Build()
            this.AddData(Ctl.Ptr, Ctl.Pos)
            this.Align(4)
        }

        this.IsBuilt := true
        return this
    }
}