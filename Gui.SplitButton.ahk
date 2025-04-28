
AddSplitButton(Opt := "", Txt?) {
    Ctl := this.Add("Custom", "ClassButton 0xC" . Opt, Txt?)
    ObjSetBase(Ctl, Gui.SplitButton.Prototype)
    return Ctl
}

class SplitButton extends Gui.Button {
    State {
        get {
            
        }
        set {

        }
    }

    Info {
        get {

        }
        set {

        }
    }
}