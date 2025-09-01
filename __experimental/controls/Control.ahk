
/**
 * 
 */
class Control {
    Opt(Options) {
        Tanuki.Theme.Parse(&Options, &Theme)
        (Tanuki.GuiOld.Control.Prototype.Opt)(this, Options)
        if (Theme) {
            this.Theme := Theme
        }
    }

    Theme {
        get => Object()
        set {
            Theme := this.ApplyTheme(Theme)

            (Object.Prototype.DefineProp)(this, "Theme", {
                Get: (_) => Theme.Clone()
            })
        }
    }

    ApplyTheme(Theme) {
        return
    }

    ; TODO lots of generic WIN32 control stuff here

    Style {
        get => ControlGetStyle(this)
        set => ControlSetStyle(value, this)
    }

    ExStyle {
        get => ControlGetExStyle(this)
        set => ControlSetExStyle(value, this)
    }

    ; TODO alignment stuff here?
}