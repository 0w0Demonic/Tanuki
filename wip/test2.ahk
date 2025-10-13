#Requires AutoHotkey v2.0

#Include <Tanuki\wip\Dialog>
#Include <Tanuki\wip\DialogItem>

#Include <Tanuki\util\PropertySheet>
#Include <Tanuki\util\PropertySheetPage>

Page := PropertySheetPage()
    .Title("Hello, world!")
    .Dialog(Dialog()
        .Size(100, 200)
        .Controls(
            DialogItem()
                .Type(0x0082)
                .Position(10, 10)
                .Size(180, 10)
                .Text("Hello, world!")
                .Id(1)
        )
    )
    .DialogProc((*) => false)

PropSheet := PropertySheet()
    .Title("Cool title")
    .Pages(Page)

MsgBox(Controls.PropertySheetW(PropSheet))