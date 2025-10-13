#Include <Tanuki\util\Dialog>
#Include <Tanuki\util\DialogItem>
#Include <Tanuki\util\PropertySheet>
#Include <Tanuki\util\PropertySheetPage>
#Include <Tanuki\util\Wizard>


#Include <AhkWin32Projection\Windows\Win32\UI\Controls\INITCOMMONCONTROLSEX>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\INITCOMMONCONTROLSEX_ICC>

ICC := INITCOMMONCONTROLSEX()
ICC.dwSize := INITCOMMONCONTROLSEX.sizeof
ICC.dwICC := INITCOMMONCONTROLSEX_ICC.ICC_WIN95_CLASSES

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
    Dlg.style |= WindowsAndMessaging.DS_CONTROL
    Dlg.style |= WindowsAndMessaging.DS_3DLOOK
    return Dlg
}

#Include <AhkWin32Projection\Windows\Win32\UI\Controls\NMHDR>
#Include <AhkWin32Projection\Windows\Win32\Graphics\Gdi\Apis>

GetPage(Title, Text) {
    return PropertySheetPage()
        .Dialog(GetDlg(Title, Text))
        .DialogProc((Hwnd, Msg, wParam, lParam) {
            if (Msg == WindowsAndMessaging.WM_NOTIFY) {
                Hdr := NMHDR(lParam)
                if (Hdr.Code == Controls.PSN_HELP) {
                    MsgBox("Help!")
                }
                if (Hdr.Code == Controls.PSN_QUERYCANCEL) {
                    MsgBox("Want cancel!")
                    return true
                }
            }

            if (Msg == WindowsAndMessaging.WM_CLOSE) {
                return false
            }
            if (Msg != WindowsAndMessaging.WM_COMMAND) {
                return false
            }
            if ((wParam >>> 16) == WindowsAndMessaging.BN_CLICKED) {
                MsgBox(lParam . " was clicked!")
                return false
            }
        })
        .HeaderTitle("Title", "Subtitle")
}

Page := GetPage("Page 1", "Text 1")
Page.dwFlags |= Controls.PSP_USEHEADERSUBTITLE | Controls.PSP_USEHEADERTITLE


Wiz := Wizard97()
    .Title("Cool title")
    .Pages(
        Page,
        GetPage("Page 2", "Text 2")
    )
    ;.RemoveContextHelp()
    ;.RemoveApplyButton()
    ;.HasHelp()
    ;.Resizable()

#Include <Tanuki\util\Dump>

Wiz.dwFlags |= Controls.PSH_HEADER

MsgBox(Wiz.dwFlags & Controls.PSH_WATERMARK)

Wiz.dwFlags |= Controls.PSH_MODELESS

Bitmap := LoadPicture("C:\Users\roemer\Pictures\graph.bmp")
Wiz.HeaderImage(Bitmap)

hPropSheet := Controls.PropertySheetW(Wiz)

^+a:: {
    ExitApp()
}