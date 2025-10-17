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
    class FileList extends Gui.ListBox {
        Type => "FileList"
    } ; class FileList extends Gui.ListBox

    class ListBox {
        ; TODO probably make this a separate class to deal with the "TextControl" part
        DirList(FilePath, FileTypes := 0, TextControl?) {
            if (!(FilePath is String)) {
                throw TypeError("Expected a String",, Type(FilePath))
            }
            if (!IsInteger(FileTypes)) {
                throw TypeError("Expected an Integer",, Type(FileTypes))
            }
            IdListBox := WindowsAndMessaging.GetDlgCtrlID(this.Hwnd)
            IdStatic := IsSet(TextControl) && WindowsAndMessaging.GetDlgCtrlID(TextControl.Hwnd)

            if (!Controls.DlgDirListW(this.Gui.Hwnd, FilePath, IdListBox, IdStatic, FileTypes)) {
                throw OSError(A_LastError)
            }
        }
    } ; class ListBox

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
    } ; class DragLst extends Gui.ListBox
} ; class Gui
} ; class Tanuki_DragList extends AquaHotkey

G := Gui()
Txt := G.AddText("w350 r2")
LB := G.AddListBox("w350 h350")
LB.DirList("C:\Users\roemer\Desktop", unset, Txt)
G.Show()

^+b:: {
    MsgBox(ControlGetText(LB))
}

^+a:: {
    ExitApp()
}