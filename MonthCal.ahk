/**
 * Adds a calendar control to the Gui.
 * 
 * @param   {String?}  Opt   additional options
 * @param   {String?}  Date  the range of dates available
 * @return  {Gui.MonthCal}
 */
AddMonthCal(Opt?, Date?) => this.Add("MonthCal", Opt?, Date?)

/**
 * 
 */
class MonthCal {
    ApplyTheme(Theme) {
        Theme := Tanuki.PrepareSubTheme(Theme, "MonthCal")
        DllCall("uxtheme\SetWindowTheme",
                "Ptr", this.Hwnd,
                "Str", "",
                "Str", "")

        if (HasProp(Theme, "Background")) {
            SetColor(0, Theme.Background)
        }

        if (HasProp(Theme, "Font") && HasProp(Theme.Font, "Color")) {
            SetColor(1, Theme.Font.Color)
        } else if (HasProp(Theme, "Foreground")) {
            SetColor(1, Theme.Foreground)
        }

        if (HasProp(Theme, "Title") && HasProp(Theme.Title, "Background")) {
            SetColor(2, Theme.Title.Background)
        } else if (HasProp(Theme, "Background")) {
            SetColor(2, Theme.Background)
        }

        if (HasProp(Theme, "Title") && HasProp(Theme.Title, "Foreground")) {
            SetColor(3, Theme.Title.Foreground)
        } else if (HasProp(Theme, "Foreground")) {
            SetColor(3, Theme.Foreground)
        }

        if (HasProp(Theme, "MonthBackground")) {
            SetColor(4, Theme.MonthBackground)
        } else if (HasProp(Theme, "Background")) {
            SetColor(4, Theme.Background)
        }
        
        if (HasProp(Theme, "TrailingText")) {
            SetColor(5, Theme.TrailingText)
        }

        SetColor(Opt, Color) {
            static MCM_SETCOLOR := 0x100A
            SendMessage(0x100A, Opt, Tanuki.Swap_RGB_BGR(Color), this)
        }
    }
}
