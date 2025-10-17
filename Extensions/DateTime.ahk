#Include <AquaHotkey>
#Include <Tanuki\Util\Event>
#Include <AhkWin32Projection\Windows\Win32\Foundation\SIZE>
#Include <AhkWin32Projection\Windows\Win32\Foundation\COLORREF>
#Include <AhkWin32Projection\Windows\Win32\Graphics\Gdi\Apis>
#Include <AhkWin32Projection\Windows\Win32\Graphics\Gdi\HFONT>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\DATETIMEPICKERINFO>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\NMHDR>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\NMDATETIMECHANGE>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\NMDATETIMECHANGE_FLAGS>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\NMDATETIMEFORMATQUERYW>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\NMDATETIMEFORMATW>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\NMDATETIMESTRINGW>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\NMDATETIMEWMKEYDOWNW>
/**
 * DateTime extension class.
 * 
 * ```
 * class Gui
 * `- class DateTime
 *    |- GetTime(&Time)
 *    |- SetTime(Time)
 *    |- Clear()
 *    |- GetRange(&MinTime, &MaxTime)
 *    |- SetRange(MinTime?, MaxTime?)
 *    |- Color[Idx] { get; set; }
 *    |- BackgroundColor { get; set; }
 *    |- MonthBackgroundColor { get; set; }
 *    |- TextColor { get; set; }
 *    |- TitleBackgroundColor { get; set; }
 *    |- TitleTextColor { get; set; }
 *    |- TrailingTextColor { get; set; }
 *    |- Font { get; set; }
 *    |- Close()
 *    |- Info { get; }
 *    |- IdealSize { get; }
 *    |- CalendarHwnd { get; }
 *    |- OnChange(Fn, Opt?)
 *    |- OnStringInput(Fn, Opt?)
 *    |- OnKeyDown(Fn, Opt?)
 *    |- OnFormat(Fn, Opt?)
 *    |- OnFormatQuery(Fn, Opt?)
 *    |- OnDropDown(Fn, Opt?)
 *    |- OnClose(Fn, Opt?)
 *    |- OnFocus(Fn, Opt?)
 *    `- OnFocusLost(Fn, Opt?)
 * ```
 */
class Tanuki_DateTime extends AquaHotkey_MultiApply {
    static __New() => super.__New(Gui.DateTime)

    ;@region Selection
    /**
     * Gets the currently selected time from the datetime control.
     * @example
     * DateTimeCtl.GetSystemTime(&Time)
     * 
     * if (Time) {
     *     MsgBox(Time.ToString())
     * } else {
     *     MsgBox("no time is currently set")
     * }
     * 
     * @param   {VarRef<SYSTEMTIME>}  Time  output time (`false`, if none is set)
     * @returns {NMDATETIMECHANGE_FLAGS}
     */
    GetTime(&Time) {
        Result := SendMessage(Controls.DTM_GETSYSTEMTIME, 0, St := SYSTEMTIME(), this)
        if (Result == NMDATETIMECHANGE_FLAGS.GDT_ERROR) {
            throw Error("Unable to retrieve system time")
        }
        Time := (Result == NMDATETIMECHANGE_FLAGS.GDT_VALID) && St
        return Result
    }

    /**
     * Sets the time in the date time control.
     * 
     * @example
     * if (!DateTimeCtl.SetSystemTime(SYSTEMTIME.Now())) {
     *     MsgBox("unable to set system time")
     * }
     * 
     * @param   {SYSTEMTIME}  Time  the time to set, if any
     * @returns {Boolean} `true` on success
     */
    SetTime(Time) {
        if (!(Time is SYSTEMTIME)) {
            throw TypeError("Expected a SYSTEMTIME",, Type(Time))
        }
        return SendMessage(Controls.DTM_SETSYSTEMTIME, NMDATETIMECHANGE_FLAGS.GDT_VALID, Time, this)
    }

    /**
     * Clears the current selection in the date time control.
     * 
     * This only works on date time controls which have been constructed using the
     * `DTS_SHOWNONE` time format. If the style is not set, an error is thrown.
     * 
     * @example
     * DateTimeCtl.Clear()
     */
    Clear() {
        if (!SendMessage(Controls.DTM_SETSYSTEMTIME, NMDATETIMECHANGE_FLAGS.GDT_NONE, 0, this)) {
            throw Error("Unable to clear selection")
        }
    }
    ;@endregion

    ;@region Region
    /**
     * Gets the current minimum and maximum allowable system times for the date time control.
     * 
     * @example
     * DateTimeCtl.GetRange(&MinTime, &MaxTime)
     * 
     * if (MinTime) {
     *     MsgBox("minimum: " . MinTime.ToString())
     * }
     * if (MaxTime) {
     *     MsgBox("maximum: " . MaxTime.ToString())
     * }
     * 
     * @param   {VarRef<SYSTEMTIME>}  MinTime  (out) minimum allowable time, else `false`
     * @param   {VarRef<SYSTEMTIME>}  MaxTime  (out) maximum allowable time, else `false`
     * @returns {Controls.GDTR_*}  a combination of `GDTR_*` flags
     */
    GetRange(&MinTime, &MaxTime) {
        Buf := Buffer(2 * SYSTEMTIME.sizeof, 0)
        Arr := Win32FixedArray(Buf.Ptr, 2, SYSTEMTIME)
        Result := SendMessage(Controls.DTM_GETRANGE, 0, Arr, this)
        MinTime := ((Result & Controls.GDTR_MIN) && Arr[1].Clone())
        MaxTime := ((Result & Controls.GDTR_MAX) && Arr[2].Clone())
        return Result
    }

    /**
     * Sets the mimum and maximum allowable system times for the date time control.
     * 
     * @example
     * Now := SYSTEMTIME.Now()
     * 
     * PlusOneYear := Now.Clone()
     * ++PlusOneYear.wYear
     * 
     * DateTimeCtl.SetRange(Now, PlusOneYear)
     * 
     * @param   {SYSTEMTIME?}  MinTime  minimum allowable time, if any
     * @param   {SYSTEMTIME?}  MaxTime  maximum allowable time, if any
     * @returns {Boolean} `true` on success
     */
    SetRange(MinTime?, MaxTime?) {
        wParam := (IsSet(MinTime) * Controls.GDTR_MIN)
                | (IsSet(MaxTime) * Controls.GDTR_MAX)

        Buf := Buffer(2 * SYSTEMTIME.sizeof, 0)
        Arr := Win32FixedArray(Buf.Ptr, 2, SYSTEMTIME)
        if (IsSet(MinTime)) {
            Arr[1] := MinTime
        }
        if (IsSet(MaxTime)) {
            Arr[2] := MaxTime
        }
        return SendMessage(Controls.DTM_SETRANGE, wParam, Arr, this)
    }
    ;@endregion

    ;@region Colors
    /**
     * Gets or sets the colours of various elements of the date time control.
     * 
     * There are six possible color types:
     * - `BackgroundColor`
     * - `MonthBackgroundColor`
     * - `TextColor`
     * - `TitleBackgroundColor`
     * - `TitleTextColor`
     * - `TrailingTextColor`
     * 
     * 1. Changes only take effect while the drop-down month-calendar is visible
     *    (dropped down) and are lost once it is hidden.
     * 
     * 2. These properties are most useful when handled inside a drop-down
     *    event (`OnDropDown`) to reliably apply them each time the calendar opens.
     * 
     * @example
     * 
     * Event := DateTimeCtl.OnDropDown(DropDown)
     * 
     * DropDown(Dtm, Hdr) {
     *     Dtm.BackgroundColor := 0x000000
     *     Dtm.MonthBackgroundColor := 0x000000
     *     Dtm.TextColor := 0xFFFFFF
     * }
     * 
     * @param   {Controls.MCSC_*}   Idx    element of date time control
     * @param   {COLORREF/Integer}  value  the new color
     * @returns {COLORREF}
     */
    Color[Idx] {
        get {
            CalendarHwnd := this.CalendarHwnd
            if (!CalendarHwnd) {
                throw TargetError("month-calendar does not exist")
            }

            Clr := SendMessage(Controls.DTM_SETMCCOLOR, Idx, 0, this)
            if (Clr == Gdi.CLR_INVALID) {
                throw Error("Unable to retrieve color")
            }
            Result := COLORREF()
            Result.Value := Clr
            return Result
        }
        set {
            CalendarHwnd := this.CalendarHwnd
            if (!CalendarHwnd) {
                throw TargetError("month-calendar does not exist")
            }
            Controls.SetWindowTheme(CalendarHwnd, "", "")
            
            switch {
                case (value is COLORREF):
                    Clr := value.value
                case IsInteger(value):
                    Clr := value
                default:
                    throw TypeError("Expected a COLORREF or Integer",, Type(value))
            }
            if (SendMessage(Controls.DTM_SETMCCOLOR, Idx, Clr, this) == Gdi.CLR_INVALID) {
                throw Error("Unable to set color")
            }
        }
    }

    /**
     * Gets or sets the background color displayed between months.
     * 
     * @param   {COLORREF/Integer}  value  the color to set
     */
    BackgroundColor {
        get => this.Color[Controls.MCSC_BACKGROUND]
        set => this.Color[Controls.MCSC_BACKGROUND] := value
    }

    /**
     * Gets or sets the background color displayed within the month.
     * 
     * @param   {COLORREF/Integer}  value  the color to set
     */
    MonthBackgroundColor {
        get => this.Color[Controls.MCSC_MONTHBK]
        set => this.Color[Controls.MCSC_MONTHBK] := value
    }

    /**
     * Gets or sets the color used to display text within a month.
     * 
     * @param   {COLORREF/Integer}  value  the color to set
     */
    TextColor {
        get => this.Color[Controls.MCSC_TEXT]
        set => this.Color[Controls.MCSC_TEXT] := value
    }

    /**
     * Gets or sets the background color displayed in the calendar's title.
     * 
     * @param   {COLORREF/Integer}  value  the color to set
     */
    TitleBackgroundColor {
        get => this.Color[Controls.MCSC_TITLEBK]
        set => this.Color[Controls.MCSC_TITLEBK] := value
    }

    /**
     * Gets or sets the color used to display text within the calendar's title.
     * 
     * @param   {COLORREF/Integer}  value  the color to set
     */
    TitleTextColor {
        get => this.Color[Controls.MCSC_TITLETEXT]
        set => this.Color[Controls.MCSC_TITLETEXT] := value
    }

    /**
     * Gets or sets the color used to display header day and trailing day text.
     * 
     * @param   {COLORREF/Integer}  value  the color to set
     */
    TrailingTextColor {
        get => this.Color[Controls.MCSC_TRAILINGTEXT]
        set => this.Color[Controls.MCSC_TRAILINGTEXT] := value
    }
    ;@endregion

    ;@region General
    /**
     * Gets and sets the font of the date time control.
     * 
     * @param   {HFONT/Integer}  value  handle of the font to be used
     * @returns {HFONT}
     */
    Font {
        get {
            Result := HFONT()
            Result.Value := SendMessage(Controls.DTM_GETMCFONT, 0, 0, this)
            return Result
        }
        set {
            switch {
                case (value is HFONT):
                    Val := HFONT.Value
                case (IsInteger(value)):
                    Val := value
                default:
                    throw TypeError("Expected an HFONT or a Integer",, Type(value))
            }
            SendMessage(Controls.DTM_SETMCFONT, Val, true, this)
        }
    }

    /**
     * Closes the date time control.
     */
    Close() {
        SendMessage(Controls.DTM_CLOSEMONTHCAL, 0, 0, this)
    }

    /**
     * Gets information on the date time control.
     * 
     * @returns {DATETIMEPICKERINFO}
     */
    Info {
        get {
            Res := DATETIMEPICKERINFO()
            SendMessage(Controls.DTM_GETDATETIMEPICKERINFO, 0, Res, this)
            return Res
        }
    }

    /**
     * Gets the size needed to display the control without clipping.
     * 
     * @returns {SIZE}
     */
    IdealSize {
        get {
            SendMessage(Controls.DTM_GETIDEALSIZE, 0, Sz := SIZE(), this)
            return Sz
        }
    }

    /**
     * Returns the HWND of the month-calendar control.
     * 
     * @returns {Integer}
     */
    CalendarHwnd => SendMessage(Controls.DTM_GETMONTHCAL, 0, 0, this)
    ;@endregion

    ;@region Events
    /**
     * Registers a function to be called when the date time is changed.
     *
     * @example
     * (DtmCtl: Gui.DateTime, Info: NMDATETIMECHANGE) => Any
     * 
     * @param   {Func}      Fn   the function to be called
     * @param   {Integer?}  Opt  add/remove the callback
     * @returns {Gui.Event}
     */
    OnChange(Fn, Opt?) {
        GetMethod(Fn)
        return Gui.Event.OnNotify(
                this, Controls.DTN_DATETIMECHANGE,
                Change, Opt?)
        
        Change(DtmCtl, lParam) {
            Fn(DtmCtl, NMDATETIMECHANGE(lParam))
            return 0
        }
    }

    /**
     * Registers a function to be called when a user finishes editing a string
     * in the control. This notification code is only sent by date time controls
     * that are set to the `DTS_APPCANPARSE` style.
     * 
     * @example
     * (DtmCtl: Gui.DateTime, Info: NMDATETIMESTRINGW) => Any
     * 
     * @param   {Func}      Fn   the function to be called
     * @param   {Integer?}  Opt  add/remove the callback
     * @returns {Gui.Event}
     */
    OnStringInput(Fn, Opt?) {
        GetMethod(Fn)
        ControlSetStyle("+" . Controls.DTS_APPCANPARSE, this)
        return Gui.Event.OnNotify(
                this, Controls.DTN_USERSTRING,
                StringInput, Opt?)
        
        StringInput(DtmCtl, lParam) {
            Fn(DtmCtl, NMDATETIMESTRINGW(lParam))
            return 0
        }
    }
    
    /**
     * Registers a function to be called when the user types in a
     * [callback field](https://learn.microsoft.com/en-us/windows/win32/controls/date-and-time-picker-controls#callback-fields).
     * 
     * @example
     * (DtmCtl: Gui.DateTime, Info: NMDATETIMESTRINGW) => Any
     * 
     * @param   {Func}      Fn   the function to be called
     * @param   {Integer?}  Opt  add/remove the callback
     * @returns {Gui.Event}
     */
    OnKeyDown(Fn, Opt?) {
        GetMethod(Fn)
        return Gui.Event.OnNotify(
                this, Controls.DTN_WMKEYDOWN,
                KeyDown, Opt?)
        
        KeyDown(DtmCtl, lParam) {
            Fn(DtmCtl, NMDATETIMEWMKEYDOWNW(lParam))
            return 0
        }
    }

    /**
     * Registers a function to be called when the date time control requests
     * text to be displayed in a [callback field](https://learn.microsoft.com/en-us/windows/win32/controls/date-and-time-picker-controls#callback-fields).
     * 
     * @example
     * (DtmCtl: Gui.DateTime, Info: NMDATETIMEFORMATW) => Any
     * 
     * @param   {Func}      Fn   the function to be called
     * @param   {Integer?}  Opt  add/remove the callback
     * @returns {Gui.Event}
     */
    OnFormat(Fn, Opt?) {
        GetMethod(Fn)
        ControlSetStyle("+" . Controls.DTS_APPCANPARSE, this)
        return Gui.Event.OnNotify(
                this, Controls.DTN_FORMAT,
                Format, Opt?)
        
        Format(DtmCtl, lParam) {
            Fn(DtmCtl, NMDATETIMEFORMATW(lParam))
            return 0
        }
    }

    /**
     * Sent by a date time control to retrieve the maximum allowable size of the
     * string that will be displayed in a [callback field](https://learn.microsoft.com/en-us/windows/win32/controls/date-and-time-picker-controls#callback-fields).
     * 
     * @example
     * (DtmCtl: Gui.DateTime, Info: NMDATETIMEFORMATQUERYW) => Any
     * 
     * @param   {Func}      Fn   the function to be called
     * @param   {Integer?}  Opt  add/remove the callback
     * @returns {Gui.Event}
     */
    OnFormatQuery(Fn, Opt?) {
        GetMethod(Fn)
        return Gui.Event.OnNotify(
                this, Controls.DTN_FORMATQUERY,
                FormatQuery, Opt?)
        
        FormatQuery(DtmCtl, lParam) {
            Fn(DtmCtl, NMDATETIMEFORMATQUERYW(lParam))
            return 0
        }
    }

    /**
     * Sent by a date time control when the user activates the drop-down month
     * calendar.
     * 
     * @example
     * (DtmCtl: Gui.DateTime, Info: NMHDR) => Any
     * 
     * @param   {Func}      Fn   the function to be called
     * @param   {Integer?}  Opt  add/remove the callback
     * @returns {Gui.Event}
     */
    OnDropDown(Fn, Opt?) {
        GetMethod(Fn)
        return Gui.Event.OnNotify(
                this, Controls.DTN_DROPDOWN,
                (DtmCtl, lParam) => Fn(DtmCtl, NMHDR(lParam), Opt?))
    }

    /**
     * Sent by a date time control when the user closes the drop-down month
     * calendar.
     * 
     * @example
     * (DtmCtl: Gui.DateTime, Info: NMHDR) => Any
     * 
     * @param   {Func}      Fn   the function to be called
     * @param   {Integer?}  Opt  add/remove the callback
     * @returns {Gui.Event}
     */
    OnClose(Fn, Opt?) {
        GetMethod(Fn)
        return Gui.Event.OnNotify(
                this, Controls.DTN_CLOSEUP,
                (DtmCtl, lParam) => Fn(DtmCtl, NMHDR(lParam)), Opt?)
    }

    /**
     * Sent when the control gains input focus.
     * 
     * @example
     * (DtmCtl: Gui.DateTime, Info: NMHDR) => Any
     * 
     * @param   {Func}      Fn   the function to be called
     * @param   {Integer?}  Opt  add/remove the callback
     * @returns {Gui.Event}
     */
    OnFocus(Fn, Opt?) {
        GetMethod(Fn)
        return Gui.Event.OnNotify(
                this, Controls.NM_SETFOCUS,
                (DtmCtl, lParam) => Fn(DtmCtl, NMHDR(lParam)), Opt?)
    }

    /**
     * Sent when the control loses input focus.
     * 
     * @example
     * (DtmCtl: Gui.DateTime, Info: NMHDR) => Any
     * 
     * @param   {Func}      Fn   the function to be called
     * @param   {Integer?}  Opt  add/remove the callback
     * @returns {Gui.Event}
     */
    OnFocusLost(Fn, Opt?) {
        GetMethod(Fn)
        return Gui.Event.OnNotify(
                this, Controls.NM_KILLFOCUS,
                (DtmCtl, lParam) => Fn(DtmCtl, NMHDR(lParam)), Opt?)
    }
    ;@endregion
} ; class Tanuki_DateTime extends AquaHotkey