/**
 * Adds a new button to the Gui.
 * 
 * @param   {String?}  Opt  additional options
 * @param   {String?}  Txt  the text to display
 * @return  {Gui.Button}
 */
AddButton(Opt?, Txt?) => this.Add("Button", Opt?, Txt?)

/** Defines new properties and methods for `Gui.Button` controls */
class Button {
    /**
     * Applies a theme to the button.
     * 
     * @param   {Object}  Theme  the theme to apply
     * @return  {Object}
     */
    ApplyTheme(Theme) {
        ; TODO background doesn't work
        Theme := Tanuki.PrepareSubTheme(Theme, "Button")
        Tanuki.ApplyFont(this, Theme)

        if (HasProp(Theme, "DarkMode") && Theme.DarkMode) {
            DllCall("uxtheme\SetWindowTheme",
                    "Ptr", this.Hwnd, 
                    "Str", "DarkMode_Explorer",
                    "Ptr", 0)
        }

        if (HasProp(Theme, "Background")) {
            this.Opt("Background" . Theme.Background)
        }
        
        return Theme
    }
}
