# Property Sheets

I was browsing through MSDN when I saw documentations about property sheets.

Wow, these are neat. You might know them as these little "properties..."
windows e.g. for looking at file properties, or - in their special form -
they're these install wizards we all know and love.

This would be awesome as an addition to Tanuki. My goal is to make it easy
enough to be at least a viable way of making GUIs. Sort of like InnoSetup?
Yeah, kinda.

## Quick Rundown

First, create one or more pages to be displayed of type `PROPSHEETPAGEW`.
Along some other stuff, they contain things like icon and title, the window
procedure, a header with image and watermark, and finally a resource that
contains - yet again - more infos like styles, position, size, you name it.

After you've done that, you create a `PROPSHEETHEADER` that holds all of the
property sheet pages (in a nutshell) along with more general information about
the window to be created.

## Attempt #1

*In and out, 20 minute adventure*, I thought.

While it was kind of a nightmare to deal with all the `dwFlags` they're using
(adding a member like `hIcon` requires you to set the `PSP_USEHICON` flag,
and other types of fun), it was reasonably easy to figure out.

Bingo. An empty window.

Normally, you're getting a lot of help from the resource compiler that
declaratively sets up dialogs for you automatically. But we won't be able to
use it to our advantage. (But if you do know how, please let me know.)

That means we'll need to write our own `DLGTEMPLATE` and `DLGITEMTEMPLATE`
structs...

## What the Hell, Microsoft?

Out of the many things I've seen in Win32, `DLGTEMPLATE` might be one of the
most ridiculous structs I've ever seen.

"Let's make this struct some kind of variable length memory blob, what
could go wrong?"

Half of the actual data is somewhere *after* the struct boundary. But I think
I've figured it out, after reading through the docs enough times.

Immediately after the struct follows...

### Menu

One of the following:

- no menu. (simply `0x0000`).
- ordinal value of a menu resource (`0xFFFF`, then resource as `WORD`).
- a UTF-16 string.

### Window Class (Dialog)

Same logic here, either...

- predefined dialog box class (`0x0000`).
- ordinal value of a predefined window class (`0xFFFF`, then a `WORD`).
- a UTF-16 string.

### Title of the Dialog

None (`0x0000`) or a UTF-16 string.

### Font Settings (Optional)

If you've specified font settings to be used (specifically, you need to set
the `DS_SETFONT` style), this struct follows...

- font size as `WORD`.
- name of the font as UTF-16 string.

## Items

And then finally, an array of `DLGITEMTEMPLATE`s (not a pointer, the actual
structs). All of these need to be aligned on `DWORD`s.

Oh no... please not again.

### Window Class (Item)

You guessed it.

- A predefined system class (`0xFFFF`, then a `WORD`).
- A window class as UTF-16 string.

This time, you have 6 different `WORD` values used as standard dialog controls:

| Value    | Meaning     |
| -------- | ----------- |
| `0x0080` | Button      |
| `0x0081` | Edit        |
| `0x0082` | Static      |
| `0x0083` | List Box    |
| `0x0084` | Scroll Bar  |
| `0x0085` | Combo Box   |

### Control Text / Resource

A UTF-16 string, a resource (`0xFFFF`, `WORD`), or nothing (`0x0000`).

### Additional Data

Essentially, just raw data with length prefix.

In other words, either append `0x0000`, or `<size in bytes><memory block>`.

## Somehow, It Works

There’s a weird charm to how bare-metal Win32 programming is. It's like building
a car from spare parts just because you can. You feel the history in every
struct and flag and hear the dial-up tone somewhere in the distance.
