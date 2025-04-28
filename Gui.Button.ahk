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

        static TypeMask    => 0x000F
        
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

    OnHighlight(Callback, AddRemove?) {
        static BN_HILITE := 0x0002
        return Gui.Event.OnCommand(this, BN_HILITE, Callback, AddRemove?)
    }

    OnHighlightLost(Callback, AddRemove?) {
        static BN_UNHILITE := 0x0003
        return Gui.Event.OnCommand(this, BN_UNHILITE, Callback, AddRemove?)
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
        ; TODO need to add BS_NOTIFY?
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
        ; TODO need to add BS_NOTIFY?
        static BN_KILLFOCUS := 0x0007
        return Gui.Event.OnCommand(this, BN_KILLFOCUS, Callback, AddRemove?)
    }

    SetButtonStyle(Style, Redraw := true) {
        ; TODO check for integer
        static BM_SETSTYLE := 0x00F4
        SendMessage(BM_SETSTYLE, Style, !!Redraw, this)
    }

    Click() {
        static BM_CLICK := 0x00F5
        SendMessage(BM_CLICK, 0, 0, this)
    }

    ; TODO wrap this in BITMAP
    GetImage(Type) {
        static BM_GETIMAGE := 0x00F6
        return SendMessage(BM_GETIMAGE, Type, 0, this)
    }

    SetImage(Type, Obj) {
        static BM_SETIMAGE := 0x00F7
        return SendMessage(BM_SETIMAGE, Type, Obj, this)
    }

    IdealSize {
        get {
            static BCM_GETIDEALSIZE := 0x1601
            Sz := SIZE()
            SendMessage(BCM_GETIDEALSIZE, 0, ObjGetDataPtr(Sz), this)
            return Sz
        }
    }

    ImageList {
        get {

        }
        set {

        }
    }

    GetTextMargin() {
        static BCM_GETTEXTMARGIN := 0x1605
        Rc := RECT()
        SendMessage(BCM_GETTEXTMARGIN, 0, ObjGetDataPtr(Rc), this)
        return Rc
    }

    SetTextMargin(Rc, Relative := false) {
        static BCM_SETTEXTMARGIN := 0x1604
        Rc := RECT.Create(Rc)
        if (Relative) {
            OldRc := this.GetTextMargin()
            Rc.Left   += OldRc.Left
            Rc.Top    += OldRc.Top
            Rc.Right  += OldRc.Right
            Rc.Bottom += OldRc.Bottom
        }
        SendMessage(BCM_SETTEXTMARGIN, 0, ObjGetDataPtr(Rc), this)
    }

    OnHover(Callback, AddRemove?) {
        
    }

    class SplitButton {
        class Style {
            static NoSplit   => 0x0001
            static Stretch   => 0x0002
            static AlignLeft => 0x0004
            static Image     => 0x0008
        }
        class Info {
            static Glyph => 0x0001
            static Image => 0x0002
            static Style => 0x0004
            static Size  => 0x0008
        }
    }

    DropDownState {
        set {

        }
    }

    SplitInfo {
        get {

        }
        set {

        }
    }

    Note {
        get {

        }
        set {

        }
    }

    ElevationRequired {
        set {
            static BCM_SETSHIELD := 0x160C
            SendMessage(BCM_SETSHIELD, 0, !!value, this)
        }
    }

    OnDropDown(Callback, AddRemove?) {

    }
}