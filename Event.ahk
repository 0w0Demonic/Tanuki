#Include <AquaHotkey>

/**
 * Extension class that introduces the `Gui.Event` class, a simple wrapper
 * for Gui events.
 * 
 * ```
 * class Gui
 * `- class Event
 *    |- __New(RemoveFn)
 *    |- static OnMessage(GuiObj, Msg, Fn, Opt?)
 *    |- static OnNotify(GuiObj, Msg, Notif, Opt?)
 *    `- static OnCommand(GuiObj, Msg, Cmd, Opt?)
 * ```
 */
class Tanuki_Gui_Event extends AquaHotkey_MultiApply {
    static __New() {
        if (VerCompare(A_AhkVersion, "<v2.1-alpha.3")) {
            this.DeleteProp("OnMessage")
        }
        super.__New(Gui)
    }

    /**
     * Simple wrapper over a Gui event (message, notification or command) with
     * additional `Remove()` method for unregistering.
     */
    class Event {
        /**
         * Creates a new `Gui.Event`.
         * 
         * @param   {Func}  RemoveFn  function that unregisters the Gui event
         */
        __New(RemoveFn) => this.DefineProp("Remove", { Call: RemoveFn })

        /**
         * (AutoHotkey >=v2.1-alpha.3) Registers a function to be called when
         * the Gui receives the specified message.
         * 
         * @param   {Gui}       GuiObj  any Gui object 
         * @param   {Integer}   Msg     the message number
         * @param   {Func}      Fn      the function to be called
         * @param   {Integer?}  Opt     add/remove the event
         * @returns {Gui.Event}
         */
        static OnMessage(GuiObj, Msg, Fn, Opt?) {
            GuiObj.OnMessage(Msg, Fn, Opt?)
            return this((_) => _.OnMessage(Msg, Fn, false))
        }

        /**
         * Registers a function to be called when the Gui receives the
         * specified notification.
         * 
         * @param   {Gui}       GuiObj  any Gui object 
         * @param   {Integer}   Notif   the notif code
         * @param   {Func}      Fn      the function to be called
         * @param   {Integer?}  Opt     add/remove the event
         * @returns {Gui.Event}
         */
        static OnNotify(GuiObj, Notif, Fn, Opt?) {
            GuiObj.OnNotify(Notif, Fn, Opt?)
            return this((_) => _.OnNotify(Notif, Fn, false))
        }

        /**
         * Registers a function to be called when the Gui receives the
         * specified command.
         * 
         * @param   {Gui}       GuiObj  any Gui object 
         * @param   {Integer}   Notif   the command code
         * @param   {Func}      Fn      the function to be called
         * @param   {Integer?}  Opt     add/remove the event
         * @returns {Gui.Event}
         */
        static OnCommand(GuiObj, Cmd, Fn, Opt?) {
            GuiObj.OnCommand(Cmd, Fn, Opt?)
            return this((_) => _.OnCommand(Cmd, Fn, false))
        }
    }
}