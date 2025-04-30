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
     * Returns an object that wraps around the selection of an edit control.
     * 
     * @return  {Gui.Edit.Selection}
     */
    Selection => Gui.Edit.Selection(this)

    /** An object used for the selection of an edit control. */
    class Selection {
        /**
         * Constructs a new Gui.Edit.Selection object.
         * 
         * @param   {Gui.Edit}  EditControl  the edit control to manage
         */
        __New(EditControl) {
            if (!(EditControl is Gui.Edit) && !(EditControl is GuiProxy.Edit)) {
                throw TypeError("Expected a Gui.Edit",, Type(EditControl))
            }
            this.DefineProp("Edit", { Get: (Instance) => EditControl })
        }

        /**
         * Returns the 1-based index of the first character in the selection.
         * 
         * @return  {Integer}
         */
        Start {
            get {
                Start := Buffer(A_PtrSize, 0)
                SendMessage(EM_GETSEL := 0x00B0, Start.Ptr, 0, this.Edit)
                return NumGet(Start, "UPtr") + 1
            }
        }

        /**
         * Returns the 1-based index of the last character in the selection.
         * 
         * @return  {Integer}
         */
        End {
            get {
                End := Buffer(A_PtrSize, 0)
                SendMessage(EM_GETSEL := 0x00B0, 0, End.Ptr, this.Edit)
                return NumGet(End, "UPtr")
            }
        }

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
        Set(Start, Length?) {
            static EM_SETSEL := 0x00B1

            if (!IsInteger(Start)) {
                throw TypeError("Expected an Integer",, Type(Start))
            }
            TotalLength := this.Edit.TextLength

            ; omitted `Length` --> until end of string (or length 0 + deselect)
            if (!IsSet(Length)) {
                Length := Max(0, TotalLength - Start + 1)
            }
            if (!IsInteger(Length)) {
                throw TypeError("Expected an Integer",, Type(Length))
            }

            if (Start == 0) {
                return this.Clear()
            }
            if (Length == 0) {
                SendMessage(EM_SETSEL, Start, Start, this.Edit)
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

            SendMessage(EM_SETSEL, Start, Stop, this.Edit)
            return this
        }

        /** Deselects all text in the edit control. */
        Clear() {
            static EM_SETSEL := 0x00B1
            SendMessage(EM_SETSEL, -1, -1, this)
            return this
        }

        /** Selects all text in the edit control. */
        All() {
            SendMessage(EM_SETSEL := 0x00B1, 0, -1, this)
        }

        /**
         * Returns the character length of the current selection.
         * 
         * @return  {Integer}
         */
        Length => this.End - this.Start

        /**
         * Returns the currently selected text.
         * 
         * @return  {String}
         */
        Text => EditGetSelectedText(this.Edit)
    }

    /**
     * Sent when the edit control receives the keyboard focus.
     * 
     * @example
     * Edit_Focus(EditControl) {
     * }
     * 
     * @param   {Func}      Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the function
     * @return  {Gui.Event}
     */
    OnFocus(Callback, AddRemove?) {
        static EN_SETFOCUS := 0x0100
        return Gui.Event.OnCommand(this, EN_SETFOCUS, Callback, AddRemove?)
    }

    /**
     * Sent when an edit control loses the keyboard focus.
     * 
     * @example
     * Edit_FocusLost(EditControl) {
     * }
     * 
     * @param   {Func}      Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the function
     * @return  {Gui.Event}
     */
    OnFocusLost(Callback, AddRemove?) {
        static EN_KILLFOCUS := 0x0200
        return Gui.Event.OnCommand(this, EN_KILLFOCUS, Callback, AddRemove?)
    }

    /**
     * Sent when the user has taken an action that may have altered text in
     * the edit control.
     * 
     * @param   {Func}      Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the function
     * @return  {Gui.Event}
     */
    OnChange(Callback, AddRemove?) {
        static EN_CHANGE := 0x0300
        return Gui.Event.OnCommand(this, EN_CHANGE, Callback, AddRemove?)
    }

    /**
     * Sent when an edit control is about to redraw itself.
     * 
     * @param   {Func}      Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the function
     * @return  {Gui.Event}
     */
    OnUpdate(Callback, AddRemove?) {
        static EN_UPDATE := 0x0400
        return Gui.Event.OnCommand(this, EN_UPDATE, Callback, AddRemove?)
    }

    /**
     * Send when the edit control cannot allocate enough memory to meet a
     * specific request.
     * 
     * @param   {Func}      Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the function
     * @return  {Gui.Event}
     */
    OnOutOfMemory(Callback, AddRemove?) {
        static EN_ERRSPACE := 0x0500
        return Gui.Event.OnCommand(this, EN_ERRSPACE, Callback, AddRemove?)
    }

    /**
     * Sent when the current text insertion has exceeded the specified number
     * of characters for the edit control.
     * 
     * @param   {Func}      Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the function
     * @return  {Gui.Event}
     */
    OnMaxText(Callback, AddRemove?) {
        static EN_MAXTEXT := 0x0501
        return Gui.Event.OnCommand(this, EN_MAXTEXT, Callback, AddRemove?)
    }

    /**
     * Sent when the user clicks the horizonal scroll bar.
     * 
     * @param   {Func}      Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the function
     * @return  {Gui.Event}
     */
    OnHScroll(Callback, AddRemove?) {
        static EN_HSCROLL := 0x0601
        return Gui.Event.OnCommand(this, EN_HSCROLL, Callback, AddRemove?)
    }

    /**
     * Sent when the user clicks the vertical scroll bar or when the user
     * scrolls the mouse wheel over the edit control.
     */
    OnVScroll(Callback, AddRemove?) {
        static EN_VSCROLL := 0x0602
        return Gui.Event.OnCommand(this, EN_VSCROLL, Callback, AddRemove?)
    }

    /**
     * Returns an object that retrieves information about the caret and changes
     * its position.
     * 
     * @return  {Gui.Edit.Caret}
     */
    Caret => Gui.Edit.Caret(this)

    /** An object that wraps around the caret of an edit control. */
    class Caret {
        /**
         * Constructs a new `Gui.Edit.Caret` object.
         * 
         * @param   {Gui.Edit}  EditControl  the edit control to manage
         */
        __New(EditControl) {
            if (!(EditControl is Gui.Edit) && !(EditControl is GuiProxy.Edit)) {
                throw TypeError("Expected a Gui.Edit",, Type(EditControl))
            }
            this.DefineProp("Edit", { Get: (Instance) => EditControl })
        }

        /**
         * Moves the caret to the specified line number and column.
         * 
         * @param   {Integer?}  Line    the new line number
         * @param   {Integer?}  Column  the new column
         */
        Move(Line := this.Line, Column := this.Column) {
            if (!IsInteger(Line) || !IsInteger(Column)) {
                throw TypeError("Expected an Integer",,
                                Type(Line) . " " . Type(Column))
            }

            Line   := Min(Max(1, Line), this.Edit.LineCount())
            Index  := this.Edit.LineIndex(Line)
            MaxLen := this.Edit.LineLength(Index)
            NewCol := Min(Max(1, Column), MaxLen + 1)

            this.Index := Index + NewCol - 1
        }

        /**
         * Scrolls the text vertically and horizontally. If both parameters are
         * omitted, scrolls the caret into view of the edit control.
         * 
         * - positive integer: down/right
         * - negative integer: up/left
         * 
         * If both parameters are omitted, scrolls into view of the caret.
         * 
         * @param   {Integer?}  UpDown     lines to move up/down
         * @param   {Integer?}  LeftRight  columns to scroll left/right
         */
        Scroll(UpDown := 0, LeftRight := 0) {
            if (!IsInteger(UpDown) || !IsInteger(LeftRight)) {
                throw TypeError("Expected an Integer",,
                                Type(UpDown) . " " . Type(LeftRight))
            }

            if ((UpDown == 0) && (LeftRight == 0)) {
                SendMessage(EM_SCROLLCARET := 0x00B7, 0, 0, this.Edit)
            }

            TotalLines := this.Edit.LineCount()
            NewLineNum := Min(Max(1, this.Line + UpDown), TotalLines)

            NewLineLen := this.Edit.LineLength(NewLineNum)
            NewColNum  := Min(Max(1, this.Column + LeftRight), NewLineLen)

            this.Index := this.Edit.LineIndex(NewLineNum) - 1 + NewColNum
        }

        /**
         * Retrieves and changes the current line in the edit control.
         * 
         * @param   {Integer}  value  the new line
         * @return  {Integer}
         */
        Line {
            get => EditGetCurrentLine(this.Edit)
            set {
                if (!IsInteger(value)) {
                    throw TypeError("Expected an Integer",, Type(value))
                }
                this.Move(value, this.Column)
            }
        }

        /**
         * Retrieves and changes the current column in the edit control.
         * 
         * @param   {Integer}  value  the new column
         * @return  {Integer}
         */
        Column {
            get {
                return EditGetCurrentCol(this.Edit)
            }
            set {
                if (!IsInteger(value)) {
                    throw TypeError("Expected an Integer",, Type(value))
                }
                this.Move(this.Line, value)
            }
        }

        /**
         * Retrieves the index of the caret or moves it to the specified
         * position.
         * 
         * @param   {Integer}  value  the new position to move caret to
         * @return  {Integer}
         */
        Index {
            get {
                static EM_GETCARETINDEX := 0x1512
                return (SendMessage(EM_GETCARETINDEX, 0, 0, this.Edit) + 1)
            }
            set {
                static EM_SETCARETINDEX := 0x1511
                return SendMessage(EM_SETCARETINDEX, value - 1, 0, this.Edit)
            }
        }
    }

    /**
     * Returns an object that wraps around the text area of the edit control.
     * 
     * @return  {Gui.Edit.TextArea}
     */
    TextArea => Gui.Edit.TextArea(this)

    /** An object that wraps around the text area of an edit control. */
    class TextArea {
        /**
         * Constructs a new `Gui.Edit.TextArea` object.
         * 
         * @param   {Gui.Edit}  EditControl  the edit control to manage
         */
        __New(EditControl) {
            if (!(EditControl is Gui.Edit) && !(EditControl is GuiProxy.Edit)) {
                throw TypeError("Expected a Gui.Edit",, Type(EditControl))
            }
            this.DefineProp("Edit", { Get: (Instance) => EditControl })
        }

        /**
         * Returns a `RECT` that contains the bounds of the text display area.
         * This area defines where text is rendered within the edit control and
         * can be modified using `.SetBounds(Rc, Absolute := false)`.
         * 
         * @return  {RECT}
         */
        GetBounds() {
            static EM_GETRECT := 0x00B2
            Rc := RECT()
            SendMessage(EM_GETRECT, 0, ObjGetDataPtr(Rc), this.Edit)
            return Rc
        }

        /**
         * Modifies the text `RECT` that contains the bounds the text display
         * area.
         * 
         * @param   {RECT/Array/String}  Rc        new RECT defining text bounds
         * @param   {Boolean?}           Relative  change relative to old RECT
         */
        SetBounds(Rc, Relative := false) {
            static EM_SETRECT   := 0x00B3

            Rc := RECT.Create(Rc)
            if (Relative) {
                OldRc := this.GetBounds()
                Rc.Left   += OldRc.Left
                Rc.Top    += OldRc.Top
                Rc.Right  += OldRc.Right
                Rc.Bottom += OldRc.Bottom
            }

            SendMessage(EM_SETRECT, !!Relative, ObjGetDataPtr(Rc), this.Edit)
            return this
        }
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
     * If `Logical` is set to `true`, "soft line breaks" caused by text wrapping
     * are ignored.
     * 
     * @param   {Boolean?}  Logical  ignore text wrapping
     * @return  {Integer}
     */
    LineCount(Logical := false) {
        static EM_GETLINECOUNT     := 0x00BA
        static EM_GETFILELINECOUNT := 0x1517

        Msg := (Logical) ? EM_GETFILELINECOUNT
                         : EM_GETLINECOUNT

        return SendMessage(Msg, 0, 0, this)
    }

    /**
     * Gets the character index of the first character of a specified line
     * in a multiline edit control.
     * 
     * If parameter `Index` is omitted, the current line is used.
     * 
     * The return value is `0` whenever the specified line number is out
     * of bounds.
     * 
     * If `Logical` is set to `true`, "soft line breaks" caused by text wrapping
     * are ignored.
     * 
     * @param   {Integer?}  Index    1-based line number
     * @param   {Boolean?}  Logical  ignore text wrapping
     * @return  {Integer}
     */
    LineIndex(Index := EditGetCurrentLine(this), Logical := false) {
        static EM_LINEINDEX     := 0x00BB
        static EM_FILELINEINDEX := 0x1514

        if (!IsInteger(Index)) {
            throw TypeError("Expected an Integer",, Type(Index))
        }
        Msg := (Logical) ? EM_FILELINEINDEX
                         : EM_LINEINDEX
        return (SendMessage(Msg, Index - 1, 0, this) + 1) << 32 >> 32
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
     * are ignored.
     * 
     * @param   {Integer?}  Index    1-based line number
     * @param   {Boolean?}  Logical  ignore text wrapping
     * @return  {Integer}
     */
    LineLength(Index := EditGetCurrentLine(this), Logical := false) {
        static EM_LINELENGTH     := 0x00C1
        static EM_FILELINELENGTH := 0x1515
        
        if (!IsInteger(Index)) {
            throw TypeError("Expected an Integer",, Type(Index))
        }
        Msg := (Logical) ? EM_FILELINELENGTH
                         : EM_LINELENGTH

        return SendMessage(Msg, Index - 1, 0, this)
    }

    /**
     * Pastes the specified string at the caret (text insertion point) in the
     * edit control.
     * 
     * @param   {String}  Str  the string to insert
     */
    Paste(Str) => EditPaste(Str, this)

    /**
     * Returns the text of the specified line in the edit control. If `N` is
     * omitted, the current line will be returned.
     * 
     * If `Logical` is set to `true`, "soft line breaks" caused by text wrapping
     * are ignored.
     * 
     * @param   {Integer?}  Index    1-based line number
     * @param   {Boolean}   Logical  ignore text wrapping
     * @return  {String}
     */
    Line(Index := EditGetCurrentLine(this), Logical := false) {
        static EM_GETFILELINE := 0x1516
        
        if (!IsInteger(Index)) {
            throw TypeError("Expected an Integer",, Type(Index))
        }
        if (!Logical) {
            return EditGetLine(Index, this)
        }

        Length := this.LineLength(Index, true)
        VarSetStrCapacity(&Result, Length)
        SendMessage(EM_GETFILELINE, Index - 1, StrPtr(Result), this)
        VarSetStrCapacity(&Result, -1)

        return Result
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
     * in a multiline edit control.
     * 
     * If `Index` is omitted, the current line is used.
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
    LineFromChar(Index := EditGetCurrentLine(this), Logical := false) {
        static EM_LINEFROMCHAR     := 0x00C9
        static EM_FILELINEFROMCHAR := 0x1513

        if (!IsInteger(Index)) {
            throw TypeError("Expeced an Integer",, Type(Index))
        }
        Msg := (Logical) ? EM_FILELINEFROMCHAR
                         : EM_LINEFROMCHAR

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
     * Returns an object that controls the margins of an edit control.
     * 
     * @return  {Gui.Edit.TextMargin}
     */
    TextMargin => Gui.Edit.TextMargin(this)

    /** An object that controls the margins of an edit control. */
    class TextMargin {
        /**
         * Constructs a new Gui.Edit.Margin object.
         * 
         * @param   {Gui.Edit}  EditControl  the edit control to manage
         */
        __New(EditControl) {
            if (!(EditControl is Gui.Edit) && !(EditControl is GuiProxy.Edit)) {
                throw TypeError("Expected a Gui.Edit",, Type(EditControl))
            }
            this.DefineProp("Edit", { Get: (Instance) => EditControl })
        }

        /**
         * Retrieves and changes the left margin of the edit control.
         * 
         * @param   {Integer}  value  the new left margin in pixels
         * @return  {Integer}
         */
        Left {
            get {
                static EM_GETMARGINS := 0x00D4
                Result := SendMessage(EM_GETMARGINS, 0, 0, this.Edit)
                return Result & 0xFFFF
            }
            set {
                static EM_SETMARGINS := 0x00D3
                static EM_LEFTMARGIN := 0x0001
                static EC_USEFONT    := 0xFFFF

                if (!IsInteger(value)) {
                    throw TypeError("Expected an Integer",, Type(value))
                }
                wParam := EM_LEFTMARGIN
                lParam := value
                if (lParam == -1) {
                    lParam := EC_USEFONT
                }
                lParam := Min(Max(lParam, 0), 0xFFFF)
                SendMessage(EM_SETMARGINS, wParam, lParam, this.Edit)
            }
        }

        /**
         * Retrieves and changes the right margin of the edit control.
         * 
         * @param   {Integer}  value  the new right margin in pixels
         * @return  {Integer}
         */
        Right {
            get {
                static EM_GETMARGINS := 0x00D4
                Result := SendMessage(EM_GETMARGINS, 0, 0, this.Edit)
                return (Result >> 16) & 0xFFFF
            }
            set {
                static EM_SETMARGINS   := 0x00D3
                static EM_RIGHTMARGIN  := 0x0002
                static EC_USEFONT      := 0xFFFF

                if (!IsInteger(value)) {
                    throw TypeError("Expected an Integer",, Type(value))
                }
                wParam := EM_RIGHTMARGIN
                lParam := value
                if (lParam == -1) {
                    lParam := EC_USEFONT
                }
                lParam := Min(Max(lParam, 0), 0xFFFF) << 16
                SendMessage(EM_SETMARGINS, wParam, lParam, this.Edit)
            }
        }
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
            if (!(EditControl is Gui.Edit) && !(EditControl is GuiProxy.Edit)) {
                throw TypeError("Expected a Gui.Edit",, Type(EditControl))
            }
            this.DefineProp("Edit", { Get: (Instance) => EditControl })
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
     * Sets the removes the multi-line style of the edit control.
     * 
     * @param   {Boolean}  value  whether to set or remove the style
     * @return  {Boolean}
     */
    MultiLine {
        get => !!(ControlGetStyle(this) | Gui.Edit.Style.MultiLine)
        set {
            (value) ? (this.Style |=  Gui.Edit.Style.MultiLine)
                    : (this.Style &= ~Gui.Edit.Style.MultiLine)
        }
    }

    /**
     * Gets the text that is displayed as a textual core, or tip, in the edit
     * control.
     * 
     * @param   {Integer?}  MaxCap  maximum string capacity of the cue
     * @return  {String}
     */
    GetCue(MaxCap := 128) {
        static EM_GETCUEBANNER := 0x1502
        static MinCap          := 64

        Buf := Buffer(Max(MinCap, MaxCap))
        SendMessage(EM_GETCUEBANNER, Buf.Ptr, Buf.Size, this)
        VarSetStrCapacity(&Str, -1) 

        return StrGet(Buf, "UTF-16")
    }

    /**
     * Sets the text that is displayed as a textual core, or tip, in the edit
     * control.
     * 
     * @param   {String?}   Str              the string to display
     * @param   {Boolean?}  ShowWhenFocused  display while keyboard has focus
     */
    SetCue(Str, ShowWhenFocused := false) {
        static EM_SETCUEBANNER := 0x1501
        if (IsObject(Str)) {
            throw TypeError("Expected a String",, Type(Str))
        }
        SendMessage(EM_SETCUEBANNER, !!ShowWhenFocused, StrPtr(Str), this)
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
     * 
     * TODO doesn't work externally
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
         * @param   {Gui.Edit}  EditControl  edit control to manage
         * @return  {Gui.Edit.BalloonTip}
         */
        __New(EditControl) {
            if (!(EditControl is Gui.Edit) && !(EditControl is GuiProxy.Edit)) {
                throw TypeError("Expected a Gui.Edit",, Type(EditControl))
            }
            this.DefineProp("Edit", { Get: (Instance) => EditControl })
        }

        /**
         * Shows a balloon tip in the edit control.
         * 
         * @param   {String?}   Text   the text to display
         * @param   {String?}   Title  title of the balloon tip
         * @param   {Integer?}  Icon   a ToolTip icon (see `static Icon`)
         */
        Show(Text := "", Title := "", Icon := Gui.Edit.BalloonTip.Icon.None) {
            static EM_SHOWBALLOONTIP := 0x1503

            if (IsObject(Title) || IsObject(Text)) {
                throw TypeError("Expected a String",,
                                Type(Title) . " " . Type(Text))
            }
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
     * input.
     * 
     * @param   {Boolean}  value  whether to allow focus
     */
    AllowInput {
        set {
            static EM_NOSETFOCUS := 0x1507
            static EM_TAKEFOCUS  := 0x1508
            SendMessage((value) ? EM_TAKEFOCUS : EM_NOSETFOCUS, 0, 0, this)
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

    /**
     * Retrieves and changes the new line character of the edit control.
     * 
     * - `0`: auto
     * - `1`: `\r\n`
     * - `2`: `\r`
     * - `3`: `\n`
     * 
     * @param   {Integer}  value  the new EOL character
     * @return  {Integer}
     */
    EndOfLine {
        get {
            static EM_GETENDOFLINE := 0x150D
            return SendMessage(EM_GETENDOFLINE, 0, 0, this)
        }
        set {
            static EM_SETENDOFLINE := 0x150C
            SendMessage(EM_SETENDOFLINE, value, 0, this)
        }
    }

    /**
     * Registers a function or method to be called when the user performs a
     * "Search with Bing..." action.
     * 
     * - `FromContextMenu`: {boolean} event comes from the context menu
     * - `HasQuery`:        {boolean} text was selected
     * - `Success`:         {boolean} search was successful
     * 
     * @example
     * 
     * Callback(EditControl, EntryPoint, HasQuery, Success)
     * 
     * @param   {Callback}  Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the event
     */
    OnWebSearch(Callback, AddRemove?) {
        static EN_SEARCHWEB := -1520
        return Gui.Event.OnNotify(this, EN_SEARCHWEB,
                                  WebSearch, AddRemove?)

        WebSearch(EditControl, lParam) {
            Notif := StructFromPtr(NMSEARCHWEB, lParam)
            Callback(EditControl,
                     Notif.EntryPoint,
                     Notif.hasQueryText,
                     Notif.InvokeSucceeded)
        }
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
            if (!(EditControl is Gui.Edit) && !(EditControl is GuiProxy.Edit)) {
                throw TypeError("Expected a Gui.Edit",, Type(EditControl))
            }
            this.DefineProp("Edit", { Get: (Instance) => EditControl })
        }
        
        /**
         * Performs a web search with Bing, using the current selection in the
         * edit control (if any).
         * 
         * To activate this feature, using `.WebSearch.Enable()` first.
         */
        Call(*) {
            static EM_SEARCHWEB := 0x150F
            SendMessage(EM_SEARCHWEB, 0, 0, this.Edit)
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
    }
}