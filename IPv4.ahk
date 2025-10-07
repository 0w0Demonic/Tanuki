#Include <AquaHotkey>
#Include <Tanuki\Event>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\NMIPADDRESS>

/**
 * A wrapper for the `SysIpAddress32` control used for selecting IPv4 addresses,
 * directly integrated as `GUI.IPv4` class. This class is automatically added
 * as static nested class to the `Gui` type.
 * 
 * ```
 * class Gui
 * |- AddIPv4(Opt := "", Addr?)
 * `- class IPv4 extends Gui.Custom
 *    |- Address[Octet?] { get; set; }
 *    |- Clear()
 *    |- IsBlank { get; }
 *    |- Focus(Index)
 *    |- SetRange(Index, Lo := 0, Hi := 255)
 *    `- OnEvent(EventName, Callback, AddRemove?)
 * ```
 */
class Tanuki_IPv4 extends AquaHotkey {
class Gui {
    /**
     * Adds an IPv4 control to the GUI.
     * 
     * @param   {String?}         Opt   additional GUI options
     * @param   {String?/Array?}  Addr  initial IPv4 address
     */
    AddIPv4(Opt := "", Addr?) {
        Ctl := this.AddCustom("ClassSysIPAddress32 r1 " . Opt)
        ObjSetBase(Ctl, Gui.IPv4.Prototype)
        if (IsSet(Addr)) {
            Ctl.Address := Addr
        }
        return Ctl
    }

    class IPv4 extends Gui.Custom {
        /**
         * Gets or sets the IPv4 address of the control.
         * 
         * This property allows reading and modifying the IPv4 address
         * as either:
         * - A full string (e.g., `"192.168.0.1"`)
         * - A segmented array of four octets (e.g., `[192, 168, 0, 1]`)
         * - A specific octet via indexed access (`Ctl.Address[1]` -> `192`)
         * 
         * When setting the address:
         * - Strings must be valid IPv4 addresses.
         * - Arrays must contain exactly four integers (0-255).
         * - Individual octets must be in the valid range.
         * @example
         * 
         * MsgBox(Ctl.Address)         ; "192.168.0.1"
         * MsgBox(Ctl.Address[1])      ; 192
         * 
         * Ctl.Address[1] := 78        ; updates first octet
         * Ctl.Address := "8.8.8.8"    ; assigns a new address
         * Ctl.Address := [8, 8, 8, 8] ; alternative array syntax 
         */
        Address[Octet?] {
            get {
                AddrWord := Buffer(4)
                SendMessage(Controls.IPM_GETADDRESS, 0, AddrWord, this)
                if (!IsSet(Octet)) {
                    return Format("{}.{}.{}.{}",
                            NumGet(AddrWord, 3, "UChar"),
                            NumGet(AddrWord, 2, "UChar"),
                            NumGet(AddrWord, 1, "UChar"),
                            NumGet(AddrWord, 0, "UChar"))
                }
                if (!IsInteger(Octet)) {
                    throw TypeError("Expected an Integer",, Type(Octet))
                }
                if ((Octet < 1) || (Octet > 4)) {
                    throw ValueError("Expected value between 1 and 4",, Octet)
                }
                return NumGet(AddrWord, 4 - Octet, "UChar")
            }

            set {
                if (IsSet(Octet)) {
                    if (!IsInteger(value) || (value < 0) || (value > 255)) {
                        throw ValueError("Invalid octet value",, value)
                    }
                    AddrWord := Buffer(4)
                    SendMessage(Controls.IPM_GETADDRESS, 0, AddrWord, this)
                    NumPut("UChar", value, AddrWord, 4 - Octet)
                    IPAddr := NumGet(AddrWord, 0, "UInt")
                    SendMessage(Controls.IPM_SETADDRESS, 0, IPAddr, this)
                    return value
                }

                if (value is String) {
                    value := StrSplit(value, ".")
                }
                if (!(value is Array)) {
                    throw TypeError("Expected an Array",, Type(value))
                }
                if (value.Length != 4) {
                    throw ValueError("invalid IPv4 address")
                }

                IPAddr := 0
                for Byte in value {
                    if (!IsInteger(Byte)) {
                        throw TypeError("Expected an Integer",, Type(Byte))
                    }
                    if ((Byte < 0) || (Byte > 255)) {
                        throw ValueError("Expected (0 <= Byte <= 255)",, Byte)
                    }

                    IPAddr <<= 8
                    IPAddr += Byte
                }
                SendMessage(Controls.IPM_SETADDRESS, 0, IPAddr, this)
            }
        }

        /**
         * Clears the contents of the IP address control.
         */
        Clear() {
            SendMessage(Controls.IPM_CLEARADDRESS, 0, 0, this)
        }

        /**
         * Determines whether all fields in the IP address control are blank.
         * 
         * @returns {Boolean}
         */
        IsBlank => !!SendMessage(Controls.IPM_ISBLANK, 0, 0, this)

        /**
         * Sets the keyboard focus to the specified field in the IP address
         * control. All of the text in that field will be selected.
         * 
         * @param   {Integer}  Index  index of the field to set
         */
        Focus(Index) {
            if (!IsInteger(Index) || (Index < 1) || (Index > 4)) {
                throw ValueError("invalid index")
            }
            SendMessage(Controls.IPM_SETFOCUS, Index - 1, 0, this)
        }

        /**
         * Sets the valid range for the specified field in the IP address
         * control.
         * 
         * @param  {Integer}  Index  index of the field to set (1-based)
         * @param  {Integer}  Lo     lower limit of the range
         * @param  {Integer}  Hi     upper limit of the range
         */
        SetRange(Index, Lo := 0, Hi := 255) {
            if ((Lo < 0) || (Lo > 255) || (Hi < 0) || (Hi > 255)) {
                throw ValueError("invalid range",, Lo . " - " . Hi)
            }
            lParam := Lo | (Hi << 8)
            SendMessage(Controls.IPM_SETRANGE, Index - 1, lParam, this)
        }

        /**
         * Registers a callback function to be called when the 
         * 
         * @param   {Func}      Fn   the function to be called
         * @param   {Integer?}  Opt  add/remove the callback
         * @returns {Gui.Event}
         */
        OnFieldChange(Fn, Opt?) {
            GetMethod(Fn)
            return Gui.Event.OnNotify(this, Controls.IPN_FIELDCHANGED,
                (IpAddrCtl, lParam) => Fn(IpAddrCtl, NMIPADDRESS(lParam)))
        }
    }
} ; class Gui
} ; class Tanuki_IPv4 extends AquaHotkey
