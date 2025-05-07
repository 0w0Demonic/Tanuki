/**
 * 
 */
AddUpDown(Opt?, StartVal?) => this.Add("UpDown", Opt?, StartVal?)

class UpDown {
    ApplyTheme(Theme) {
        Theme := Tanuki.PrepareSubTheme(Theme, "UpDown")
        Tanuki.ApplyFont(this, Theme)
        if (HasProp(Theme, "Background")) {
            this.Opt("Background" . Theme.Background)
        }
        return Theme
    }

    class Style {
        static Wrap        => 0x0001
        static SetBuddyInt => 0x0002
        static AlignLeft   => 0x0004
        static AlignRight  => 0x0008
        static AutoBuddy   => 0x0010
        static ArrowKeys   => 0x0020
        static Horizontal  => 0x0040
        static NoThousands => 0x0080
        static HotTrack    => 0x0100
    }
}