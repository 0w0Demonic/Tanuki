/**
 * 
 */
AddListBox(Opt?, Items?) => this.Add("ListBox", Opt?, Items?)

class ListBox {
    ApplyTheme(Theme) {
        Theme := Tanuki.PrepareSubTheme(Theme, "ListBox")
        Tanuki.ApplyFont(this, Theme)
        if (HasProp(Theme, "Background")) {
            this.Opt("Background" . Theme.Background)
        }
    }

    ; LB_OKAY
    ; LB_ERR
    ; LB_ERRSPACE

    OnClick(Callback, AddRemove?) {
        
    }

    OnDoubleClick() {

    }

    OnCancel() {

    }

    OnFocus() {

    }

    OnFocusLost() {

    }

    ; ...

    class Style {
        static Notify            => 0x0000
        static Sort              => 0x0000
        static NoRedraw          => 0x0000
        static MultipleSelection => 0x0000
        static OwnerDrawFixed    => 0x0000
        static OwnerDrawVariable => 0x0000
        static HasStrings        => 0x0000
        static UseTabStops       => 0x0000
        static NoIntegralHeight  => 0x0000
        static MultiColumn       => 0x0000
        static WantKeyboardInput => 0x0000
        static ExtendedSelection => 0x0000
        static DisableNoScroll   => 0x0000
        static NoData            => 0x0000
        static NoSelection       => 0x0000
        static ComboBox          => 0x0000
        static Standard          => 0x0000
    }

    EnableDrag() {
        static DRAGLISTMSGSTRING := "commctrl_DragListMsg"
        DllCall("MakeDragList", "Ptr", this.Hwnd)
        m := DllCall("RegisterWindowMessage", "Str", DRAGLISTMSGSTRING)
        this.DefineProp("DragListMessage", { Get: (Instance) => m })
    }

    IsDragList {
        get => !!this.DragListMessage
        set {
            if (value) {
                this.EnableDrag()
            }
        }
    }

    DragListMessage => 0

    ; TODO these don't work

    CreateDragEvent(NotifyCode, Callback, AddRemove?) {
        return Gui.Event.OnMessage(this.Gui, this.DragListMessage,
                                   DragEvent, AddRemove?)

        DragEvent(GuiObj, wParam, lParam, Hwnd) {
            Info := StructFromPtr(DRAGLISTINFO, lParam)
            if (Info.Hwnd != this.Hwnd) {
                return
            }
            if (Info.uNotification != NotifyCode) {
                return
            }
            return Callback(this, Info.ptCursor)
        }
    }

    OnDragBegin(Callback, AddRemove?)  {
        static DL_BEGINDRAG := 0x0400 + 133
        return this.CreateDragEvent(DL_BEGINDRAG, Callback, AddRemove?)
    }

    OnDrag(Callback, AddRemove?) {
        static DL_DRAGGING := 0x0400 + 134
        return this.CreateDragEvent(DL_DRAGGING, Callback, AddRemove?)
    }

    OnDropped(Callback, AddRemove?) {
        static DL_DROPPED := 0x0400 + 135
        return this.CreateDragEvent(DL_DROPPED, Callback, AddRemove?)
    }

    OnDragCancel(Callback, AddRemove?) {
        static DL_CANCELDRAG := 0x0400 + 136
        return this.CreateDragEvent(DL_CANCELDRAG, Callback, AddRemove?)
    }

    ; TODO return values
    ; DL_CURSORSET...
}