/**
 * Adds an edit control to the Gui.
 * 
 * @param   {String?}  Opt  additional options
 * @param   {String?}  Txt  the text to display
 */
AddEdit(Opt?, Txt?) => this.Add("Edit", Opt?, Txt?)

/**
 * Defines new properties for the `Gui.Edit` class.
 */
class Edit {
    /**
     * Applies a theme to the edit control.
     * @param   {Object}  Theme  the theme to apply
     */
    ApplyTheme(Theme) {
        Theme := Tanuki.PrepareSubTheme(Theme, "Edit")
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
    }

    /**
     * Returns an object that is used for displaying balloon tips.
     * 
     * @return  {Gui.Edit.BalloonTip}
     */
    BalloonTip => Gui.Edit.BalloonTip(this)

    /**
     * A "balloon tip" is a notification that appears above the edit control,
     * resembling a cartoon speech bubble.
     */
    class BalloonTip {
        cbStruct : u32 := ObjGetDataSize(this)
        pszTitle : uPtr
        pszText  : uPtr
        ttiIcon  : i32

        /** Icons which are used inside of the balloon tip. */
        static Icon => {
            None:         0,
            Info:         1,
            Warning:      2,
            Error:        3,
            InfoLarge:    4,
            WarningLarge: 5,
            ErrorLarge:   6
        }

        /**
         * Creates a new BalloonTip object which is associated with the
         * given edit control.
         * 
         * @param   {Gui.Edit}  EditCtl  edit control that owns the balloon tip
         * @return  {Gui.Edit.BalloonTip}
         */
        __New(EditCtl) {
            if (!(EditCtl is Gui.Edit)) {
                throw TypeError("Expected a Gui.Edit",, Type(EditCtl))
            }
            this.DefineProp("Hwnd", {
                Get: (Instance) => EditCtl.Hwnd
            })
        }

        /**
         * Shows a balloon tip in the edit control.
         * 
         * @param   {String?}   Title  title of the balloon tip
         * @param   {String?}   Text   the text to display
         * @param   {Integer?}  Icon   a ToolTip icon (see `static Icon`)
         */
        Show(Title := "", Text := "", Icon := 0) {
            static EM_SHOWBALLOONTIP := 0x1503

            if (IsObject(Title) || IsObject(Text)) {
                throw TypeError("Expected a String",,
                                Type(Title) . " " . Type(Text))
            }
            if (!IsObject(Icon))
            this.pszTitle := StrPtr(Title)
            this.pszText  := StrPtr(Text)
            this.ttiIcon  := Icon

            SendMessage(EM_SHOWBALLOONTIP, 0, ObjGetDataPtr(this), this.Hwnd)
        }

        /** Hides the balloon tip. */
        Hide() {
            static EM_HIDEBALLOONTIP := 0x1504
            SendMessage(EM_HIDEBALLOONTIP, 0, 0, this.Hwnd)
        }
    }

    /**
     * Gets the currently selected text inside of the edit control.
     * 
     * @return  {String}
     */
    SelectedText => EditGetSelectedText(this)

    /**
     * Selects a range of characters in the edit control.
     * If the user uses the `SHIFT` key, the anchor point remains the same.
     * 
     * Parameters behave exactly as they would in built-in `SubStr()`.
     * 
     * To select all text inside the edit control, use `SelectAll()`.
     * To deselect text, use `Deselect()`.
     * 
     * @param   {Integer}   Start   1-based index of the starting character
     * @param   {Integer?}  Length  length of the selection (default 1)
     * @return  {this}
     */
    Select(Start, Length?) {
        static EM_SETSEL := 0x00B1

        if (!IsInteger(Start)) {
            throw TypeError("Expected an Integer",, Type(Start))
        }
        TotalLength := this.TextLength

        ; omitted `Length` --> until end of string (or length 0 + deselect)
        if (!IsSet(Length)) {
            Length := Max(0, TotalLength - Start + 1)
        }
        if (!IsInteger(Length)) {
            throw TypeError("Expected an Integer",, Type(Length))
        }

        if ((Start == 0) || (Length == 0)) {
            return this.Deselect()
        }

        ; convert `Start` to 0-based starting index.
        ; negative parameter --> last x characters
        if (Start < 0) {
            Start := Max(0, Start + TotalLength)
        } else {
            Start -= 1
        }

        ; convert `Length` to 0-based end index.
        ; negative parameter --> omit x characters from end
        if (Length < 0) {
            Stop := Max(Start, TotalLength + Length)
        } else {
            Stop := Min(TotalLength, Start + Length)
        }

        SendMessage(EM_SETSEL, Start, Stop, this)
        return this
    }

    /** Selects all the text inside of the edit control. */
    SelectAll() {
        static EM_SETSEL := 0x00B1
        SendMessage(EM_SETSEL, 0, -1, this)
    }

    /** Deselects any selected text in the edit control. */
    Deselect() {
        static EM_SETSEL := 0x00B1
        SendMessage(EM_SETSEL, -1, -1, this)
    }

    /**
     * Returns a `RECT` that contains the bounds of the text display area.
     * This area defines where text is rendered within the edit control and
     * can be modified using `.SetTextBounds()`.
     * 
     * @return  {RECT}
     */
    GetTextBounds() {
        static EM_GETRECT := 0x00B2
        Rc := RECT()
        SendMessage(EM_GETRECT, 0, ObjGetDataPtr(Rc), this)
        return Rc
    }

    /**
     * Modifies the text `RECT` that contains the bounds the text display
     * area.
     * 
     * @param   {RECT/Array/String}  Rc        the new RECT of the edit control
     * @param   {Boolean?}           Relative  coords are relative to old RECT
     * @param   {Boolean?}           Redraw    control is redrawn
     * @return  {this}
     */
    SetTextBounds(Rc, Relative := false, Redraw := true) {
        static EM_SETRECT   := 0x00B3
        static EM_SETRECTNP := 0x00B4

        if (!IsObject(Rc)) {
            Rc := StrSplit(Rc, ",", A_Space)
        }
        if (Rc is Array) {
            if (Rc.Length != 4) {
                throw ValueError("Invalid number of RECT params",, Rc.Length)
            }
            Rc := RECT(Rc*)
        }
        if (!(Rc is RECT)) {
            throw TypeError("Expected a RECT",, Type(Rc))
        }

        Msg := (Redraw) ? EM_SETRECT
                        : EM_SETRECTNP

        SendMessage(Msg, !!Relative, ObjGetDataPtr(Rc), this)
        return this
    }

    /**
     * Returns the number of lines in the edit control.
     * 
     * @return  {Integer}
     */
    LineCount => EditGetLineCount(this)

    /**
     * 
     */
    Scroll(UpDown := 0, LeftRight := 0) {
        static EM_SCROLL := 0x00B5
        static EM_LINESCROLL := 0x00BB

        static SB_LINEUP := 0x0000
        static SB_LINEDOWN := 0x0001
        static SB_PAGEUP := 0x0002
        static SB_PAGEDOWN := 0x0003

        ; TODO
        if (this.MultiLine) {
            Direction := (UpDown > 0) ? SB_PAGEDOWN : SB_PAGEUP
        }

    }

    /**
     * 
     */
    ScrollLines(Count) {
        static EM_SCROLL := 0x00B5

        static SB_LINEUP := 0x0000
        static SB_LINEDOWN := 0x0001

        if (!IsInteger(Count)) {
            throw TypeError("Expected an Integer", , Type(Count))
        }
        if (!Count) {
            return 0
        }
        Direction := (Count > 0) ? SB_LINEDOWN : SB_LINEUP

        TotalLines := 0
        loop Abs(Count) {
            Lines := SendMessage(EM_SCROLL, Direction, 0, this) & 0xFFFF
            if (!Lines) {
                break
            }
            TotalLines += Lines
        }
        return TotalLines
    }

    ScrollPages(Count) {
        static EM_SCROLL := 0x00B5

        static SB_PAGEUP := 0x0002
        static SB_PAGEDOWN := 0x0003

        if (!IsInteger(Count)) {
            throw TypeError("Expected an Integer", , Type(Count))
        }
        if (!Count) {
            return
        }
        Direction := (Count > 0) ? SB_PAGEDOWN : SB_PAGEUP

        TotalLines := 0
        loop Abs(Count) {
            Lines := SendMessage(EM_SCROLL, Direction, 0, this) & 0xFFFF
            if (!Lines) {
                break
            }
            TotalLines += Lines
        }
        return TotalLines
    }

    ; TODO EM_LINESCROLL

    ScrollCaret() {
        static EM_SCROLLCARET := 0x00B7
        SendMessage(EM_SCROLLCARET, 0, 0, this)
    }

    WasModified {
        get {
            static EM_GETMODIFY := 0x00B8
            return !!SendMessage(EM_GETMODIFY, 0, 0, this)
        }
        set {
            static EM_SETMODIFY := 0x00B9
            SendMessage(EM_SETMODIFY, !!value, 0, this)
        }
    }

    CurrentLine => EditGetCurrentLine(this)

    CurrentCol => EditGetCurrentCol(this)

    Line[N := EditGetCurrentLine(this)] {
        get => EditGetLine(N, this)
        ; TODO { set; }
    }

    LineLength[N] => StrLen(EditGetLine(N, this))

    LineIndex[Index := 0] {
        get {
            static EM_LINEINDEX := 0x00BB
            if (!IsInteger(Index)) {
                throw TypeError("Expected an Integer",, Type(Index))
            }
            return (SendMessage(EM_LINEINDEX, Index - 1, 0, this) + 1)
        }
    }

    Paste(Str) {
        EditPaste(Str, this)
    }

    Limit {
        ; TODO
        get {

        }
        set {
            if (!IsInteger(value)) {
                throw TypeError("Expected an Integer",, Type(value))
            }
            this.Opt("Limit" . value)
        }
    }

    CanUndo {
        get {
            static EM_CANUNDO := 0x00C6
            return SendMessage(EM_CANUNDO, 0, 0, this)
        }
    }

    Undo() {
        static EM_UNDO := 0x00C7
        return SendMessage(EM_UNDO, 0, 0, this)
    }

    ; TODO better name
    LineFromChar[Index := 0] {
        get {
            static EM_LINEFROMCHAR := 0x00C9
            if (!IsInteger(Index)) {
                throw TypeError("Expected an Integer",, Type(Index))
            }
            return (SendMessage(EM_LINEFROMCHAR, Index - 1, 0, this) + 1)
        }
    }

    EmptyUndoBuffer() {
        static EM_EMPTYUNDOBUFFER := 0x00CD
        SendMessage(EM_EMPTYUNDOBUFFER, 0, 0, this)
    }

    ; TODO make this better
    TabStops {
        set {
            if (!IsObject(value)) {
                value := StrSplit(value, ",", A_Space)
            }
            if (!(value is Array)) {
                throw TypeError("Expected a String or Array",, Type(value))
            }
            Opt := ""
            for TabStop in value {
                if (!IsInteger(TabStop)) {
                    throw TypeError("Expected an Integer",, Type(TabStop))
                }
                Opt .= " t" . TabStop
            }
            this.Opt(Opt)
        }
    }

    PasswordChar {
        get {
            static EM_GETPASSWORDCHAR := 0x00D2
            Char := SendMessage(EM_GETPASSWORDCHAR, 0, 0, this)
            if (Char != 0) {
                return Chr(Char)
            }
            return ""
        }
        set {
            static EM_SETPASSWORDCHAR := 0x00CC
            if (value == "") {
                value := 0
            }
            Char := Ord(value)
            SendMessage(EM_SETPASSWORDCHAR, Char, 0, this)
        }
    }

    ; TODO check if the edit control is one-line
    FirstVisibleCol {

    }

    FirstVisibleLine {
        get {
            static EM_GETFIRSTVISIBLELINE := 0x00CE
            return (SendMessage(EM_GETFIRSTVISIBLELINE, 0, 0, this) + 1)
        }
    }

    ReadOnly {
        ; TODO find out ES_READONLY
        get {
            return ControlGetStyle(this)
        }
        set {
            static EM_SETREADONLY := 0x00CF
            SendMessage(EM_SETREADONLY, !!value, 0, this)
        }
    }

    WordBreakProcedure {
        get {
    
        }
        set {
    
        }
    }

    LeftMargin {
        get {

        }
        set {

        }
    }

    RightMargin {
        get {

        }
        set {

        }
    }

    PosFromChar() {

    }

    CharFromPos() {

    }

    ImeStatus {

    }

    static Style => {
        Left:        0x0000,
        Center:      0x0001,
        Right:       0x0002,
        MultiLine:   0x0004,
        UpperCase:   0x0008,
        LowerCase:   0x0010,
        Password:    0x0021,
        AutoVScroll: 0x0040,
        AutoHScroll: 0x0080,
        NoHideSel:   0x0100,
        OEMConvert:  0x0400,
        ReadOnly:    0x0800,
        WantReturn:  0x1000,
        Number:      0x2000
    }

    MultiLine {
        get => (ControlGetStyle(this) & Gui.Edit.Style.MultiLine)
        set {
            (value) ? this.Style |=  Gui.Edit.Style.MultiLine
                    : this.Style &= ~Gui.Edit.Style.MultiLine
        }
    }

    ; TODO Styles
    ; TODO commctrl.h stuff like CueBanner...
}
