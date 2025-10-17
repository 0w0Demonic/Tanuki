# TODO List

- `ControlSetStyle("+" . Controls..., this)` kind of sucks manually. Fix this.
- Add common COLORREF colors as static params for DateTime.ahk.
- DateTime Open().
- Add a way to attach menus to dialogs.
- Refactor all of the window styles logic in `DialogItem.ahk` into its own thing
- DialogEx.
- Probably split up extension classes for the `Gui.Control` classes because
  they're huge.
- Add Time API for DateTime controls. It should have an easy way of doing
  time arithmetic like e.g. `.PlusDays(4)`.
- Add SysLink? It already exists as `Gui.Link`
- BUTTON_SPLITINFO extension
- Allow DragList to register messages directly, in which case they must be dispatched
- resize monthcal dropped down by datetime control when the theme is removed
