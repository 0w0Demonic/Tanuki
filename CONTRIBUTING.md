# Contributing to Tanuki

First of all, thanks for considering contributing to Tanuki!

From typo fixes to architectural ideas, your effort is greatly appreciated.
Otherwise, if you'd like to request more features, feel free to open an issue
and I'll try my best.

Before you start, here are a few principles that guide development:

- Features are meant to feel natural, like they were always meant to be there.
  Prefer extending existing classes, and avoid simple utility functions that
  sit "next to" the design.
- A feature is only worth adding if it can be expressed (reasonably) clearly.
  Make sure you're not just dropping functions with a dozen parameters or
  obscure names.
- When possible, use AhkWin32Projection and AquaHotkey. They're here to write
  things more easier.
- You don't need to be nearly as thorough as I am, but please keep your code
  reasonably clean and include some basic documentation. For extension classes,
  it's very appreciated when you include a list of things present in the class.

More generally speaking: if something makes the API simpler to read and reason
about, it's usually the right direction.

## Code Example (Ideally)

```ahk
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\NMSEARCHWEB>
#Include <Tanuki\Util\Event>
/**
 * Introduces the "Search with Bing..." feature for edit controls.
 * 
 * ```
 * class Gui.Edit
 * |- EnableWebSearch(OnOff := true)
 * |- SearchWeb()
 * `- OnWebSearch(Fn, Opt?)
 * ```
 */
class Tanuki_EditWebSearch extends AquaHotkey_MultiApply {
    static __New() => super.__New(Gui.Edit)

    /**
     * Enables or disables the "Search with Bing..." context menu item.
     * 
     * @param   {Boolean?}  OnOff  turn on/off web search
     */
    EnableWebSearch(OnOff := true) {
        SendMessage(Controls.EM_ENABLESEARCHWEB, !!OnOff, 0, this)
    }

    /**
     * Opens the browser and performs a web search with the selected text as
     * the search item.
     */
    SearchWeb() {
        this.EnableWebSearch()
        SendMessage(Controls.EM_SEARCHWEB, 0, 0, this)
    }

    /**
     * Registers a function to be called when a "Search with Bing..." web
     * search is being made.
     * 
     * @example
     * WebSearch(EditCtl: Gui.Edit, Notif: NMSEARCHWEB) => Void
     * 
     * @param   {Func}      Fn   the function to be called
     * @param   {Integer?}  Opt  add/remove the callback
     * @returns {Gui.Event}
     */
    OnWebSearch(Fn, Opt?) {
        this.EnableWebSearch()
        return Gui.Event.OnNotify(
                this,
                Controls.EN_SEARCHWEB,
                (EditCtl, lParam) => Fn(EditCtl, NMSEARCHWEB(lParam)),
                Opt?)
    }
}
```
