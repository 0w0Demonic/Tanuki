
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
        }
    }

    ; TODO
    class Style {
        static NoSplit   => 0x0001
        static Stretch   => 0x0002
        static AlignLeft => 0x0004
        static Image     => 0x0008
    }

    class Info {
        static Glyph => 0x0001
        static Image => 0x0002
        static Style => 0x0004
        static Size  => 0x0008
    }
}