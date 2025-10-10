#Requires AutoHotkey v2.0

#Include <Tanuki\util\PropertySheet>
#Include <Tanuki\util\PropertySheetPage>
#Include <Tanuki\util\Dump>

#Include <AquaHotkey\Src\Builtins\Buffer> ; for hexdumps

Btn := DialogItem.Button()
  .Position(20, 20)
  .Size(50, 50)
  .ControlId(1)
  .Text("Sample Text")
  .Build()

Dlg := Dialog()
  .Size(50, 50)
  .Font("Cascadia Code", 10)
  .Title("Dlg Title")
  .Controls(Btn)
  .Build()

Page1 := PropertySheetPage()
  .Title("Page 1")
  .Dialog(Dlg)
  .DialogProc((*) {
    ToolTip("dummy proc")
  })
  .HeaderTitle("Header Title", "Header Subtitle")

PropSheet := PropertySheet()
  .Title("My Property Sheet")
  .Pages(Page1)

MsgBox(ClipboardAll(Dlg.Ptr, Dlg.Size).HexDump())
MsgBox(PropSheet.DumpProps())
MsgBox("return code: " . Controls.PropertySheetW(PropSheet))

^+a:: {
    ExitApp()
}