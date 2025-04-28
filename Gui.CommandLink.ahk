
AddCommandLink(Opt := "", Txt?) {
    Ctl := this.Add("Custom", "ClassButton 0xE " . Opt, Txt?)
    ObjSetBase(Ctl, Gui.CommandLink.Prototype)
    return Ctl
}

class CommandLink extends Gui.Button {
    Note {
        get {
            static BCM_GETNOTELENGTH := 0x160B
            static BCM_GETNOTE       := 0x160A

            Len := SendMessage(BCM_GETNOTELENGTH, 0, 0, this)
            Cap := (2 * (Len + 1))
            Result := Buffer(Cap, 0)
            CapBuf := Buffer(4, 0)
            NumPut("UInt", Cap, CapBuf)
            SendMessage(BCM_GETNOTE, CapBuf.Ptr, Result.Ptr, this)
            return StrGet(Result, "UTF-16")
        }
        set {
            static BCM_SETNOTE := 0x1609
            SendMessage(BCM_SETNOTE, 0, StrPtr(value), this)
        }
    }
}