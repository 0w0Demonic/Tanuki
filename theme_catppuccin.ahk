
class Catppuccin {
    static Background => "0x1E1E2E"
    static Foreground => "0xE0E0E0"
    static DarkMode   => true

    class Button {
        static Background => "0xa600ff"
    }

    class Edit {
        static Background => "0x1E1E2E"
        static DarkMode   => true

        class Font {
            static Color => "0xb5c67c"
            static Name  => "Cascadia Code"
        }
    }

    class Text {
        static Background => "0x251E2E"

        class Font {
            static Color   => "0xbba07a"
            static Name    => "Segoe UI"
            static Size    => 10
            static Quality => "Default"
        }
    }

    class DDL {
        static Background => "0x404040"
        static DarkMode   => false

        class Font {
            static Color => "0xE0E0E0"
        }
    }

    class MonthCal {
        static Background   => "0x202040"
        static MonthBackground => "0x303050"
        static TrailingText => "0x8fd398"
        static Foreground   => "0xbcb287"
    }

    class Slider {
        ; TODO naming scheme of this
        static Background => "0xa06060"
        static Foreground => "0x202020"
    }

    class ListView {
        static Background     => "0x1f283f"
        static TextBackground => "0x3d0000"
        static Foreground     => "0xc687c6"

        class Font {
            static Size => 8
        }
    }
}