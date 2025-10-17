# TODO List

## General

- `ControlSetStyle("+" . Controls..., this)` kind of sucks manually, fix this
- Add property to find out control ID (`GetDlgCtrlID`)
- `Gui#ControlById()`, `Gui.Control#Id { get; }`

## Controls

- Add common COLORREF colors as static params for DateTime.ahk
- Probably split up extension classes for the `Gui.Control` classes because
  they're huge
- resize monthcal dropped down by datetime control when the theme is removed

- Add support for drag lists

## Dialogs

- DateTime Open()
- Improve `DialogItem` with static factories for the commonly used controls
- Add a way to attach menus to dialogs
- Refactor all of the window styles logic in `DialogItem.ahk` into its own thing
- DialogEx

## Misc

- Add Time API for DateTime controls. It should have an easy way of doing
  time arithmetic like e.g. `.PlusDays(4)`
- Add SysLink? It already exists as `Gui.Link`
- BUTTON_SPLITINFO extension

- Add abbreviated version of common classes like `WindowsAndMessaging` simply
  by using `AquaHotkey_Backup`?
- Create a GUI outline tool to helps generate some diagrams
