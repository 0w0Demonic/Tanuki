; class Tanuki {
;     class Gui {


/**
 * 
 */
AddButton(Opt?, Txt?) {
    return this.Add("Button", Opt?, Txt?)
}

/**
 * 
 */
class Button {
    ApplyTheme(Theme) {
        Theme := Tanuki.Theme.Search(Theme, "Button")
        Tanuki.Theme.ApplyFont(this, Theme)
    }
}

;     } ; class Gui
; } ; class Tanuki