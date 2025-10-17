#Include <AquaHotkey>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\BUTTON_SPLITINFO>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\NMBCDROPDOWN>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\Apis>

/**
 * Introduces the split button as new `Gui.SplitButton`.
 * 
 * ```
 * class Gui
 * |- AddSplitButton(Opt := "", Txt?)
 * `- class SplitButton extends Gui.Button
 *    |- Settings { get; set; }
 *    |- OnDropDown(Fn, Opt?)
 *    |- DropDown()
 *    |- UndoDropDown()
 *    `- Type { get; }
 * ```
 */
class Tanuki_SplitButton extends AquaHotkey {
class Gui {
    /**
     * Adds a split button to the Gui.
     * 
     * @param   {String?}  Opt  option string
     * @param   {String?}  Txt  text to display
     * @return  {Gui.SplitButton}
    */
    AddSplitButton(Opt := "", Txt?) {
        Ctl := this.AddCustom("ClassButton 0xC " . Opt, Txt?)
        ObjSetBase(Ctl, Gui.SplitButton.Prototype)
        return Ctl
    }

    /**
     * The Split Button is a composite control with which the user can select a
     * default value, or select from a drop-down list bound to a secondary
     * button.
     */
    class SplitButton extends Gui.Button {
        /**
         * Retrieves and changes the current options set for the split button
         * control.
         * 
         * @param   {BUTTON_SPLITINFO}  value  the new options
         * @return  {BUTTON_SPLITINFO}
         */
        Settings {
            get {
                Info := BUTTON_SPLITINFO()
                SendMessage(Controls.BCM_GETSPLITINFO, 0, Info, this)
                return Info
            }
            set {
                if (!(value is BUTTON_SPLITINFO)) {
                    throw TypeError("Expected a BUTTON_SPLITINFO",, Type(value))
                }
                SendMessage(Controls.BCM_SETSPLITINFO, 0, value, this)
                this.Redraw()
            }
        }

        /**
         * Registers a function to be called when the user clicks the drop down
         * arrow.
         * 
         * @example
         * (Gui.SplitButton, Pointer<NMBCDROPDOWN>) => Void
         * 
         * @param   {Func}     Fn   the function to be called
         * @param   {Integer}  Opt  add/remove the callback
         */
        OnDropDown(Fn, Opt?) {
            ControlSetStyle("+" . WindowsAndMessaging.BS_NOTIFY, this)
            this.OnNotify(Controls.BCN_DROPDOWN, Fn, Opt?)
            return this
        }

        /**
         * Causes a drop down action for the button by manually sending a
         * `BCN_DROPDOWN` notification to the Gui.
         */
        DropDown() {
            static WM := WindowsAndMessaging
            static CT := Controls
            SendMessage(CT.BCM_SETDROPDOWNSTATE, true, 0, this)
            Id := WM.GetDlgCtrlID(this.Hwnd)
            SendMessage(WM.WM_NOTIFY, Id, NMBCDROPDOWN.FromObject({
                hdr: { hwndFrom: this.Hwnd, idFrom: Id, code: CT.BCN_DROPDOWN },
                rcButton: WM.GetClientRect(this.Hwnd, Rc := RECT()) && Rc
            }), this.Gui.Hwnd)
        }

        /**
         * Reverts the drop down status of the button.
         */
        UndoDropDown() {
            SendMessage(Controls.BCM_SETDROPDOWNSTATE, false, 0, this)
        }

        /**
         * Returns the type of Gui control.
         * @returns {String}
         */
        Type => "SplitButton"
    }
} ; class Gui
} ; class Tanuki_SplitButton extends AquaHotkey