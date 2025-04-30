
/**
 * Adds a split button to the Gui.
 * 
 * @param   {String?}  Opt  additional options
 * @param   {String?}  Txt  the text to display
 * @return  {Gui.SplitButton}
 */
AddSplitButton(Opt := "", Txt?) {
    ; TODO use .IdealSize as default or something
    Ctl := this.Add("Custom", "ClassButton 0xC" . Opt, Txt?)
    ObjSetBase(Ctl, Gui.SplitButton.Prototype)
    return Ctl
}

/**
 * The Split Button is a composite control with which the user can select a
 * default value, or select from a drop-down list bound to a secondary button.
 */
class SplitButton extends Gui.Button {
    /**
     * Retrieves and changes the current options set for the split button
     * control.
     * @example
     * 
     * IList := ImageList().Add(A_Desktop . "\icon.ico")
     * SplitBtn.Settings := BUTTON_SPLITINFO()
     *          .NoSplit().AlignLeft()
     *          .ImageList(IList)
     * 
     * @param   {BUTTON_SPLITINFO}  value  the new options
     * @return  {BUTTON_SPLITINFO}
     */
    Settings {
        get {
            static BCM_GETSPLITINFO := 0x1608
            Info := BUTTON_SPLITINFO()
            SendMessage(BCM_GETSPLITINFO, 0, ObjGetDataPtr(Info), this)
            return Info
        }
        set {
            static BCM_SETSPLITINFO := 0x1607
            if (!(value is BUTTON_SPLITINFO)) {
                throw TypeError("Expected a BUTTON_SPLITINFO",, Type(value))
            }
            SendMessage(BCM_SETSPLITINFO, 0, ObjGetDataPtr(value), this)
            this.Redraw()
            return
        }
    }

    /**
     * Sent when the user clicks the drop down arrow.
     * 
     * @param   {Func}      Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the function
     * @return  {Gui.Event}
     */
    OnDropDown(Callback, AddRemove?) {
        static BTN_DROPDOWN := -1248
        try this.Style |= Gui.Button.Style.Notify

        OnMessage(0x004E, (wParam, lParam, msg, hwnd) {
            Struct := StructFromPtr(NMBCDROPDOWN, lParam)
            MsgBox(Struct.hdr.hwndFrom . " " Struct.hdr.idFrom . " " . Struct.hdr.code)
        })
        return Gui.Event.OnNotify(this, BTN_DROPDOWN, DropDown, AddRemove?) 

        DropDown(ButtonControl, lParam) {
            Rc := StructFromPtr(NMBCDROPDOWN, lParam).rcButton
            Callback(ButtonControl, Rc)
        }
    }

    ; TODO generate a BTN_DROPDOWN event
    /**
     * 
     */
    DropDown() {
        static BCM_SETDROPDOWNSTATE := 0x1606
        SendMessage(BCM_SETDROPDOWNSTATE, true, 0, this)
        
        static BCN_DROPDOWN := -1248
        Notif := NMBCDROPDOWN()
        Header := Notif.hdr

        Header.hwndFrom := this.Hwnd
        Header.idFrom := DllCall("GetDlgCtrlID", "Ptr", this.Hwnd)
        Header.code := BCN_DROPDOWN

        Client := RECT.OfClient(this)
        rc := Notif.rcButton
        rc.Left   := Client.Left
        rc.Top    := Client.Top
        rc.Right  := Client.Right
        rc.Bottom := Client.Bottom

        SendMessage(WM_NOTIFY := 0x004E, Header.idFrom, ObjGetDataPtr(Notif), this)
    }

    ; TODO generate a BTN_DROPDOWN event
    /**
     * 
     */
    UndoDropDown() {
        static BCM_SETDROPDOWNSTATE := 0x1606
        SendMessage(BCM_SETDROPDOWNSTATE, false, 0, this)
        ControlHideDropDown(this)
    }
}