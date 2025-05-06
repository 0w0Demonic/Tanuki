
AddPushButton(Opt := "", Txt?) {
    Ctl := this.Add("Custom", "ClassButton 0xA " . Opt, Txt?)

    if (!(Ctl.Style & 0x0F00)) {
        Ctl.Style |= Gui.PushButton.Style.Center
    }

    ObjSetBase(Ctl, Gui.PushButton.Prototype)
    Ctl.ApplySize(Opt)
    Ctl.Redraw()
    return Ctl
}

class PushButton extends Gui.Button {
    
}