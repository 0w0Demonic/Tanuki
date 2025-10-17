# Tanuki

```
____________________      /\ /\
              - o x |    <_'u'_>
_|_ _ __    |/ o |  |   <^0, .o^>
 |_(_|| ||_||\ | .  | <((({ ()}
                           \/\/
```

## AutoHotkey `Gui` on Steroids

Tanuki is a Win32-powered GUI library for AutoHotkey v2 that *directly extends*
the built-in `Gui` type and its controls. Features that feel like they were
already there from day one, without wrappers and without hacks.

## Features at a Glance

- A broad range of extensions for built-in Gui controls
- Support for Win32 events and notifications
- GUIs such as dialogs, property sheets and wizards
- Modular and feature-driven design
- Powered by [AquaHotkey](https://www.github.com/0w0Demonic/AquaHotkey) for
  painless class prototyping
- Standardized Win32 API access with the help of
  [AhkWin32Projection](https://www.github.com/holy-tao/AhkWin32Projection)

## The Vision

Tanuki makes working with Win32 fun.

Things that are normally too complex or tedious are now just part of the toolkit.
Imagine the possibilities of being open to the Win32 GUI API in its entirety,
all while staying readable, concise, and modular.

## Why it Matters

Most GUI libraries in AutoHotkey stop at the surface level. They make simple
things simpler, and leave the real depth of Win32 locked away behind
hand-crafted DLL calls and structs. It's an enormous barrier that hinders the
library from making any progress after it has grown to a certain size.

Tanuki breaks this barrier and dives all the way down into the rabbit hole that
is Win32. By standardizing how Win32 data and events are exposed, it makes some
otherwise *impossible* GUI features possible.

### 1. Standardized Win32 Interop

Thanks to [AhkWin32Projection](https://www.githuv.com/holy-tao/AhkWin32Projection),
you can forget about manual structs, message constants and raw DLL calls.
It lets you concentrate on what's important and makes working with Win32
actually fun.

```ahk
myRect := RECT({ top: 20, bottom: 100, left: 0, right: 100 })
hDC := Gdi.GetDC(0)

hIcon := WindowsAndMessaging.GetClassLongPtrW(
        Hwnd,
        GET_CLASS_LONG_INDEX.GCLP_HICON)
```

### 2. Designed for Growth

*A GUI library is never "done".*

When it comes to GUI libraries, there's always more features you can add.
Tanuki embraces this type of growth by making it easy to write your own
extensions, and giving you a wide range of utility classes.

### 3. Class Prototyping

Tanuki takes huge advantage of class prototyping, one of the most underrated
powers of AutoHotkey. Features are baked directly into `Gui` and its
`Gui.Control` classes:

```ahk
g := Gui()
e := g.AddEdit()

e.OnBeforePaste(BeforePaste)
e.OnAfterPaste((*) => MsgBox("successful clipboard paste."))
g.Show()

BeforePaste(EditCtl, lParam) {
    MsgBox("pasting: " . A_Clipboard)
    return true ; return `false` to cancel paste
}
```

Powered by [AquaHotkey](https://www.github.com/0w0Demonic/AquaHotkey), so you
know its serious business.

## Getting Started

To get started, clone the repository into one of the AutoHotkey lib folders.

```sh
git clone https://www.github.com/0w0Demonic/Tanuki
```

Dependancies (install first):

- [AquaHotkey](https://www.github.com/0w0Demonic/AquaHotkey)
- [AhkWin32Projection](https://www.github.com/holy-tao/AhkWin32Projection)

## About

Made with love and lots of caffeine.

- 0w0Demonic
