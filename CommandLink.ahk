
/**
 * Adds a command link to the Gui.
 * 
 * @param   {String?}  Opt   additional options
 * @param   {String?}  Txt   the label of the command link
 * @param   {String?}  Note  optional description text
 */
AddCommandLink(Opt := "", Txt?, Note?) {
    Ctl := this.Add("Custom", "ClassButton 0xE " . Opt, Txt?)
    ObjSetBase(Ctl, Gui.CommandLink.Prototype)
    if (IsSet(Note)) {
        Ctl.Note := Note
    }
    return Ctl
}

/**
 * A command link is a type of button with a lightweight appearance that allows
 * for descriptive labels, and are displayed with either a standard arrow or
 * custom icon, and an optional supplemental explanation.
 */
class CommandLink extends Gui.Button {
    /**
     * Retrieves and changes the description text of the command link.
     * 
     * @param   {String}  value  the new description text
     * @return  {String}
     */
    Note {
        get {
            static BCM_GETNOTE := 0x160A

            Cap := (2 * (this.NoteLength + 1))
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

    /**
     * Returns the length of the description text, in characters.
     * 
     * @return  {Integer}
     */
    NoteLength {
        get {
            static BCM_GETNOTELENGTH := 0x160B
            return SendMessage(BCM_GETNOTELENGTH, 0, 0, this)
        }
    }
}