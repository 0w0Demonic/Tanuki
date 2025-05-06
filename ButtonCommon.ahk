/**
 * 
 */
class ButtonCommon extends AquaHotkey_MultiApply {
    static __New() => super.__New(
        Tanuki.Gui.Button,
        Tanuki.Gui.Radio,
        Tanuki.Gui.CheckBox) ; TODO more?
    
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
}