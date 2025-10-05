# Tanuki

```
______________________,     /\ /\
                - o x |    <_'u'_>
_|_ _ __      |/ o |  |     *0,.o*
 |_(_|| | |_| |\ | .  | <(((| ()|
                             \/\/
```

## AutoHotkey `Gui` on Steroids

Tanuki is a Gui library for AutoHotkey v2 that massively upgrades the native
`Gui` type and its controls with Win32 features - some of which you've probably
never heard of.

Example: Clipboard paste notification for edit controls (Windows 10+):

```ahk
#Include <Tanuki\Edit>

g := Gui()
e := g.AddEdit()

; enables paste notifications
e.EnablePasteNotifs()
e.OnBeforePaste(BeforePaste)
e.OnAfterPaste(AfterPaste)
g.Show()

BeforePaste(EditCtl, lParam) {
    ; the actual notification struct is undocumented - but it probably only
    ; contains clipboard-related data, and `A_Clipboard` still exists.
    Hdr := NMHDR(lParam)

    MsgBox("pasting: " . A_Clipboard)
    return true ; `false` cancels the paste operation
}

AfterPaste(EditCtl, lParam) {
    Hdr := NMHDR(lParam)
    MsgBox("pasting: " . A_Clipboard)
}
```

## Design

Tanuki consists of a variety of standalone packages which add new features baked
directly into the native `Gui` and its controls.

```ahk
#Include <Tanuki\Edit> ; extensions for `Gui.Edit`
```

## Why it Matters

There's tons of AutoHotkey Gui libraries, most of them using the same Win32 API.
My goal is to provide a complete and modular wrapper for all of the relevant parts
of the Win32 API, in a way that feels like it's a built-in feature.

## Getting Started

To get started, first clone the repository, preferably into one of the
AutoHotkey lib folders.

```sh
git clone https://www.github.com/0w0Demonic/Tanuki
```

Dependancies:
- [AquaHotkey](https://www.github.com/0w0Demonic/AquaHotkey)
- [AhkWin32Projection](https://www.github.com/holy-tao/AhkWin32Projection)

Now, `#Include` one of the many packages available:

```ahk
#Include <Tanuki\CommandLink>

g := Gui()
cl := g.AddCommandLink("w350 h100", "Command Link Button",
        "A special type of button "
        . "button")
```
