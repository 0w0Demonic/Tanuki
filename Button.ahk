/**
 * Adds a new button to the Gui.
 * 
 * @param   {String?}  Opt  additional options
 * @param   {String?}  Txt  the text to display
 * @return  {Gui.Button}
 */
AddButton(Opt?, Txt?) => this.Add("Button", Opt?, Txt?)

/** Defines new properties and methods for `Gui.Button` controls */
class Button {
    /**
     * Applies a theme to the button.
     * 
     * @param   {Object}  Theme  the theme to apply
     * @return  {Object}
     */
    ApplyTheme(Theme) {
        ; TODO background doesn't work
        Theme := Tanuki.PrepareSubTheme(Theme, "Button")
        Tanuki.ApplyFont(this, Theme)

        if (HasProp(Theme, "DarkMode") && Theme.DarkMode) {
            DllCall("uxtheme\SetWindowTheme",
                    "Ptr", this.Hwnd, 
                    "Str", "DarkMode_Explorer",
                    "Ptr", 0)
        }

        if (HasProp(Theme, "Background")) {
            this.Opt("Background" . Theme.Background)
        }
        
        return Theme
    }

    /** All button styles. */
    class Style {
        static PushButton         => 0x0000
        static DefaultPushButton  => 0x0001
        static CheckBox           => 0x0002
        static AutoCheckBox       => 0x0003
        static RadioButton        => 0x0004
        static ThreeState         => 0x0005
        static AutoThreeState     => 0x0006
        static GroupBox           => 0x0007
        static UserButton         => 0x0008
        static AutoRadioButton    => 0x0009
        static PushBox            => 0x000A
        static OwnerDraw          => 0x000B
        static SplitButton        => 0x000C
        static DefaultSplitButton => 0x000D
        static CommandLink        => 0x000E
        static DefaultCommandLink => 0x000F
        static TypeMask           => 0x000F
        
        static LeftText    => 0x0020
        static RightButton => 0x0020

        static Text        => 0x0000
        static Icon        => 0x0040
        static Bitmap      => 0x0080
        static Left        => 0x0100
        static Right       => 0x0200
        static Center      => 0x0300
        static Top         => 0x0400
        static Bottom      => 0x0800
        static VCenter     => 0x0C00
        static PushLike    => 0x1000
        static MultiLine   => 0x2000
        static Notify      => 0x4000
        static Flat        => 0x8000
    }

    /**
     * Sent when the user clicks the button.
     * 
     * @example
     * MyButton_Click(ButtonControl) {
     * }
     * 
     * @param   {Func}      Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the function
     */
    OnClick(Callback, AddRemove?) {
        static BN_CLICKED := 0x0000
        return Gui.Event.OnCommand(this, BN_CLICKED, Callback, AddRemove?)
    }

    /**
     * Sent when a button should be painted.
     * 
     * @example
     * MyButton_Paint(ButtonControl) {
     * }
     * 
     * @param   {Func}      Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the function
     * @return  {Gui.Event}
     */
    OnPaint(Callback, AddRemove?) {
        static BN_PAINT := 0x0001
        return Gui.Event.OnCommand(this, BN_PAINT, Callback, AddRemove?)
    }

    /**
     * Sent when the button is diabled.
     * 
     * @example
     * MyButton_Disable(ButtonControl) {
     * }
     * 
     * @param   {Func}      Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the function
     * @return  {Gui.Event}
     */
    OnDisable(Callback, AddRemove?) {
        static BN_DISABLE := 0x0004
        return Gui.Event.OnCommand(this, BN_DISABLE, Callback, AddRemove?)
    }

    /**
     * Sent when the user double-clicks the button.
     * 
     * @example
     * MyButton_DoubleClick(ButtonControl) {
     * }
     * 
     * @param   {Func}      Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the function
     * @return  {Gui.Event}
     */
    OnDoubleClick(Callback, AddRemove?) {
        static BN_DOUBLECLICKED := 0x0005
        return Gui.Event.OnCommand(this, BN_DOUBLECLICKED, Callback, AddRemove?)
    }

    /**
     * Sent when a button receives the keyboard focus.
     * 
     * @example
     * MyButton_Focus(ButtonControl) {
     * }
     * 
     * @param   {Func}      Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the function
     * @return  {Gui.Event}
     */
    OnFocus(Callback, AddRemove?) {
        try this.Style |= Gui.Button.Style.Notify
        static BN_SETFOCUS := 0x0006
        return Gui.Event.OnCommand(this, BN_SETFOCUS, Callback, AddRemove?)
    }

    /**
     * Sent when a button loses the keyboard focus.
     * 
     * @example
     * MyButton_FocusLost(ButtonControl) {
     * }
     * 
     * @param   {Func}      Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the function
     * @return  {Gui.Event}
     */
    OnFocusLost(Callback, AddRemove?) {
        try this.Style |= Gui.Button.Style.Notify
        static BN_KILLFOCUS := 0x0007
        return Gui.Event.OnCommand(this, BN_KILLFOCUS, Callback, AddRemove?)
    }

    /**
     * Simulates the user clicking the button.
     */
    Click() {
        static BM_CLICK := 0x00F5
        SendMessage(BM_CLICK, 0, 0, this)
    }

    ; TODO wrap this in BITMAP and ICON
    ; TODO how do I remove that "Type" parameter?
    /**
     * Retrieves and changes the handle to the image (icon or bitmap)
     * associated with the button.
     * 
     * @param   {Boolean}              IsIcon  the type of image
     * @param   {Gdi.Bitmap/Gdi.Icon}  value   the new icon/bitmap
     * @return  {Gdi.Bitmap/Gdi.Icon}
     */
    Image[IsIcon] {
        get {
            static BM_GETIMAGE := 0x00F6
            return SendMessage(BM_GETIMAGE, !!IsIcon, 0, this)
        }
        set {
            static BM_SETIMAGE := 0x00F7
            return SendMessage(BM_SETIMAGE, !!IsIcon, Obj, this)
        }
    }

    /**
     * Gets the size that best fits the text and image of the button control.
     * 
     * @return  {SIZE}
     */
    IdealSize {
        get {
            static BCM_GETIDEALSIZE := 0x1601
            Sz := SIZE()
            SendMessage(BCM_GETIDEALSIZE, 0, ObjGetDataPtr(Sz), this)
            return Sz
        }
    }

    /**
     * TODO test this
     * 
     * Retrieves and changes the structure that describes the image list of
     * the button control.
     * 
     * @param   {BUTTON_IMAGELIST}  value  the new image list to display
     * @return  {BUTTON_IMAGELIST}
     */
    ImageList {
        get {
            static BCM_GETIMAGELIST := 0x1603
            BtnImageList := BUTTON_IMAGELIST()

            SendMessage(BCM_GETIMAGELIST, 0, ObjGetDataPtr(BtnImageList), this)
            return BtnImageList
        }
        set {
            static BCM_SETIMAGELIST := 0x1602
            if (!(value is BUTTON_IMAGELIST)) {
                throw TypeError("Expected a BUTTON_IMAGELIST",, Type(value))
            }
            SendMessage(BCM_SETIMAGELIST, 0, ObjGetDataPtr(value), this)
        }
    }

    /**
     * Retrieves and changes the margins used to draw text in the button
     * control.
     * 
     * @param   {RECT/Array/String}  Rc  the new text margin
     * @return  {RECT}
     */
    TextMargin {
        get {
            static BCM_GETTEXTMARGIN := 0x1605
            Rc := RECT()
            SendMessage(BCM_GETTEXTMARGIN, 0, ObjGetDataPtr(Rc), this)
            return Rc
        }
        set {
            static BCM_SETTEXTMARGIN := 0x1604
            Rc := RECT.Create(value)
            SendMessage(BCM_SETTEXTMARGIN, 0, ObjGetDataPtr(Rc), this)
        }
    }

    /**
     * Sent when the mouse is entering or leaving the client area of the button
     * control.
     * 
     * @example
     * MyButton_OnHover(ButtonControl, Info) {
     *     if (Info.Entering) {
     *         ToolTip("entering area...")
     *     } else {
     *         ToolTip("leaving area...")
     *     }
     * }
     * 
     * @param   {Func}      Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the function
     * @return  {Gui.Event}
     */
    OnHover(Callback, AddRemove?) {
        static BTN_HOTITEMCHANGE := -1249
        return Gui.Event.OnNotify(this, BTN_HOTITEMCHANGE, Hover, AddRemove?)

        Hover(ButtonControl, lParam) {
            HotItemStruct := StructFromPtr(NMBCHOTITEM, lParam)
            Callback(ButtonControl, HotItemStruct.dwFlags)
        }
    }

    /**
     * Sets the elevation required state for the button to display an elevated
     * icon (a shield).
     * 
     * @param   {Boolean}  value  activate to draw elevated icon
     */
    RequireAdmin {
        set {
            static BCM_SETSHIELD := 0x160C
            SendMessage(BCM_SETSHIELD, 0, !!value, this)
        }
    }

    /**
     * Sets the highlight state of the button. Highlighting affects only
     * the appearance of the button.
     * 
     * @param   {Boolean}  value  wether the button is highlighted.
     */
    IsHighlighted {
        set {
            static BM_SETSTATE := 0x00F3
            SendMessage(BM_SETSTATE, !!value, 0, this)
        }
    }

    /**
     * Retrieves the state of the button.
     * 
     * @return  {Gui.Button.State}
     */
    State {
        get {
            static BM_GETSTATE := 0x00F2
            Result := SendMessage(BM_GETSTATE, 0, 0, this)
            return Gui.Button.State(Result)
        }
    }

    /** An object that wraps around button state constants. */
    class State {
        Value : u16

        /**
         * Creates a new `Gui.Button.State` object.
         * 
         * @param  {Integer}  Value  integer containing state flags
         */
        __New(Value) {
            this.Value := Value
        }
        
        Pushed  => !!(this.Value & Gui.Button.State.Pushed)
        Focused => !!(this.Value & Gui.Button.State.Focused)
        Hot     => !!(this.Value & Gui.Button.State.Hot)

        static Unchecked      => 0x0000
        static Checked        => 0x0001
        static Indeterminate  => 0x0002
        static Pushed         => 0x0004
        static Focused        => 0x0008
        static Hot            => 0x0200
        static DropDownPushed => 0x0400
    }
}