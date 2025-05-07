; TODO still looks weird
/**
 * 
 */
AddSlider(Opt?, StartVal?) => this.Add("Slider", Opt?, StartVal?)

class Slider {
    ApplyTheme(Theme) {
        Theme := Tanuki.PrepareSubTheme(Theme, "Slider")

        if (HasProp(Theme, "Background")) {
            this.Opt("Background" . Theme.Background)
        }
        if (HasProp(Theme, "Foreground")) {
            this.Opt("c" . Theme.Foreground)
        }
    }

    class Style {
        static AutoTicks             => 0x0000
        static Vertical              => 0x0000
        static Horizontal            => 0x0000
        static Top                   => 0x0000
        static Bottom                => 0x0000
        static Left                  => 0x0000
        static Right                 => 0x0000
        static Both                  => 0x0000
        static NoTicks               => 0x0000
        static EnableSelectionRange  => 0x0000
        static FixedLength           => 0x0000
        static NoThumb               => 0x0000
        static ToolTips              => 0x0000
        static Reversed              => 0x0000
        static DownIsLeft            => 0x0000
        static NotifyBeforeMove      => 0x0000
        static TransparentBackground => 0x0000
    }
}

