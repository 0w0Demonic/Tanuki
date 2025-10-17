#Requires AutoHotkey v2.0
#Include <AquaHotkey>
#Include <Tanuki\Util\Event>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\DRAGLISTINFO>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\DRAGLISTINFO_NOTIFICATION_FLAGS>

/**
 * 
 */
class Tanuki_ListBox extends AquaHotkey {
class Gui {
    /**
     * 
     */
    AddDragList(Opt?, Items?) {
        ListBox := this.AddListBox(Opt?, Items?)
        if (!Controls.MakeDragList(ListBox.Hwnd)) {
            throw Error("Unable to create drag list")
        }
        ObjSetBase(ListBox, Gui.DragList.Prototype)
        return ListBox
    }

    class DragList extends Gui.ListBox {
        /**
         * 
         */
        static MessageNumber {
            get {
                Msg := WindowsAndMessaging.RegisterWindowMessageW(
                                Controls.DRAGLISTMSGSTRING)
                this.DefineProp("MessageNumber", { Get: (_) => Msg })
                
                return Msg
            }
        }

        /**
         * 
         */
        Type => "DragList"

        /**
         * 
         */
        ItemAt(Pt, AutoScroll := true) {
            if (!(Pt is POINT)) {
                throw TypeError("Expected a POINT",, Type(Pt))
            }
            return (Controls.LBItemFromPt(this.Hwnd, Pt, !!AutoScroll) + 1)
        }

        /**
         * 
         * @param   {Integer}  Index  index of the item to be drawn (1-based)
         */
        DrawInsert(Index) {
            if (!IsInteger(Index)) {
                throw TypeError("Expected an Integer",, Type(Index))
            }
            Controls.DrawInsert(this.Gui.Hwnd, this.Hwnd, Index - 1)
        }
    }
} ; class Gui
} ; class Tanuki_DragList extends AquaHotkey

G := Gui()
Arr := Array()
Loop 50 {
    Arr.Push(A_Index)
}
DL := G.AddDragList("w600 h600", Arr)
G.OnMessage(Gui.DragList.MessageNumber, (GuiObj, wParam, lParam, Msg) {
    Info := DRAGLISTINFO(lParam)

    switch (Info.uNotification)
    {
    case DRAGLISTINFO_NOTIFICATION_FLAGS.DL_BEGINDRAG:
        return true
    case DRAGLISTINFO_NOTIFICATION_FLAGS.DL_DRAGGING:
        Pt := Info.ptCursor
        DllCall("ScreenToClient", "Ptr", DL.Hwnd, "Ptr", Pt)
        Item := Controls.LBItemFromPt(DL.Hwnd, Pt, false)
        if (Item != -1) {
            MsgBox()
        }
    }
})

G.Show()

^+a:: {
    ExitApp()
}