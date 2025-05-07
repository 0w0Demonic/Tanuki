/**
 * 
 */
class Text {
    /**
     * 
     */
    ApplyTheme(Theme) {
        Theme := Tanuki.PrepareSubTheme(Theme, "Text")
        Tanuki.ApplyFont(this, Theme)
        if (HasProp(Theme, "Background")) {
            this.Opt("Background" . Theme.Background)
        }
        return Theme
    }


}