
AddScrollBar(Opt := "") {
    Ctl := g.Add("Custom", "ClassScrollBar " . Opt)
}

class ScrollBar {
    class Style {
        static Horizontal              => 0x0000
        static Vertical                => 0x0001
        static TopAlign                => 0x0002
        static LeftAlign               => 0x0002
        static BottomAlign             => 0x0004
        static RightAlign              => 0x0004
        static SizeBoxTopLeftAlign     => 0x0002
        static SizeBoxButtomRightAlign => 0x0004
        static SizeBox                 => 0x0008
        static SizeGrip                => 0x0010
    }

    Pos {
        get {

        }
        set {

        }
    }

    Range {
        get {

        }
        set {

        }
    }

    EnableArrows(OnOff := true) {

    }

    ScrollInfo {
        get {

        }
        set {

        }
    }

    ScrollBarInfo {
        get {

        }
        set {

        }
    }

    ; SIF_*
    ; typedef struct... SCROLLINFO
}