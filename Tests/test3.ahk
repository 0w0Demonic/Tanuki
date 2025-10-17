#Requires AutoHotkey v2.0
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\DLG_DIR_LIST_FILE_TYPE>
#Include <AhkWin32Projection\Windows\Win32\UI\WindowsAndMessaging\Apis>
#Include <Tanuki\Gui\Dialog>
#Include <Tanuki\Gui\DialogItem>

GetDlg(Title, Text) {
    Dlg := Dialog()
        .Small()
        .Font("MS Shell Dlg", 8)
        .Title(Title)
        .Controls(
            DialogItem.Button(Text, true)
                .Position(50, 50)
                .Size(80, 20)
                .Id(1)
        )
    return Dlg
}

DlgProc(hwnd, msg, wp, lp) {
    if (msg = 0x110)
        return 1
    if (msg = 0x111 && (wp & 0xFFFF) = 1) {
        DllCall("EndDialog", "ptr", hwnd, "int", 1)
        return 1
    }
    if (msg = 0x10) {
        DllCall("EndDialog", "ptr", hwnd, "int", 0)
        return 1
    }
    return 0
}

TestDialog() {
    GetItem(x, y) {
        return DialogItem.ListBox()
                .Position(x, y)
                .Size(180, 12)
                .Style(0x50000000, 0)
                .Id(1001)
                .Text("This is a DLGTEMPLATE test")
                .Build()
    }

    Dlg := Dialog()
        .Position(0, 0)
        .Size(200, 100)
        .Style(0x80C800C4, 0)
        .Font("MS Shell Dlg", 8)
        .Title("Test Dialog")
        .Controls(GetItem(10, 10))
        .Build()

    cb := CallbackCreate(DlgProc, "F", 4)
    Result := WindowsAndMessaging.DialogBoxIndirectParamW(0, Dlg, 0, Cb, 0)
    MsgBox(Result)
    CallbackFree(cb)
}

; TestDialog()

G := Gui()
LB := G.AddListBox()
G.Show()

ID := WindowsAndMessaging.GetDlgCtrlID(LB.Hwnd)

MsgBox(Controls.DlgDirListW(
        G.Hwnd,
        "C:\Users\roemer\Desktop",
        ID,
        0,
        DLG_DIR_LIST_FILE_TYPE.DDL_DIRECTORY
))