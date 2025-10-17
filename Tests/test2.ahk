#Include <Tanuki\Gui\Dialog>
#Include <Tanuki\Gui\DialogItem>
#Include <Tanuki\Gui\PropertySheet>
#Include <Tanuki\Gui\PropertySheetPage>
#Include <Tanuki\Wip\Wizard>

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
    return Dlg
}

#Include <AhkWin32Projection\Windows\Win32\UI\Controls\NMHDR>
#Include <AhkWin32Projection\Windows\Win32\Graphics\Gdi\Apis>

#Include <Tanuki\util\WindowProcedure>

class DialogProc extends WindowProcedure {
    static __New() {
        super.__New(&Msg, &Ntf, &Cmd)
        
        Cmd(1, WindowsAndMessaging.BN_CLICKED, (*) => ToolTip("click!"))

        Ntf(0, Controls.PSN_QUERYCANCEL, (*) => ToolTip("cancel!"))
    }
}

Proc := DialogProc()

GetPage(Title, Text) {
    return PropertySheetPage()
        .Dialog(GetDlg(Title, Text))
        .DialogProc(ObjBindMethod(Proc))
        .HeaderTitle("Title", "Subtitle")
}

Page := GetPage("Page 1", "Text 1")
Page.dwFlags |= Controls.PSP_USEHEADERSUBTITLE | Controls.PSP_USEHEADERTITLE

Wiz := AeroWizard()
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
Wiz.dwFlags |= Controls.PSH_MODELESS

Bitmap := LoadPicture("C:\Users\roemer\Pictures\graph.bmp")
Wiz.HeaderImage(Bitmap)

hPropSheet := Controls.PropertySheetW(Wiz)

^+a:: {
    ExitApp()
}