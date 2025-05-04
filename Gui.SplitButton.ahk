
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
    static ContainsSizingOptions := "
    (
    Six)
    (?(DEFINE) (?<size> r | (?:w|h) (?: p(?:\+|-) )? )
               (?<integer> 0 | [1-9]\d*+ )
               (?<float> (?&integer)? \. \d++ )
               (?<number>  (?&integer) | (?&float) ))
    (?&size) (?&number)
    )"
    ObjSetBase(Ctl, Gui.SplitButton.Prototype)
    if (!(Opt ~= ContainsSizingOptions)) {
        Ctl.Size := Ctl.IdealSize
    }
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
     * SplitBtn.Settings := BUTTON_SPLITINFO().AlignLeft().ImageList(IList)
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
     * The callback function receives a `NMBCDROPDOWN` struct as its second
     * parameter.
     * 
     * @example
     * MyButton_DropDown(ButtonControl, DropDownStruct) {
     * }
     * 
     * @param   {Func}      Callback   the function to call
     * @param   {Integer?}  AddRemove  add or remove the function
     * @return  {Gui.Event}
     */
    OnDropDown(Callback, AddRemove?) {
        static BTN_DROPDOWN := -1248
        static WM_NOTIFY    := 0x004E

        try this.Style |= Gui.Button.Style.Notify
        return Gui.Event.OnNotify(this, BTN_DROPDOWN, DropDown)

        DropDown(ButtonControl, lParam) {
            Callback(ButtonControl, StructFromPtr(NMBCDROPDOWN, lParam))
        }
    }

    /**
     * Causes a drop down action for the button.
     * This method generates a WM_NOTIFY message, which can be catched by
     * using `.OnDropDown()`.
     */
    DropDown() {
        static BCM_SETDROPDOWNSTATE := 0x1606
        static BCN_DROPDOWN         := -1248
        static WM_NOTIFY            := 0x004E
        SendMessage(BCM_SETDROPDOWNSTATE, true, 0, this)

        Id := DllCall("GetDlgCtrlID", "Ptr", this.Hwnd)
        
        Notif           := NMBCDROPDOWN()
        Header          := Notif.hdr
        Header.hwndFrom := this.Hwnd
        Header.idFrom   := Id
        Header.code     := BCN_DROPDOWN

        Client    := RECT.OfClient(this)
        Rc        := Notif.rcButton
        Rc.Left   := Client.Left
        Rc.Top    := Client.Top
        Rc.Right  := Client.Right
        Rc.Bottom := Client.Bottom

        SendMessage(WM_NOTIFY, Id, ObjGetDataPtr(Notif), this.Gui.Hwnd)
    }

    /** Reverts the drop down static of the button. */
    UndoDropDown() {
        static BCM_SETDROPDOWNSTATE := 0x1606
        SendMessage(BCM_SETDROPDOWNSTATE, false, 0, this)
    }
}