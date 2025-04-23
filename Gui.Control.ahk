
/**
 * Defines new properties and methods for class `Gui.Control`.
 */
class Control {
    /**
     * Sets various options and styles for the appearance and behaviour
     * of the control, additionally allowing the use of Gui themes.
     */
    Opt(Options) {
        HasTheme := Tanuki.ParseGuiOptions(&Options, &Theme)
        (Tanuki.Gui_Old.Control.Prototype.Opt)(this, Options)
        (HasTheme && (this.Theme := Theme))
    }

    /**
     * Sets the theme of the Gui control.
     * 
     * @param   {Object/String}  value  the theme to apply
     */
    Theme {
        set {
            Theme := this.ApplyTheme(Tanuki.LoadTheme(value))
            this.DefineProp("Theme", {
                Get: (Instance) => Theme.Clone()
            })
        }
    }

    /**
     * Shared `.ApplyTheme()` between Gui controls that does nothing.
     * 
     * @param   {Object}  Theme  the theme to apply
     */
    ApplyTheme(Theme) {
        return
    }

    /**
     * Returns the character length of the control text.
     * 
     * @return  {Integer}
     */
    TextLength { ; TODO rename to `StrLen()`?
        get {
            static WM_GETTEXTLENGTH := 0x000E
            return SendMessage(WM_GETTEXTLENGTH, 0, 0, this)
        }
    }

    /**
     * 
     */
    Style {
        get => ControlGetStyle(this)
        set => ControlSetStyle(value, this)
    }

    /**
     * 
     */
    ExStyle {
        get => ControlGetExStyle(this)
        set => ControlSetExStyle(value, this)
    }

    ; TODO a bunch of other common control messages
}