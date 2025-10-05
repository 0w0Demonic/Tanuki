# The Mysterious `EM_ENABLEFEATURE`

I've been looking through the header files, and came across this section in `WinUser.h`:

```c
#if(WINVER >= 0x0604)
#define EM_ENABLEFEATURE        0x00DA
#endif /* WINVER >= 0x0604 */
```

Interesting. But what does it do?

Hmm, no documentation anywhere... But it did find a [diff](https://abi-laboratory.pro/compatibility/Windows_10_1511_10586.494_to_Windows_10_1607_14393.0/x86_64/headers_diff/user32.dll/diff.html):

```diff
+#if(WINVER >= 0x0604)
+#define EM_ENABLEFEATURE        0x00DA
+#endif /* WINVER >= 0x0604 */

...

+#if(WINVER >= 0x0604)
+#define EN_BEFORE_PASTE     0x0800
+#define EN_AFTER_PASTE      0x0801
+#endif /* WINVER >= 0x0604 */

...

+#if(WINVER >= 0x0604)
+/*
+ * EM_ENABLEFEATURE options
+ */
+typedef enum {
+    EDIT_CONTROL_FEATURE_ENTERPRISE_DATA_PROTECTION_PASTE_SUPPORT  = 0,
+    EDIT_CONTROL_FEATURE_PASTE_NOTIFICATIONS                       = 1,
+} EDIT_CONTROL_FEATURE;
+#endif /* WINVER >= 0x0604 */
```

Seems like it's got something to do with features related to clipboard pasting.
Now the only thing I need to find out is how to use the message.

Okay... How would Microsoft do this?

- Probably use `TRUE/FALSE` as return value to indicate success/fail.
- wParam might be a reference to the enum (`EDIT_CONTROL_FEATURE`), lParam might be an on/off switch.
- ... or the other way around.

```ahk
; test out with garbage data
SendMessage(EM_ENABLEFEATURE, 813632, 95820866, EditCtl) ; 0

; test with parameters that the message might be using
SendMessage(EM_ENABLEFEATURE,
            EDIT_CONTROL_FEATURE_PASTE_NOTIFICATIONS,
            true, EditCtl) ; 1
```

Perfect.

From what I've found, the message should work roughly like this:

## Half-Baked `EM_ENABLEFEATURE` Documentation

>## `EM_ENABLEFEATURE` message
>
>Enables and disables a feature for an edit control.
>
>### Parameters
>
>**wParam**:
>
>A value of type `int` specifying which feature to (de)activate.
>This value can be one of the following:
>
>| Value                                                           | Description                                                                                   |
>| --------------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
>| `EDIT_CONTROL_FEATURE_PASTE_NOTIFICATIONS`                      | Enables support for clipboard paste notifications `EN_BEFORE_PASTE` and `EN_AFTER_PASTE`.     |
>| `EDIT_CONTROL_FEATURE_ENTERPRISE_DATA_PROTECTION_PASTE_SUPPORT` | Enables support for... uh, no idea. Probably related to Windows Information Protection (WIP). |
>
>**lParam**:
>
>`TRUE` to enable to feature, `FALSE` to disable the feature.
>
>### Return Value
>
>This message returns `TRUE` on success, otherwise `FALSE`.

...Geez, these are *long* names.

## Paste Notifications `EN_BEFORE_PASTE` and `EN_AFTER_PASTE`

Now all you have to do is catch `EN_BEFORE_PASTE` (note: it's a `WM_NOTIFY`
message) and magically, our beloved `MsgBox()` window appears.

```ahk
SendMessage(...) ; enable clipboard notifs
EditCtl.OnNotify(EN_BEFOREPASTE, (*) => MsgBox("pasting: " . A_Clipboard))
```

For some reason, I was unable to paste text into the edit control now.

Turns out that the return value behind `EN_BEFOREPASTE` determines whether the
paste should proceed. Like this:

```ahk
BeforePaste(GuiObj, lParam) {
    MsgBox("pasting: " . A_Clipboard)
    return true ; `false` cancels the paste operation
}
```

What I don't know is what kind of struct `lParam` actually is. But I don't think
there's a lot more to see other than clipboard-relevant data. And `A_Clipboard`
exists, so there's nothing to worry about.

Though I can imagine that it contains very detailed things about the paste operation,
e.g. whether the user pressed `Ctrl+V` or pasted by using `Paste` in the context menu.

---

>## `EN_BEFORE_PASTE` Notification
>
>Sent before the system clipboard is pasted into an edit control.
>
>### Parameters
>
>**lParam**:
>
>A pointer to an unknown notification structure.
>
>### Return Value
>
>Return `TRUE` to let the paste operation proceed. To cancel the paste operation, return `FALSE`.

---

>## `EN_AFTER_PASTE` Notification
>
>Sent after a successful clipboard paste operation was performed an on edit control.
>
>### Parameters
>
>**lParam**:
>
>A pointer to an unknown notification structure.
>
>### Return Value
>
>None.

## Enterprise Data Protection

Now that we have that out of the way, let's move on to the other feature with the ridiculously long name.
I'm unsure what this could be, but it might have something to do with [WIP](https://learn.microsoft.com/en-us/previous-versions/windows/uwp/enterprise/wip-hub)
(Windows Information Protection).

Basically, it prevents you from pasting clipboard data marked as "enterprise" into unauthorized applications.
Check out the external link for more.
