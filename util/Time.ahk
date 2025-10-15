#Include <AquaHotkey>
#Include <AhkWin32Projection\Windows\Win32\Foundation\SYSTEMTIME>
#Include <AhkWin32Projection\Windows\Win32\Foundation\FILETIME>
#Include <AhkWin32Projection\Windows\Win32\System\SystemInformation\Apis>
#Include <AhkWin32Projection\Windows\Win32\System\Time\Apis>

/**
 * 
 */
class Tanuki_Ext_SYSTEMTIME extends AquaHotkey_MultiApply {
    static __New() => super.__New(SYSTEMTIME)

    static Now() {
        SystemInformation.GetSystemTime(St := this())
        return St
    }

    ToString(Fmt := "yyyy.MM.dd HH:mm:ss") {
        return FormatTime(Format("{}{:02}{:02}{:02}{:02}{:02}",
                Min(this.wYear, 9999),
                this.wMonth,
                this.wDay,
                this.wHour,
                this.wMinute,
                this.wSecond), Fmt)
    }

    ToFileTime() {
        Time.SystemTimeToFileTime(this, Ft := FILETIME())
        return Ft
    }
}

class Tanuki_Ext_FILETIME extends AquaHotkey_MultiApply {
    static __New() => super.__New(FILETIME)

    static Now() {
        SystemInformation.GetSystemTimeAsFileTime(Ft := this())
        return Ft
    }
}

Now := SYSTEMTIME.Now().ToFileTime()
