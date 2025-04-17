
/**
 * 
 */
AddDropDownList(Opt?, Items?) => this.Add("DropDownList", Opt?, Items?)

/**
 * 
 */
class DDL {
    ApplyTheme(Theme) {
        Theme := Tanuki.PrepareSubTheme(Theme, "DDL")
        Tanuki.ApplyFont(this, Theme)

        if (HasProp(Theme, "Background")) {
            this.Opt("Background" . Theme.Background)
        }

        if (HasProp(Theme, "DarkMode") && Theme.DarkMode) {
            DllCall("uxtheme\SetWindowTheme",
                    "Ptr", this.Hwnd,
                    "Str", "DarkMode_CFD",
                    "Ptr", 0)
        }

        static WM_CTLCOLORLISTBOX := 0x0134
        this.OnMessage(WM_CTLCOLORLISTBOX, RenderListBox, false)
        this.OnMessage(WM_CTLCOLORLISTBOX, RenderListBox)
        return Theme
        
        RenderListBox(LbCtl, wParam, lParam, Hwnd) {
            if (HasProp(Theme, "Font") && HasProp(Theme.Font, "Color"))
            {
                TextColor := Tanuki.Swap_RGB_BGR(Theme.Font.Color)
                DllCall("SetTextColor",
                        "Ptr", wParam,
                        "UInt", TextColor)
            }
            BackgroundColor := Tanuki.Swap_RGB_BGR(Theme.Background)
            return DllCall("CreateSolidBrush", "UInt", BackgroundColor)
        }
    }
}