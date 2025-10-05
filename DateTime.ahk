#Include <AquaHotkey>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\NMDATETIMECHANGE_FLAGS>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\Apis>
#Include <AhkWin32Projection\Windows\Win32\Foundation\SYSTEMTIME>

class Tanuki_DateTime extends AquaHotkey_MultiApply {
    static __New() => super.__New(Gui.DateTime)

    GetSystemTime(&Time) {
        Result := SendMessage(Controls.DTM_GETSYSTEMTIME, 0, Time := SYSTEMTIME(), this)
        return (Result == NMDATETIMECHANGE_FLAGS.GDT_VALID)
    }

    SetSystemTime(Time?) {
        if (!IsSet(Time)) {
            return SendMessage(Controls.DTM_SETSYSTEMTIME, NMDATETIMECHANGE_FLAGS.NONE, 0, this)
        }
        if (!(Time is SYSTEMTIME)) {
            throw TypeError("Expected a SYSTEMTIME",, Type(Time))
        }
        return SendMessage(Controls.DTM_SETSYSTEMTIME, NMDATETIMECHANGE_FLAGS.GDT_VALID, Time, this)
    }

    GetRange(&MinTime, &MaxTime) {
        Buf := Buffer(2 * SYSTEMTIME.sizeof, 0)
        Arr := Win32FixedArray(Buf.Ptr, 2, SYSTEMTIME)
        Result := SendMessage(Controls.DTM_GETRANGE, 0, Arr)
        if (Result & Controls.GDTR_MIN) {
            MinTime := Arr[1]
        }
        if (Result & Controls.GDTR_MAX) {
            MaxTime := Arr[2]
        }
        return Result
    }

}