
class StaticControl extends AquaHotkey_MultiApply {
    static __New() => super.__New(Tanuki.Gui.Text,
                                  Tanuki.Gui.Pic)
    
    OnClick(Callback, AddRemove?) {
        static STN_CLICKED := 0x0000
        try this.Style |= Gui.StaticControl.Style.Notify
        return Gui.Event.OnCommand(this, STN_CLICKED, Callback, AddRemove?)
    }

    OnDoubleClick(Callback, AddRemove?) {
        static STN_DBLCLK := 0x0001
        try this.Style |= Gui.StaticControl.Style.Notify
        return Gui.Event.OnCommand(this, STN_DBLCLK, Callback, AddRemove?)
    }

    OnEnable(Callback, AddRemove?) {
        static STN_ENABLE := 0x0002
        try this.Style |= Gui.StaticControl.Style.Notify
        return Gui.Event.OnCommand(this, STN_ENABLE, Callback, AddRemove?)
    }

    OnDisable(Callback, AddRemove?) {
        static STN_DISABLE := 0x0002
        try this.Style |= Gui.StaticControl.Style.Notify
        return Gui.Event.OnCommand(this, STN_DISABLE, Callback, AddRemove?)
    }
}