#Include <AquaHotkey>

#Include <AhkWin32Projection\Windows\Win32\Foundation\SIZE>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\NMBCHOTITEM>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\BUTTON_IMAGELIST>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\GDI_IMAGE_TYPE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\HICON>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\HCURSOR>
#Include <AhkWin32Projection\Windows\Win32\Graphics\Gdi\HBITMAP>

/**
 * Extension class for Gui.Button
 */
class Tanuki_Button extends AquaHotkey_MultiApply {
    static __New() => super.__New(Gui.Button)

    /**
     * Presses the button.
     */
    Click() {
        SendMessage(WindowsAndMessaging.BM_CLICK)
    }

    /**
     * Gets and sets the image of this button.
     * 
     * @param   {HBITMAP/HICON}  value  the bitmap/icon to be used
     * @returns {HBITMAP/HICON}
     */
    Image {
        get {
            static SM := SendMessage
            static GI := WindowsAndMessaging.BM_GETIMAGE
            static IT := GDI_IMAGE_TYPE
            return SM(GI, IT.IMAGE_BITMAP, 0, this)
                || SM(GI, IT.IMAGE_ICON,   0, this)
        }
        set {
            static SM := SendMessage
            static GI := WindowsAndMessaging.BM_SETIMAGE
            static IT := GDI_IMAGE_TYPE
            ControlSetStyle("+" . WindowsAndMessaging.BS_BITMAP, this)
            switch {
                case (value is HBITMAP):
                    SM(GI, IT.IMAGE_BITMAP, value.Value, this)
                case (value is HICON):
                    SM(GI, IT.IMAGE_ICON, value.Value, this)
                default:
                    throw TypeError()
            }
        }
    }

    /**
     * Returns the ideal size of the button.
     * 
     * @returns {SIZE}
     */
    IdealSize {
        get {
            SendMessage(Controls.BCM_GETIDEALSIZE, 0, Sz := SIZE(), this)
            return Sz
        }
    }

    /**
     * Gets and sets the image list of the button.
     * 
     * @param   {BUTTON_IMAGELIST}  value  the new button image list
     * @returns {BUTTON_IMAGELIST}
     */
    ImageList {
        get {
            IL := BUTTON_IMAGELIST()
            SendMessage(Controls.BCM_GETIMAGELIST, 0, IL, this)
            return IL
        }
        set {
            if (!(value is BUTTON_IMAGELIST)) {
                throw TypeError("Expected a BUTTON_IMAGELIST",, Type(value))
            }
            SendMessage(Controls.BCM_SETIMAGELIST, 0, value, this)
        }
    }

    /**
     * Gets the sets the text margin of the button.
     * 
     * @param   {RECT}  value  the new text margin
     * @returns {RECT}
     */
    TextMargin {
        get {
            SendMessage(Controls.BCM_GETTEXTMARGIN, 0, Rc := RECT(), this)
            return Rc
        }
        set {
            if (!(value is RECT)) {
                throw TypeError("Expected a RECT",, Type(value))
            }
            SendMessage(Controls.BCM_SETTEXTMARGIN, 0, value, this)
        }
    }

    /**
     * Sets the state of the button to display an elevated icon (a shield).
     * 
     * @param   {Boolean}  value  activate to draw elevated icon
     */
    RequireAdmin {
        set => SendMessage(Controls.BCM_SETSHIELD, 0, !!value, this)
    }

    /**
     * Sets the highlighted appearance of the button.
     * 
     * @param   {Boolean}  value  whether the button is highlighted
     */
    Highlighted {
        set => SendMessage(Controls.BCM_SETSTATE, !!value, 0, this)
    }

    /**
     * Returns the state of the button.
     * 
     * @param   {WindowsAndMessaging.BS*}  value  the new button state
     * @returns {WindowsAndMessaging.BS*}
     */
    State {
        get => SendMessage(WindowsAndMessaging.BM_GETSTATE, 0, 0, this)
        set => SendMessage(WindowsAndMessaging.BM_SETSTATE, !!value, 0, this)
    }

    ;@region Events
    /**
     * Registers a function to call when the button is clicked.
     * 
     * @param   {Func}      Fn   the function to be called
     * @param   {Integer?}  Opt  add/remove the callback
     * @returns {this}
     */
    OnClick(Fn, Opt?) {
        this.OnCommand(WindowsAndMessaging.BN_CLICKED, Fn, Opt?)
        return this
    }

    /**
     * Registers a function to call when the button is double-clicked.
     * 
     * @param   {Func}      Fn   the function to be called
     * @param   {Integer?}  Opt  add/remove the callback
     * @returns {this}
     */
    OnDoubleClick(Fn, Opt?) {
        ControlSetStyle("+" . WindowsAndMessaging.BS_NOTIFY, this)
        this.OnCommand(WindowsAndMessaging.BN_DOUBLECLICKED, Fn, Opt?)
        return this
    }

    /**
     * Registers a function to call when the button gains focus.
     * 
     * @param   {Func}      Fn   the function to be called
     * @param   {Integer?}  Opt  add/remove the callback
     * @returns {this}
     */
    OnFocus(Fn, Opt?) {
        ControlSetStyle("+" . WindowsAndMessaging.BS_NOTIFY, this)
        this.OnCommand(WindowsAndMessaging.BN_SETFOCUS, Fn, Opt?)
        return this
    }

    /**
     * Registers a function to call when the button loses focus.
     * 
     * @param   {Func}      Fn   the function to be called
     * @param   {Integer?}  Opt  add/remove the callback
     * @returns {this}
     */
    OnFocusLost(Fn, Opt?) {
        ControlSetStyle("+" . WindowsAndMessaging.BS_NOTIFY, this)
        this.OnCommand(WindowsAndMessaging.BN_KILLFOCUS, Fn, Opt?)
        return this
    }

    /**
     * Registers a function to call when the mouse is entering or leaving
     * the client area of the button.
     * 
     * @see {NMBCHOTITEM}
     * @see {Controls.HICF*}
     * @example
     * Button_HotItemChanged(Btn, lParam) {
     *     Hdr := NMBCHOTITEM(lParam)
     * }
     * 
     * @param   {Func}      Fn   the function to be called
     * @param   {Integer?}  Opt  add/remove the callback
     * @returns {this}
     */
    OnHover(Fn, Opt?) {
        this.OnNotify(Controls.BCN_HOTITEMCHANGE, Fn, Opt?)
        return this
    }

    ;@endregion
}