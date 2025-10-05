# Tanuki

```
______________________,     /\ /\
                - o x |    <_'u'_>
_|_ _ __      |/ o |  |     *0,.o*
 |_(_|| | |_| |\ | .  | <(((| ()|
                             \/\/
```

## AutoHotkey `Gui` on Steroids

Tanuki is a Gui library for AutoHotkey v2 that *directly upgrades* the native
`Gui` type and its controls with deep Win32 integration.

No wrappers, no boilerplate. Just features that feel like they were there from
day one.

## Features at a Glance

- Extensions for built-in Gui controls
- Win32 events and notifications (e.g. paste notifications for Edit controls)
- Very modular design
- Powered by [AquaHotkey](https://www.github.com/0w0Demonic/AquaHotkey) for
  painless class prototyping
- Standardized Win32 API access with the help of
  [AhkWin32Projection](https://www.github.com/holy-tao/AhkWin32Projection)
  (no more manual structs)

### Example: Clipboard Paste Notifications (Windows 10+)

```ahk
#Include <Tanuki\Edit>

g := Gui()
e := g.AddEdit()

; enables paste notifications
e.EnablePasteNotifs()

; catch clipboard paste notifications
e.OnBeforePaste(BeforePaste)
e.OnAfterPaste(AfterPaste)
g.Show()

BeforePaste(EditCtl, lParam) {
    Hdr := NMHDR(lParam) ; undocumented struct
    MsgBox("pasting: " . A_Clipboard)
    return true ; return `false` to cancel paste
}

AfterPaste(EditCtl, lParam) {
    Hdr := NMHDR(lParam)
    MsgBox("pasting: " . A_Clipboard)
}
```

### Another Example: New `Gui.CommandLink` Class

```ahk
#Include <Tanuki\CommandLink>

g := Gui()
cl := g.AddCommandLink("w350 h100", "Command Link Button",
        "A special type of button with a lightweight appearance")
g.Show()
```

## Why it Matters

There are other Gui libraries that add their features in the form of
properties - quick shoutout to [GuiEnhancerKit](https://github.com/nperovic/GuiEnhancerKit/blob/main/GuiEnhancerKit.ahk),
it's an awesome library. Tanuki goes a little further by going all-in on class prototyping:

- Features feel native, not bolted on
- Consistent, modular, and extensible design
- Built on top of solid libraries that remove the pain of dealing with Win32 directly

## Getting Started

To get started, first clone the repository, preferably into one of the
AutoHotkey lib folders.

```sh
git clone https://www.github.com/0w0Demonic/Tanuki
```

Dependancies (install first):

- [AquaHotkey](https://www.github.com/0w0Demonic/AquaHotkey)
- [AhkWin32Projection](https://www.github.com/holy-tao/AhkWin32Projection)

## About

Made with love and lots of caffeine.

- 0w0Demonic
