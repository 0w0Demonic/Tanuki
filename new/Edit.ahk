#Include <AquaHotkey>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\Apis>
#Include <AhkWin32Projection\Windows\Win32\Foundation\RECT>
#Include <AhkWin32Projection\Windows\Win32\Storage\FileSystem\TRANSACTION_NOTIFICATION_RECOVERY_ARGUMENT>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\EDITBALLOONTIP>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\EDITBALLOONTIP_ICON>
#Include <AhkWin32Projection\Windows\Win32\Devices\DeviceAndDriverInstallation\FILE_IN_CABINET_INFO_W>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\ENABLE_SCROLL_BAR_ARROWS>

/**
 * Introduces functionality for handling selections in edit controls.
 */
class Tanuki_Edit extends AquaHotkey_MultiApply {
    static __New() => super.__New(Gui.Edit)

    ;@region General
    /**
     * Returns the text of the specified line in the edit control.
     * 
     * @param   {Integer}  N
     * @returns {String}
     */
    Line[N := EditGetCurrentLine(this)] => EditGetLine(N, this)

    /**
     * Returns the number of lines in the edit control.
     * 
     * @returns {Integer}
     */
    LineCount => EditGetLineCount(this)

    /**
     * Returns the column number in the edit control where the caret resides.
     * 
     * @returns {Integer}
     */
    CurrentCol => EditGetCurrentCol(this)

    /**
     * Returns the line number in the edit control where the caret resides.
     * 
     * @returns {Integer}
     */
    CurrentLine => EditGetCurrentLine(this)

    /**
     * Returns the selected text in the edit control.
     * 
     * @returns {String}
     */
    SelectedText => EditGetSelectedText(this)

    /**
     * Pastes the specified string at the caret in the edit control.
     * 
     * @param   {String}
     */
    Paste(Str) => EditPaste(Str, this)
    ;@endregion

    ;@region Selection
    /**
     * Returns a `Gui.Edit.Select` that wraps around the selection of an
     * edit control.
     */
    Selection => Gui.Edit.Selection(this)

    /**
     * Class that wraps around the selection of an edit control.
     */
    class Selection {
        /**
         * Creates a new selection object for the given edit control.
         * 
         * @param   {Gui.Edit}  EditControl  the edit control
         */
        __New(EditCtl) {
            if (!(EditCtl is Gui.Edit)) {
                throw TypeError("Expected a Gui.Edit",, Type(EditCtl))
            }
            this.DefineProp("Edit", { Get: (_) => EditCtl })
        }

        /**
         * Returns the 1-based index of the first character in the selection.
         * @returns {Integer}
         */
        Start {
            get {
                Buf := Buffer(A_PtrSize, 0)
                SendMessage(Controls.EM_GETSEL, Buf.Ptr, 0, this.Edit)
                return NumGet(Buf, "UPtr") + 1
            }
        }

        /**
         * Returns the 1-based index of the last character in the selection.
         * @returns {Integer}
         */
        End {
            get {
                Buf := Buffer(A_PtrSize, 0)
                SendMessage(Controls.EM_GETSEL, 0, Buf.Ptr, this.Edit)
                return NumGet(Buf, "UPtr")
            }
        }

        /**
         * Returns the character length of the current selection
         * @returns {Integer}
         */
        Length => (this.End - this.Start + 1)

        /**
         * Returns the currently selected text.
         * @returns {String}
         */
        Text => EditGetSelectedText(this.Edit)

        /**
         * Selects a range of characters in the edit control.
         * 
         * If the user uses the `Shift` key, the anchor point remains the same.
         * Parameters behave exactly as you'd expect from `SubStr()`.
         * 
         * To select all text, use `.SelectAll()`. To deselect, use `.Clear()`.
         * 
         * @param   {Integer}  Start   1-based start index
         * @param   {Integer?} Length  string length (default 1)
         * @returns {this}
         */
        Set(Start, Length?) {
            if (!IsInteger(Start)) {
                throw TypeError("Expected an Integer",, Type(Start))
            }
            TotalLength := SendMessage(WindowsAndMessaging.WM_GETTEXTLENGTH,
                                       0, 0, this.Edit)
                                       
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
                SendMessage(Controls.EM_SETSEL, Start, Start, this.Edit)
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

            SendMessage(Controls.EM_SETSEL, Start, Stop, this.Edit)
            return this
        }

        /**
         * Selects all text in the edit control.
         * @returns {this}
         */
        SelectAll() {
            SendMessage(Controls.EM_SETSEL, 0, -1, this)
            return this
        }

        /**
         * Deselects all text in the edit control.
         * @returns {this}
         */
        Clear() {
            SendMessage(Controls.EM_SETSEL, -1, -1, this)
            return this
        }
    }
    ;@endregion

    ;@region Undo
    /**
     * Gets and sets the state of a flag indicating whether the contents of the
     * edit control have been modified.
     * 
     * @param   {Boolean}  value  the new value
     * @returns {Boolean}
     */
    WasModified {
        get => !!SendMessage(Controls.EM_GETMODIFY, 0, 0, this)
        set => SendMessage(Controls.EM_SETMODIFY, !!value, 0, this)
    }

    /**
     * Determines whether there are any actions in the edit control's undo
     * queue.
     * 
     * @returns {Boolean}
     */
    CanUndo => !!SendMessage(Controls.EM_CANUNDO, 0, 0, this)

    /**
     * Resets the undo flag of the edit control.
     */
    EmptyUndoBuffer() {
        SendMessage(Controls.EM_EMPTYUNDOBUFFER, 0, 0, this)
    }

    /**
     * Undoes the last operation in the edit control.
     */
    Undo() {
        SendMessage(Controls.EM_UNDO, 0, 0, this)
    }
    ;@endregion

    ;@region Caret
    /**
     * Creates a new `Gui.Edit.Caret` that handles the caret of the edit
     * control.
     * 
     * @returns {Gui.Edit.Caret}
     */
    Caret => Gui.Edit.Caret(this)

    /**
     * Class that warps around the caret (text insertion point) of an edit
     * control.
     */
    class Caret {
        /**
         * Creates a new `Gui.Edit.Caret`.
         * 
         * @param   {Gui.Edit}  EditCtl  the edit control
         */
        __New(EditCtl) {
            if (!(EditCtl is Gui.Edit)) {
                throw TypeError("Expected a Gui.Edit",, Type(EditCtl))
            }
            this.DefineProp("Edit", { Get: (_) => EditCtl })
        }

        /**
         * Moves the caret to the specified line number and column
         * 
         * @param   {Integer?}  Line    the new line number
         * @param   {Integer?}  Column  the new column
         */
        Move(Line := this.Line, Column := this.Column) {
            if (!IsInteger(Line)) {
                throw TypeError("Expected an Integer",, Line)
            }
            if (!IsInteger(Column)) {
                throw TypeError("Expected an Integer",, Column)
            }
            Line   := Min(Max(1, Line), EditGetLineCount(this.Edit))
            Index  := this.Edit.LineIndex(Line)
            MaxLen := this.Edit.LineLength(Index)
            NewCol := Min(Max(1, Column), MaxLen + 1)

            this.Index := Index + NewCol - 1
        }

        /**
         * Scrolls the text vertically and horizonally. If both parameters are
         * omitted, scrolls the caret into view of the edit control.
         * 
         * - positive integer: down/right
         * - negative integer: up/left
         * 
         * If both parameters are omitted, scrolls into view of the caret.
         * 
         * @param   {Integer?}  UpDown     lines to move up/down
         * @param   {Integer?}  LeftRight  column to scroll left/right
         */
        Scroll(UpDown := 0, LeftRight := 0) {
            if (!IsInteger(UpDown)) {
                throw TypeError("Expected an Integer",, Type(UpDown))
            }
            if (!IsInteger(LeftRight)) {
                throw TypeError("Expected an Integer",, Type(LeftRight))
            }

            if ((UpDown == 0) && (LeftRight == 0)) {
                SendMessage(Controls.EM_SCROLLCARET, 0, 0, this.Edit)
            }

            TotalLines := EditGetLineCount(this)
            NewLineNum := Min(Max(1, this.Line + UpDown), TotalLines)

            NewLineLen := this.Edit.LineLength(NewLineNum)
            NewColNum  := Min(Max(1, this.Column + LeftRight), NewLineLen)

            this.Index := this.Edit.LineIndex(NewLineNum) - 1 + NewColNum
        }

        /**
         * Gets and sets the current line of the caret.
         * 
         * @param   {Integer}  value  the new line
         * @returns {Integer}
         */
        Line {
            get => EditGetCurrentLine(this.Edit)
            set => this.Move(value, this.Column)
        }

        /**
         * Gets and sets the current column of the caret.
         * 
         * @param   {Integer}  value  the new line
         * @returns {Integer}
         */
        Column {
            get => EditGetCurrentCol(this.Edit)
            set => this.Move(this.Line, value)
        }

        /**
         * Gets the index of the caret or moves it to the specified position.
         * 
         * @param   {Integer}  value  1-based index to move caret to
         * @returns {Integer}
         */
        Index {
            get {
                Msg := Controls.EM_GETCARETINDEX
                return SendMessage(Msg, 0, 0, this.Edit) + 1
            }
            set {
                Msg := Controls.EM_SETCARETINDEX
                return SendMessage(Msg, value - 1, 0, this.Edit)
            }
        }
    }
    ;@endregion

    ;@region Positions
    /**
     * Gets information about the character closest to a specified point in the
     * client area of the edit control.
     * 
     * @param   {Integer}           x           client x
     * @param   {Integer}           y           client y
     * @param   {VarRef<Integer>}   Index       output index (1-based)
     * @param   {VarRef<Integer>?}  LineNumber  output line number (1-based)
     */
    CharFromPos(x, y, &Index, &Line?) {
        Coords := (x & 0xFFFF) | ((y & 0xFFFF) << 16)
        Result := SendMessage(Controls.EM_CHARFROMPOS, 0, Coords, this)
        Index  := (Result & 0xFFFF) + 1
        Line   := ((Result >>> 16) & 0xFFFF) + 1
    }

    /**
     * Retrieves the client are coordinates of a specified character in the
     * edit control.
     * 
     * @param   {Integer}          Index  1-based index of the character
     * @param   {VarRef<Integer>}  x      [out] client x
     * @param   {VarRef<Integer>}  y      [out] client y
     */
    PosFromChar(Index, &x, &y) {
        Coords := SendMessage(Controls.EM_POSFROMCHAR, Index - 1, 0, this)
        x := Coords & 0xFFFF
        y := (Coords >>> 16) & 0xFFFF
    }

    /**
     * Gets the index of the line that contains the specified character index
     * in a multiline edit control.
     * 
     * @param   {Integer?}  Index  1-based character index
     * @returns {Integer}
     */
    LineFromChar(Index := EditGetCurrentLine(this)) {
        return SendMessage(Controls.EM_LINEFROMCHAR, Index - 1, 0, this) + 1
    }

    /**
     * Gets the index of the line that contains the specified character index
     * in a multiline edit control, ignoring soft line breaks.
     * 
     * @param   {Integer?}  Index  1-based character index
     * @returns {Integer}
     */
    LogicalLineFromChar(Index := EditGetCurrentLine(this)) {
        return SendMessage(Controls.EM_FILELINEFROMCHAR, Index - 1, 0, this) + 1
    }

    /**
     * Returns the number of lines in the edit control, ignoring soft line
     * breaks.
     * 
     * @returns {Integer}
     */
    LogicalLineCount => SendMessage(Controls.EM_GETFILELINECOUNT, 0, 0, this)

    /**
     * Gets the character index of the first character of a specified line
     * in a multiline edit control.
     * 
     * @param   {Integer?}  Index  1-based line number
     * @returns {Integer}
     */
    LineIndex[Index := EditGetCurrentLine(this)] {
        get {
            Result := SendMessage(Controls.EM_LINEINDEX, Index - 1, 0, this)
            return Result & 0xFFFFFFFF
        }
    }

    /**
     * Gets the character index of the first character of a specified line in
     * a multiline edit control, ignoring soft line breaks.
     * 
     * @param   {Integer?}  Index  1-based line number
     * @returns {Integer}
     */
    LogicalLineIndex[Index := EditGetCurrentLine(this)] {
        get {
            Result := SendMessage(Controls.EM_FILELINEINDEX, Index - 1, 0, this)
            return Result & 0xFFFFFFFF
        }
    }

    /**
     * Gets the length in characters of a line in the edit control.
     * 
     * @param   {Integer?}  Index  1-based line number
     * @returns {Integer}
     */
    LineLength[Index := EditGetCurrentLine(this)] {
        get => SendMessage(Controls.EM_LINELENGTH, Index - 1, 0, this)
    }

    /**
     * Gets the length in characters of a line in the edit control, ignoring
     * soft line breaks.
     * 
     * @param   {Integer?}  Index  1-based line number
     * @returns {Integer}
     */
    LogicalLineLength[Index := EditGetCurrentLine(this)] {
        get => SendMessage(Controls.EM_FILELINELENGTH, Index - 1, 0, this)
    }

    /**
     * Gets a certain line in the edit control by its line number, ignoring
     * soft line breaks.
     * 
     * @param   {Integer?}  Index  1-based line number
     * @returns {Integer}
     */
    LogicalLine[Index := EditGetCurrentLine(this)] {
        get {
            VarSetStrCapacity(&Ret, this.LogicalLineLength[Index])
            SendMessage(Controls.EM_GETFILELINE, Index - 1, StrPtr(Ret), this)
            VarSetStrCapacity(&Ret, -1)
            return Ret
        }
    }

    /**
     * Returns the 1-based line number of the topmost visible line.
     * 
     * @returns {Integer}
     */
    FirstVisibleLine => (
        SendMessage(Controls.EM_GETFIRSTVISIBLELINE, 0, 0, this) + 1
    )
    ;@endregion

    ;@region Area + Margin
    /**
     * Gets and sets the `RECT` containing the bounds of the text display area.
     * 
     * @param   {RECT}  value  the new text bounds
     * @returns {RECT}
     */
    TextArea {
        get {
            SendMessage(Controls.EM_GETRECT, 0, Rc := RECT(), this)
            return Rc
        }
        set {
            if (!(value is RECT)) {
                throw TypeError("Expected a RECT",, Type(value))
            }
            SendMessage(Controls.EM_SETRECT, 0, value.Ptr, this)
        }
    }

    /**
     * Retrieves the text margin of the edit control.
     * 
     * @param   {VarRef<Integer>}  Left   [out] left margin in pixels
     * @param   {VarRef<Integer>}  Right  [out] right margin in pixels
     */
    GetTextMargin(&Left, &Right) {
        Result := SendMessage(Controls.EM_GETMARGINS, 0, 0, this)
        Left   := Result & 0xFFFF
        Right  := (Result >>> 16) & 0xFFFF
    }

    /**
     * Changes the text margins of the edit control. If neither parameter
     * is set, this method defaults to `EC_USEFONTINFO` and uses a margin
     * based on the font being used.
     * 
     * @param   {Integer?}  Left   left margin in pixels
     * @param   {Integer?}  Right  right margin in pixels
     */
    SetTextMargin(Left?, Right?) {
        if (!IsSet(Left) && !IsSet(Right)) {
            SendMessage(Controls.EM_SETMARGINS,
                    WindowsAndMessaging.EC_USEFONTINFO, 0, this)
            return
        }
        wParam := 0
        lParam := 0
        if (IsSet(Left)) {
            wParam |= WindowsAndMessaging.EC_LEFTMARGIN
            lParam |= Min(Max(Left, 0), 0xFFFF)
        }
        if (IsSet(Right)) {
            wParam |= WindowsAndMessaging.EC_RIGHTMARGIN
            lParam |= Min(Max(Right, 0), 0xFFFF) << 16
        }
        SendMessage(Controls.EM_SETMARGINS, wParam, lParam, this)
    }
    ;@endregion

    ;@region Alignment
    /**
     * Aligns text on the left.
     */
    AlignLeft() {
        Style := ControlGetStyle(this)
        ControlSetStyle(Style & ~0x0003 | WindowsAndMessaging.ES_LEFT, this)
    }

    /**
     * Aligns text on the right.
     */
    AlignRight() {
        Style := ControlGetStyle(this)
        ControlSetStyle(Style & ~0x0003 | WindowsAndMessaging.ES_RIGHT, this)
    }

    /**
     * Aligns text in the center.
     */
    AlignCenter() {
        Style := ControlGetStyle(this)
        ControlSetStyle(Style & ~0x0003 | WindowsAndMessaging.ES_CENTER, this)
    }
    ;@endregion

    ;@region Cues
    /**
     * Returns the cue text of the edit control.
     * 
     * @param   {Integer?}  MaxCap  capacity of the buffer that receives string
     * @returns {String}
     */
    GetCue(MaxCap := 128) {
        Buf := Buffer(Max(64, MaxCap), 0)
        SendMessage(Controls.EM_GETCUEBANNER, Buf.Ptr, Buf.Size, this)
        return StrGet(Buf, "UTF-16")
    }

    /**
     * Sets a text to be displayed in the empty edit control.
     * 
     * @param   {String}    Str              the string to be displayed
     * @param   {Boolean?}  ShowWhenFocused  show string when edit is focused
     */
    SetCue(Str, ShowWhenFocused := false) {
        SendMessage(Controls.EM_SETCUEBANNER, !!ShowWhenFocused,
                    StrPtr(Str), this)
    }
    ;@endregion

    ;@region Balloon Tips
    /**
     * Displays a balloon tip.
     * 
     * @param   {String?}              Text   displayed text
     * @param   {String?}              Title  displayed title
     * @param   {EDITBALLOONTIP_ICON}  Icon   the icon to be used
     */
    ShowBalloonTip(Text := "", Title := "",
                   Icon := EDITBALLOONTIP_ICON.TTI_NONE)
    {
        Bt := EDITBALLOONTIP.FromObject({
            cbStruct: EDITBALLOONTIP.sizeof,
                pszTitle: StrPtr(Title),
                pszText: StrPtr(Text),
                ttiIcon: Icon
            })
        SendMessage(Controls.EM_SHOWBALLOONTIP, 0, Bt.Ptr, this)
    }

    /**
     * Hides the balloon tip.
     */
    HideBalloonTip() {
        SendMessage(Controls.EM_HIDEBALLOONTIP, 0, 0, this)
    }
    ;@endregion

    ;@region Web Search
    /**
     * Enables the "Search with Bing..." context menu item.
     */
    EnableSearchWeb() {
        SendMessage(Controls.EM_ENABLESEARCHWEB, true, 0, this)
    }

    /**
     * Disables the "Search with Bing..." context menu item.
     */
    DisableSearchWeb() {
        SendMessage(Controls.EM_ENABLESEARCHWEB, false, 0, this)
    }

    /**
     * Opens the browser and performs a web search with the selected text as
     * the search item.
     */
    SearchWeb() {
        SendMessage(Controls.EM_SEARCHWEB, 0, 0, this)
    }
    ;@endregion

    ;@region Styles and Misc

    /**
     * Gets and sets the end-of-line character for the edit control.
     * 
     * @param   {EC_ENDOFLINE}  value  the new EOL
     * @returns {EC_ENDOFLINE}
     */
    EndOfLine {
        get => SendMessage(Controls.EM_GETENDOFLINE, 0, 0, this)
        set {
            SendMessage(Controls.EM_SETENDOFLINE, value, 0, this)
        }
    }

    /**
     * Gets the sets the text limit of the edit control.
     * 
     * @param   {Integer}  value  the new limit
     * @returns {Integer}
     */
    Limit {
        get => SendMessage(Controls.EM_GETLIMITTEXT, 0, 0, this)
        set => SendMessage(Controls.EM_SETLIMITTEXT, value, 0, this)
    }

    /**
     * Determines whether a multiline edit control includes soft line-break
     * characters.
     * 
     * @param   {Boolean}  value  insert/remove soft line-break characters
     */
    FormatLines {
        set => SendMessage(Controls.EM_FMTLINES, !!value, 0, this)
    }

    /**
     * Gets and changes the password character of the edit control.
     * 
     * @param   {String}  value  the character to be used, else an empty string
     * @returns {String}
     */
    PasswordChar {
        get {
            Result := SendMessage(Controls.EM_GETPASSWORDCHAR, 0, 0, this)
            return (Result) ? Chr(Result) : ""
        }
        set => this.Opt("Password" . value)
    }

    /**
     * Gets or sets the current word wrap function.
     * 
     * ```
     * EditWordBreakProcW(LPSTR lpch, int ichCurrent, int cch, int code)
     * ```
     * 
     * @param   {Integer}  value  function pointer to the procedure
     * @returns {Integer}
     */
    WordBreakProc {
        get => SendMessage(Controls.EM_GETWORDBREAKPROC, 0, 0, this)
        set => SendMessage(Controls.EM_SETWORDBREAKPROC, 0, value, this)
    }

    /**
     * @param   {EDIT_CONTROL_FEATURE}  Feat  the value to enable
     */
    EnableFeature(Feat) {
        SendMessage(Controls.EM_ENABLEFEATURE, true, Feat, this)
        ; TODO find out how this works
    }

    ; TODO GetZoom(&Nom, &Den), SetZoom(Nom, Den)
    ;@endregion
}

;@region Events
class Tanuki_Edit_Events extends AquaHotkey_MultiApply {
    static __New() {
        if (VerCompare(A_AhkVersion, "v2.1-alpha.3") >= 0) {
            super.__New(Gui.Edit)
        }
    }

    OnFocus(Fn, Opt?) {
        this.OnCommand(WindowsAndMessaging.EN_SETFOCUS, Fn, Opt?)
        return this
    }

    OnFocusLost(Fn, Opt?) {
        this.OnCommand(WindowsAndMessaging.EN_KILLFOCUS, Fn, Opt?)
        return this
    }

    OnChange(Fn, Opt?) {
        this.OnCommand(WindowsAndMessaging.EN_CHANGE, Fn, Opt?)
        return this
    }

    OnUpdate(Fn, Opt?) {
        this.OnCommand(WindowsAndMessaging.EN_UPDATE, Fn, Opt?)
        return this
    }

    OnMemoryError(Fn, Opt?) {
        this.OnCommand(WindowsAndMessaging.EN_ERRSPACE, Fn, Opt?)
        return this
    }

    OnMaxText(Fn, Opt?) {
        this.OnCommand(WindowsAndMessaging.EN_MAXTEXT, Fn, Opt?)
        return this
    }

    OnHScroll(Fn, Opt?) {
        this.OnCommand(WindowsAndMessaging.EN_HSCROLL, Fn, Opt?)
        return this
    }

    OnVScroll(Fn, Opt?) {
        this.OnCommand(WindowsAndMessaging.EN_VSCROLL, Fn, Opt?)
        return this
    }

    OnAlignLeftToRight(Fn, Opt?) {
        this.OnCommand(WindowsAndMessaging.EN_ALIGN_LTR_EC, Fn, Opt?)
        return this
    }
    
    OnAlignRightToLeft(Fn, Opt?) {
        this.OnCommand(WindowsAndMessaging.EN_ALIGN_RTL_EC, Fn, Opt?)
        return this
    }

    OnBeforePaste(Fn, Opt?) {
        this.OnCommand(WindowsAndMessaging.EN_BEFORE_PASTE, Fn, Opt?)
        return this
    }

    OnAfterPaste(Fn, Opt?) {
        this.OnCommand(WindowsAndMessaging.EN_AFTER_PASTE, Fn, Opt?)
        return this
    }
}
;@endregion

g := Gui()
e := g.AddEdit()
g.Show()

esc:: ExitApp()