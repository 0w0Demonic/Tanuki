
class StaticControl extends AquaHotkey_MultiApply {
    static __New() => super.__New(Tanuki.Gui.Text,
                                  Tanuki.Gui.Picture)

    class Style {
        static Left             => 0x0000
        static Center           => 0x0001
        static Right            => 0x0002
        static Icon             => 0x0003
        static BlackRect        => 0x0004
        static GrayRect         => 0x0005
        static WhiteRect        => 0x0006
        static BlackFrame       => 0x0007
        static GrayFrame        => 0x0008
        static WhiteFrame       => 0x0009
        static UserItem         => 0x000A
        static Simple           => 0x000B
        static LeftNoWordWrap   => 0x000C
        static OwnerDraw        => 0x000D
        static Bitmap           => 0x000E
        static EnhancedMetaFile => 0x000F
        static EtchedHorizontal => 0x0010
        static EtchedVertical   => 0x0011
        static EtchedFrame      => 0x0012
        static TypeMask         => 0x001F

        static RealSizeControl  => 0x0040
        static NoPrefix         => 0x0080

        static Notify           => 0x0100
        static CenterImage      => 0x0200
        static RightJust        => 0x0400
        static RealSizeImage    => 0x0800
        static Sunken           => 0x1000
        static EditControl      => 0x2000
        static EndEllipsis      => 0x4000
        static PathEllipsis     => 0x8000
        static WordEllipsis     => 0xC000
        static EllipsisMask     => 0xC000
    }

    OnClick(Callback, AddRemove?) {
        static STN_CLICKED := 0x0000
        try this.Style |= Gui.StaticControl.Style.Notify
        return Gui.Event.OnCommand(this, STN_CLICKED, Callback, AddRemove?)
    }

    OnDoubleClick(Callback, AddRemove?) {
        static STN_DBLCLK := 0x0001
        try this.Style |= Gui.StaticControl.Style.Notify
        return Gui.Event.OnCommand(this, STN_DBLCLK, Callback, AddRemove?)
    }

    OnEnable(Callback, AddRemove?) {
        static STN_ENABLE := 0x0002
        try this.Style |= Gui.StaticControl.Style.Notify
        return Gui.Event.OnCommand(this, STN_ENABLE, Callback, AddRemove?)
    }

    OnDisable(Callback, AddRemove?) {
        static STN_DISABLE := 0x0002
        try this.Style |= Gui.StaticControl.Style.Notify
        return Gui.Event.OnCommand(this, STN_DISABLE, Callback, AddRemove?)
    }
}