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
        EventObj.DefineProp("Remove", {
            Call: (Instance) => Instance.OnMessage(MsgNumber, Callback, false)
        })
        return EventObj
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
        EventObj.DefineProp("Remove", {
            Call: (Instance) => Instance.OnNotify(NotifyCode, Callback, false)
        })
        return EventObj

        Remove(Instance) {
            Instance.OnNotify(NotifyCode, Callback, false)
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
        EventObj.DefineProp("Remove", {
            Call: (Instance) => Instance.OnCommand(NotifyCode, Callback, false)
        })
        return EventObj
    }
}