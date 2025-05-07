/**
 * Adds a ListView control to the Gui.
 * 
 * @param   {String?}  Opt    additional options
 * @param   {Array?}   Items  a list of items
 * @return  {Gui.ListView}
 */
AddListView(Opt?, Items?) => this.Add("ListView", Opt?, Items?)

class ListView {
    ; TODO Font.Color should override Foreground
    ApplyTheme(Theme) {
        static LVS_EX_DOUBLEBUFFER := 0x00010000
        static NM_CUSTOMDRAW       := -12
        static UIS_SET             := 0x0001
        static UISF_HIDEFOCUS      := 0x0001
                                   
        static WM_CHANGEUISTATE    := 0x0127
        static WM_NOTIFY           := 0x004E
        static WM_THEMECHANGED     := 0x031A
                                   
        static LVM_SETBKCOLOR      := 0x1001
        static LVM_SETTEXTCOLOR    := 0x1024
        static LVM_SETTEXTBKCOLOR  := 0x1026
        static LVM_GETHEADER       := 0x101F

        DllCall("uxtheme\SetWindowTheme",
                "Ptr", this.Hwnd,
                "Str", "",
                "Ptr", 0)
        
        Theme := Tanuki.PrepareSubTheme(Theme, "ListView")

        if (HasProp(Theme, "Background")) {
            this.Opt("Background" . Theme.Background)
            Background := Tanuki.Swap_RGB_BGR(Theme.Background)
            SendMessage(LVM_SETBKCOLOR, 0, Background, this)

            if (!HasProp(Theme, "TextBackground")) {
                SendMessage(LVM_SETTEXTBKCOLOR, 0, Background, this)
            }
        }

        if (HasProp(Theme, "TextBackground")) {
            TextBackground := Tanuki.Swap_RGB_BGR(Theme.TextBackground)
            SendMessage(LVM_SETTEXTBKCOLOR, 0, TextBackground, this)
        }

        this.OnMessage(WM_THEMECHANGED, (*) => 0)

        HeaderHwnd := SendMessage(LVM_GETHEADER, 0, 0, this)
        DllCall("uxtheme\SetWindowTheme",
                "Ptr", HeaderHwnd,
                "Str", "",
                "Ptr", 0)

        if (HasProp(Theme, "Foreground")) {
            Foreground := Tanuki.Swap_RGB_BGR(Theme.Foreground)
            SendMessage(LVM_SETTEXTCOLOR, 0, Foreground, this)
            ; >>>>
            this.OnMessage(WM_NOTIFY, (Hwnd, wParam, lParam, Msg) {
                static CDDS_PREPAINT          := 0x00000001
                static CDDS_POSTPAINT         := 0x00000002
                static CDDS_ITEMPREPAINT      := 0x00010001
                static CDDS_SUBITEM           := 0x00020000

                static CDRF_DODEFAULT         := 0x00000000
                static CDRF_NEWFONT           := 0x00000002
                static CDRF_SKIPDEFAULT       := 0x00000004
                static CDRF_NOTIFYPOSTPAINT   := 0x00000010
                static CDRF_NOTIFYITEMDRAW    := 0x00000020
                static CDRF_NOTIFYSUBITEMDRAW := 0x00000020

                static DCBrush := DllCall("GetStockObject", "UInt", 18)

                Code := StructFromPtr(NMHDR, lParam).Code
                if (Code != NM_CUSTOMDRAW) {
                    return
                }

                nmcd  := StructFromPtr(NMCUSTOMDRAW, lParam)
                if (nmcd.hdr.HwndFrom != HeaderHwnd) {
                    return CDRF_DODEFAULT
                }
                Stage := nmcd.dwDrawStage

                if (Stage == CDDS_PREPAINT) {
                    return CDRF_NOTIFYITEMDRAW | CDRF_NOTIFYPOSTPAINT
                }
                if (Stage == CDDS_ITEMPREPAINT) {
                    hDC := nmcd.hDC
                    rc  := nmcd.rc

                    Item := HDITEM()
                    VarSetStrCapacity(&ItemTxt, 520)
                    Item.mask := 0x86
                    Item.pszText := StrPtr(ItemTxt)
                    Item.cchTextMax := 260
                    SendMessage(0x120B, nmcd.dwItemSpec, ObjGetDataPtr(Item), HeaderHwnd)

                    VarSetStrCapacity(&ItemTxt, -1)
                    
                    DC := Gdi.DeviceContext.FromHandle(hDC)

                    DllCall("SetDCBrushColor", "Ptr", hDC, "UInt", TextBackground)
                    DllCall("FillRect", "Ptr", hDC, RECT, nmcd.rc, "Ptr", DCBrush)

                    NewRc := RECT()
                    DllCall("CopyRect", RECT, NewRc, RECT, Rc)

                    DllCall("SetBkMode", "Ptr", hDC, "UInt", 0)
                    DllCall("SetTextColor", "Ptr", hDC, "Uint", Foreground)

                    DllCall("DrawText", "Ptr", hDC, "Ptr", StrPtr(ItemTxt),
                            "Int", StrLen(ItemTxt), RECT, NewRc, "UInt", 0x0204)
                    
                    return CDRF_SKIPDEFAULT
                }
                if (Stage == CDDS_POSTPAINT) {
                    ClientRc   := RECT()
                    LastItemRc := RECT()

                    DllCall("GetClientRect", "Ptr", HeaderHwnd, RECT, ClientRc)
                    Count := SendMessage(0x1200, 0, 0, HeaderHwnd)
                    SendMessage(0x1207, Count - 1, ObjGetDataPtr(LastItemRc), HeaderHwnd)

                    R1 := ClientRc.Right
                    R2 := LastItemRc.Right
                    if (R2 < R1) {
                        hDC           := nmcd.hDC
                        ClientRc.Left := R2

                        DllCall("SetDCBrushColor", "Ptr", hDC, "UInt", TextBackground)
                        DllCall("FillRect", "Ptr", hDC, RECT, ClientRc, "Ptr", DCBrush)
                    }
                    return CDRF_SKIPDEFAULT
                }
                return CDRF_DODEFAULT
            })
            ; <<<<
        }

        this.Opt("+LV" . LVS_EX_DOUBLEBUFFER)
        UIState := (UIS_SET << 8) | UISF_HIDEFOCUS
        SendMessage(WM_CHANGEUISTATE, UIState, 0, this)

    }

    ; TODO
    class Style {
        static Icon                => 0x0000
        static Report              => 0x0000
        static SmallIcon           => 0x0000
        static List                => 0x0000
        static TypeMask            => 0x0000
        
        static SingleSelection     => 0x0000
        static AlwaysShowSelection => 0x0000
        static SortAscending       => 0x0000
        static SortDescending      => 0x0000
        static NoLabelWrap         => 0x0000
        static AutoArrange         => 0x0000
        static EditLabels          => 0x0000
        static OwnerData           => 0x0000
        static NoScroll            => 0x0000
        static TypeStyleMask       => 0x0000
        static AlignTop            => 0x0000
        static AlignLeft           => 0x0000
        static AlignMask           => 0x0000
        static OwnerDrawFixed      => 0x0000
        static NoColumnHeader      => 0x0000
        static NoSortHeader        => 0x0000
    }
}