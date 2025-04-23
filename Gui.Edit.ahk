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
     * @return  {Object}
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
        return Theme
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

        if (Start == 0) {
            return this.Deselect()
        }
        if (Length == 0) {
            SendMessage(EM_SETSEL, Start, Start, this)
            return this
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

    /**
     * Selects all the text inside of the edit control.
     * 
     * @return  {this}
     */
    SelectAll() {
        static EM_SETSEL := 0x00B1
        SendMessage(EM_SETSEL, 0, -1, this)
        return this
    }

    /**
     * Deselects any selected text in the edit control.
     * 
     * @return  {this}
     */
    Deselect() {
        static EM_SETSEL := 0x00B1
        SendMessage(EM_SETSEL, -1, -1, this)
        return this
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

    ; TODO Scrolling with LINESCROLL doesnt work

    /**
     * 
     */
    Scroll(UpDown := 0, LeftRight := 0) {
        static EM_SCROLL     := 0x00B5
        static EM_LINESCROLL := 0x00B6

        static SB_LINEUP   := 0x0000
        static SB_LINEDOWN := 0x0001
        static SB_PAGEUP   := 0x0002
        static SB_PAGEDOWN := 0x0003

        SendMessage(EM_LINESCROLL, UpDown, LeftRight, this)
    }

    /**
     * 
     */
    ScrollLines(Count) {
        ; TODO how do I summarize these?
        static EM_SCROLL   := 0x00B5

        static SB_LINEUP   := 0x0000
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
        ; TODO how do I summarize these?
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

    /**
     * Scrolls the caret into view of the edit control.
     * 
     * @return  {this}
     */
    ScrollCaret() {
        static EM_SCROLLCARET := 0x00B7
        SendMessage(EM_SCROLLCARET, 0, 0, this)
        return this
    }

    /**
     * Retrieves or sets the modification flag for the edit control. The
     * modification flag indicates whether the text within the edit control
     * has been modified.
     * 
     * @param   {Boolean}  value  the new value for the modification flag
     * @return  {Boolean}
     */
    WasModified {
        get {
            static EM_GETMODIFY := 0x00B8
            return !!SendMessage(EM_GETMODIFY, 0, 0, this)
        }
        set {
            static EM_SETMODIFY := 0x00B9
            SendMessage(EM_SETMODIFY, !!value, -1, this)
        }
    }

    /**
     * Returns the number of lines in the edit control.
     * 
     * @return  {Integer}
     */
    LineCount(Logical := false) {
        static EM_GETLINECOUNT     := 0x00BA
        static EM_GETFILELINECOUNT := 0x1517

        return EditGetLineCount(this)
        ; TODO
    }

    /**
     * Gets the character index of the first character of a specified line
     * in a multiline edit control.
     * 
     * If parameter `Index` is omitted or `0`, the first character index of
     * the current line is returned.
     * 
     * Similar to `SubStr()`, negative index start from the end of the string.
     * 
     * The return value is `0` whenever the specified line number is out
     * of bounds.
     * 
     * If `Logical` is set to `true`, "soft line breaks" caused by text wrapping
     * are not counted.
     * 
     * @param   {Integer?}  Index    1-based line number
     * @param   {Boolean?}  Logical  ignore text wrapping
     * @return  {Integer}
     */
    LineIndex(Index := 0, Logical := false) {
        static EM_LINEINDEX     := 0x00BB
        static EM_FILELINEINDEX := 0x1514

        if (!IsInteger(Index)) {
            throw TypeError("Expected an Integer",, Type(Index))
        }
        if (Index < 0) {
            Index += this.LineCount
        }
        Msg := (Logical) ? EM_LINEINDEX
                         : EM_FILELINEINDEX
        return (SendMessage(Msg, Index, 0, this) + 1) << 32 >> 32
    }

    /**
     * Retrieves the length in characters of a line in the edit control.
     * 
     * If parameter `N` is omitted, the current line will be used.
     * 
     * If parameter `N` is set to `0`, the number of unselected characters
     * on lines containing selected characters are returned.
     * 
     * - https://learn.microsoft.com/en-us/windows/win32/controls/em-linelength
     * 
     * If `Logical` is set to `true`, "soft line breaks" caused by text wrapping
     * are not counted.
     * 
     * @param   {Integer?}  N        1-based line number
     * @param   {Boolean?}  Logical  ignore text wrapping
     * @return  {Integer}
     */
    LineLength(N := this.CurrentLine, Logical := false) {
        static EM_LINELENGTH     := 0x00C1
        static EM_FILELINELENGTH := 0x1515
        
        Msg := (Logical) ? EM_LINELENGTH
                         : EM_FILELINELENGTH

        return SendMessage(Msg, N - 1, 0, this)
    }

    /**
     * Pastes the specified string at the caret (text insertion point) in the
     * edit control.
     * 
     * @param   {String}  Str  the string to insert
     */
    Paste(Str) => EditPaste(Str, this)

    /**
     * Returns the text of the specified line in the edit control.
     * 
     * @param   {Integer}  1-based line number
     * @return  {String}
     */
    Line(N := this.CurrentLine, Logical := false) {
        return EditGetLine(N, this)
        ; TODO
    }

    /**
     * Determines whether there are any actions in the edit control's undo
     * queue.
     * 
     * @return  {Boolean}
     */
    CanUndo {
        get {
            static EM_CANUNDO := 0x00C6
            return SendMessage(EM_CANUNDO, 0, 0, this)
        }
    }

    /**
     * Undoes the last edit control operation.
     * 
     * @return  {Boolean}
     */
    Undo() {
        static EM_UNDO := 0x00C7
        return SendMessage(EM_UNDO, 0, 0, this)
    }

    /**
     * Gets the index of the line that contains the specified character index
     * in a multiline edit control. If `Index` is omitted or `0`, the current
     * line is used, or if there is a selection, the line number of the line
     * containing the beginning of the selection.
     * 
     * If the character index exceeds the length of the string, the last line
     * number is returned.
     * 
     * If `Logical` is set to `true`, "soft line breaks" caused by text wrapping
     * are ignored.
     * 
     * @param   {Integer?}  Index    1-based character index
     * @param   {Boolean?}  Logical  ignore text wrapping
     * @return  {Integer}
     */
    LineFromChar(Index := 0, Logical := true) {
        static EM_LINEFROMCHAR     := 0x00C9
        static EM_FILELINEFROMCHAR := 0x1513

        if (!IsInteger(Index)) {
            throw TypeError("Expeced an Integer",, Type(Index))
        }
        Msg := (Logical) ? EM_LINEFROMCHAR
                         : EM_FILELINEFROMCHAR
        return (SendMessage(Msg, Index - 1, 0, this) + 1)
    }

    /**
     * Sets the tab stops in a multiline edit control. Any tab character in the
     * text causes space to be generated up to the next tab stop.
     * 
     * @param   {String/Array}  value  the new tab stops
     */
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

    /**
     * Gets and retrieves the character used for the password option.
     * 
     * @param   {String}  value  the new character to use (or empty string)
     * @return  {String}
     */
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

    /**
     * Resets the undo flag of the edit control, which is set whenever an
     * operation within the edit control can be undone. 
     */
    EmptyUndoBuffer() {
        static EM_EMPTYUNDOBUFFER := 0x00CD
        SendMessage(EM_EMPTYUNDOBUFFER, 0, 0, this)
    }

    /**
     * Retrieves the 1-based line number of the current line.
     * 
     * @return  {Integer}
     */
    CurrentLine => EditGetCurrentLine(this)

    /**
     * Retrieves the 1-based index of the current column.
     * 
     * @return  {Integer}
     */
    CurrentCol => EditGetCurrentCol(this)

    /**
     * Gets the 1-based index of the uppermost visible line in a multiline edit
     * control. For single-line edit controls, the return value is the 1-based
     * index of the first visible character.
     * 
     * @return  {Integer}
     */
    FirstVisibleLine {
        get {
            static EM_GETFIRSTVISIBLELINE := 0x00CE
            return (SendMessage(EM_GETFIRSTVISIBLELINE, 0, 0, this) + 1)
        }
    }

    /**
     * Sets or removes the read-only style of the edit control.
     * 
     * @param   {Boolean}  value  whether to set or remove the style
     * @return  {Boolean}
     */
    ReadOnly {
        get => !!(ControlGetStyle(this) | Gui.Edit.Style.ReadOnly)
        set {
            static EM_SETREADONLY := 0x00CF
            SendMessage(EM_SETREADONLY, !!value, 0, this)
        }
    }

    /**
     * Gets the widths of the left and right margins for an edit control, which
     * are returned of an object with properties `Left` and `Right`.
     * 
     * @return  {Object}
     */
    GetMargins() {
        static EM_GETMARGINS := 0x00D4

        Result := SendMessage(EM_GETMARGINS, 0, 0, this)
        return {
            Left:  (Result      ) & 0xFFFF,
            Right: (Result >> 16) & 0xFFFF
        }
    }

    /**
     * Sets the widths of the left and right margins for an edit control.
     * The control is redrawn to reflect the new margins.
     * 
     * Using the special value `-1` in any of the two parameters causes that
     * margin to be calculated using the text metrics of the current font.
     * 
     * @param   {Integer?}  Left   width of the left margin in pixels
     * @param   {Integer?}  Right  width of the right margin in pixels
     */
    SetMargins(Left?, Right?) {
        static EM_SETMARGINS  := 0x00D3

        static EC_LEFTMARGIN  := 0x0001
        static EC_RIGHTMARGIN := 0x0002
        static EC_USEFONT     := 0xFFFF

        wParam := 0
        lParam := 0
        if (IsSet(Left)) {
            if (Left == -1) {
                Left := 0xFFFF
            }
            wParam |= EC_LEFTMARGIN
            lParam |= (Left & 0xFFFF)
        }
        if (IsSet(Right)) {
            if (Right == -1) {
                Right := 0xFFFF
            }
            wParam |= EC_RIGHTMARGIN
            lParam |= (Right & 0xFFFF) << 16
        }

        SendMessage(EM_SETMARGINS, wParam, lParam, this)
    }

    /**
     * Gets and sets the text limit for the edit control.
     * 
     * @param   {Integer}  value  maximum amount of characters
     * @return  {Integer}
     */
    Limit {
        get {
            static EM_GETLIMITTEXT := 0x00D5
            return SendMessage(EM_GETLIMITTEXT, 0, 0, this)
        }
        set {
            if (!IsInteger(value)) {
                throw TypeError("Expected an Integer",, Type(value))
            }
            this.Opt("Limit" . value)
        }
    }

    /**
     * Returns an object that manages the text alignment of the edit control
     * 
     * @return  {Gui.Edit.Align}
     */
    Align => Gui.Edit.Align(this)

    /** An object that manages the text alignment of the edit control. */
    class Align {
        /**
         * Creates a new Edit.Align object.
         * 
         * @param   {Gui.Edit}  EditControl  the edit to be aligned
         */
        __New(EditControl) {
            if (!(EditControl is Gui.Edit)) {
                throw TypeError("Expected a Gui.Edit",, Type(EditControl))
            }
            this.DefineProp("Edit", {
                Get: (Instance) => EditControl
            })
        }

        /** Aligns the text on the left. */
        Left() {
            this.Edit.Style &= ~0x0003
            this.Edit.Style |= Gui.Edit.Style.Left
        }

        /** Aligns the text on the right. */
        Right() {
            this.Edit.Style &= ~0x0003
            this.Edit.Style |= Gui.Edit.Style.Right
        }

        /** Aligns the text in the center. */
        Center() {
            this.Edit.Style &= ~0x0003
            this.Edit.Style |= Gui.Edit.Style.Center
        }
    }

    /** All edit control styles. */
    class Style {
        static Left        => 0x0000
        static Center      => 0x0001
        static Right       => 0x0002
        static MultiLine   => 0x0004
        static UpperCase   => 0x0008
        static LowerCase   => 0x0010
        static Password    => 0x0020
        static AutoVScroll => 0x0040
        static AutoHScroll => 0x0080
        static NoHideSel   => 0x0100
        static OEMConvert  => 0x0400
        static ReadOnly    => 0x0800
        static WantReturn  => 0x1000
        static Number      => 0x2000
    }

    /**
     * 
     */
    MultiLine {
        get => !!(ControlGetStyle(this) & Gui.Edit.Style.MultiLine)
        set {
            (value) ? this.Style |=  Gui.Edit.Style.MultiLine
                    : this.Style &= ~Gui.Edit.Style.MultiLine
        }
    }

    ; TODO Styles

    /**
     * Gets the text that is displayed as a textual core, or tip, in the edit
     * control.
     * 
     * @param   {Integer?}  MaxCap  maximum string capacity of the cue
     * @return  {String}
     */
    GetCue(MaxCap := 128) {
        ; TODO can you use "GETTEXTLENGTH?"
        static EM_GETCUEBANNERTEXT := 0x1501

        MinCap := 64
        Cap := VarSetStrCapacity(&Str, Max(MinCap, MaxCap))
        SendMessage(EM_GETCUEBANNERTEXT, StrPtr(Str), Cap)
        VarSetStrCapacity(&Str,-1) 
        return Str
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
        class Icon {
            static None         => 0
            static Info         => 1
            static Warning      => 2
            static Error        => 3
            static InfoLarge    => 4
            static WarningLarge => 5
            static ErrorLarge   => 6
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
            this.DefineProp("Edit", {
                Get: (Instance) => EditCtl
            })
        }

        /**
         * Shows a balloon tip in the edit control.
         * 
         * @param   {String?}   Title  title of the balloon tip
         * @param   {String?}   Text   the text to display
         * @param   {Integer?}  Icon   a ToolTip icon (see `static Icon`)
         */
        Show(Title := "", Text := "", Icon := Gui.Edit.BalloonTip.None) {
            static EM_SHOWBALLOONTIP := 0x1503

            if (IsObject(Title) || IsObject(Text)) {
                throw TypeError("Expected a String",,
                                Type(Title) . " " . Type(Text))
            }
            if (!IsObject(Icon))
            this.pszTitle := StrPtr(Title)
            this.pszText  := StrPtr(Text)
            this.ttiIcon  := Icon

            SendMessage(EM_SHOWBALLOONTIP, 0, ObjGetDataPtr(this), this.Edit)
        }

        /** Hides the balloon tip. */
        Hide() {
            static EM_HIDEBALLOONTIP := 0x1504
            SendMessage(EM_HIDEBALLOONTIP, 0, 0, this.Edit)
        }
    }

    /**
     * Allows and prevents a single-line edit control from receiving keyboard
     * focus.
     */
    AllowFocus {
        set {
            static EM_NOSETFOCUS := 0x1507
            static EM_TAKEFOCUS  := 0x1508

            Msg := (value) ? EM_TAKEFOCUS
                           : EM_NOSETFOCUS

            SendMessage(Msg, 0, 0, this)
        }
    }

    /** All extended edit control styles. */
    class ExStyle {
        static AllowCR        => 0x0001
        static AllowLF        => 0x0002
        static AllowAll       => 0x0003
        static ConvertOnPaste => 0x0004
        static Zoomable       => 0x0010
    }

    /** Retrieves and changes the new line character of the edit control. */
    EndOfLine {
        get {
            static EM_GETENDOFLINE := 0x150D
            ; TODO
        }
        set {
            static EM_SETENDOFLINE := 0x150C
            ; TODO
        }
    }

    /** An enum of newline characters for use with the `EndOfLine` property. */
    class EndOfLine {
        static Auto => 0x0000
        static CRLF => 0x0001
        static CR   => 0x0002
        static LF   => 0x0003
    }

    /**
     * Returns an object that manages the "Search with Bing..." feature of the
     * edit control.
     * 
     * @return   {Gui.Edit.WebSearch}
     */
    WebSearch => Gui.Edit.WebSearch(this)

    /** An object that manages the "Search with Bing..." feature. */
    class WebSearch {
        /**
         * Creates a new Edit.WebSearch object.
         * 
         * @param   {Gui.Edit}  EditControl  the edit control to manage
         */
        __New(EditControl) {
            if (!(EditControl is Gui.Edit)) {
                throw TypeError("Expected a Gui.Edit",, Type(EditControl))
            }
            this.DefineProp("Edit", {
                Get: (Instance) => EditControl
            })
        }

        /** Enables the "Search with Bing..." feature. */
        Enable() {
            static EM_ENABLESEARCHWEB := 0x150E
            SendMessage(EM_ENABLESEARCHWEB, true, 0, this.Edit)
        }

        /** Disables the "Search with Bing..." feature. */
        Disable() {
            static EM_ENABLESEARCHWEB := 0x150E
            SendMessage(EM_ENABLESEARCHWEB, false, 0, this.Edit)
        }

        /** Performs a search with Bing using the current selection. */
        Search() {
            static EM_SEARCHWEB := 0x150F
            SendMessage(EM_SEARCHWEB, 0, 0, this.Edit)
        }
    }

    /**
     * Retrieves the index of the caret or moves it to the specified position.
     * 
     * @param   {Integer}  value  the new position to move caret to
     * @return  {Integer}
     */
    CaretIndex {
        get {
            static EM_GETCARETINDEX := 0x1512
            return (SendMessage(EM_GETCARETINDEX, 0, 0, this) + 1)
        }
        set {
            static EM_SETCARETINDEX := 0x1511
            return SendMessage(EM_SETCARETINDEX, value - 1, 0, this)
        }
    }

    /**
     * Returns an object that manages the zoom of the edit control.
     * 
     * @return  {Gui.Edit.Zoom}
     */
    Zoom => Gui.Edit.Zoom(this)

    /** An object that manages zooming of the edit control. */
    class Zoom {
        /**
         * Creates a new Gui.Edit.Zoom object.
         * 
         * @param   {Gui.Edit}  EditControl  the edit control to manage
         */
        __New(EditControl) {
            if (!(EditControl is Gui.Edit)) {
                throw TypeError("Expected a Gui.Edit",, Type(Edt))
            }
            this.DefineProp("Edit", {
                Get: (Instance) => EditControl
            })
        }

        /** Enables the zoom extended style of the edit control. */
        Enable() {
            this.Edit.ExStyle |= Gui.Edit.ExStyle.Zoomable
        }

        /** Disables the zoom extended style of the edit control. */
        Disable() {
            this.Edit.ExStyle &= Gui.Edit.ExStyle.Zoomable
        }

        /**
         * Grows the text by the given percentage.
         * 
         * @param   {Integer?}  Percent  percentage to grow
         */
        In(Percent := 10) {
            this.Set(this.Get() * (100 - Percent) / 100)
        }

        /**
         * Shrinks the text by the given percentage.
         * 
         * @param   {Integer?}  Percent  percentage to shrink
         */
        Out(Percent := 10) {
            this.Set(this.Get() * (100 + Percent) / 100)
        }
        
        /**
         * Gets the current size in the form of a float number.
         * 
         * @return  {Number}
         */
        Get() {
            ; TODO doesnt work
            static EM_GETZOOM := 0x0400 + 224

            Numer := Buffer(A_PtrSize, 0)
            Denom := Buffer(A_PtrSize, 0)
            SendMessage(EM_GETZOOM, Numer.Ptr, Denom.Ptr, this.Edit)
            Numer := NumGet(Numer, "UPtr")
            Denom := NumGet(Denom, "UPtr")
            return Numer / Denom
        }
        
        /**
         * Sets the scaling of the text to a certain size
         */
        Set(Ratio) {
            ; TODO doesn't work
            static EM_SETZOOM := 0x0400 + 225

            Ratio := Round(Ratio, 4)
            Numer := Integer(Ratio * 10000)
            Denom := 10000
            SendMessage(EM_SETZOOM, Numer, Denom, this.Edit)
        }

        /**
         * Resets the scaling of the text to its original size (100%).
         */
        Reset() => this.Set(1)
    }

    ; TODO notif messages?
}