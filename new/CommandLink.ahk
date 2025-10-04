#Include <AquaHotkey>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>
#Include <AhkWin32Projection\Windows\Win32\Graphics\Gdi\HBITMAP>
#Include <Tanuki\New\Button>

/**
 * Extension class that introduces the command link control as a new
 * Gui class.
 */
class Tanuki_CommandLink extends AquaHotkey {
class Gui {
    /**
     * Adds a command link to the Gui.
     * 
     * @param   {String?}  Opt   option string
     * @param   {String?}  Txt   label of the command link
     * @param   {String?}  Note  description text
     * @returns {Gui.CommandLink}
     */
    AddCommandLink(Opt := "", Txt?, Note?) {
        Ctl := this.AddCustom("ClassButton 0xE " . Opt, Txt?)
        ObjSetBase(Ctl, Gui.CommandLink.Prototype)
        if (IsSet(Note)) {
            Ctl.Note := Note
        }
        return Ctl
    }

    /**
     * A command link is a type of button with a lightweight appearance that
     * allows for descriptive labels, and are displayed either a standard
     * arrow or custom icon, and an optional supplemental explanation.
     */
    class CommandLink extends Gui.Button {
        /**
         * Gets and sets the description text of the command link button.
         * 
         * @param   {String}  value  the new description text
         * @returns {String}
         */
        Note {
            get {
                Cap := (2 * (this.NoteLength + 1))
                Result := Buffer(Cap, 0)
                CapBuf := Buffer(4, 0)
                NumPut("UInt", Cap, CapBuf)
                SendMessage(Controls.BCM_GETNOTE, CapBuf.Ptr, Result.Ptr, this)
                return StrGet(Result, "UTF-16")
            }
            set => SendMessage(Controls.BCM_SETNOTE, 0, StrPtr(value), this)
        }

        /**
         * Returns the length of the description text in characters.
         * @returns {Integer}
         */
        NoteLength => SendMessage(Controls.BCM_GETNOTELENGTH, 0, 0, this)

        /**
         * Returns the type of the Gui control.
         * 
         * @returns {String}
         */
        Type => "CommandLink"
    }
} ; class Gui
} ; class Tanuki_CommandLink extends AquaHotkey
