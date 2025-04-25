/**
 * 
 */
class Event {
    /**
     * 
     */
    static OnMessage(GuiObj, MsgNumber, Callback, AddRemove?) {
        if (!HasMethod(Callback)) {
            throw TypeError("Expected a Function object",, Type(Callback))
        }
        GuiObj.OnMessage(MsgNumber, Callback, AddRemove?)
        EventObj := this()
        EventObj.DefineProp("Remove", { Call: Remove })
        return EventObj

        Remove(Instance) {
            GuiObj.OnMessage(MsgNumber, Callback, false)
        }
    }

    /**
     * 
     */
    static OnNotify(GuiObj, NotifyCode, Callback, AddRemove?) {
        if (!HasMethod(Callback)) {
            throw TypeError("Expected a Function object",, Type(Callback))
        }
        GuiObj.OnNotify(NotifyCode, Callback, AddRemove?)
        EventObj := this()
        EventObj.DefineProp("Remove", { Call: Remove })
        return EventObj

        Remove(Instance) {
            GuiObj.OnNotify(NotifyCode, Callback, false)
        }
    }

    /**
     * 
     */
    static OnCommand(GuiObj, NotifyCode, Callback, AddRemove?) {
        if (!HasMethod(Callback)) {
            throw TypeError("Expected a Function object",, Type(Callback))
        }
        GuiObj.OnCommand(NotifyCode, Callback, AddRemove?)
        EventObj := this()
        EventObj.DefineProp("Remove", { Call: Remove })
        return EventObj

        Remove(Instance) {
            GuiObj.OnCommand(NotifyCode, Callback, false)
        }
    }
}