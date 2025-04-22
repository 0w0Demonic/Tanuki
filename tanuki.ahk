#Requires AutoHotkey >=v2.0.5
#DllLoad  "uxtheme.dll"
#Include  <AquaHotkeyX>
#Include  "%A_LineFile%/../theme_catppuccin.ahk"

/**
 * Tanuki is an extension that allows the use of Gui themes for
 * easy customization.
 */
class Tanuki extends AquaHotkey
{
    /**
     * This class saves a snapshot of the previous state of `Gui()`,
     * which is required to save e.g. its the old `__New()` method.
     */
    class Gui_Old extends AquaHotkey_Backup {
        static Class => Gui
    }

    /**
     * Defines new properties and methods added to the built-in `Gui` type.
     */
    class Gui {
        /**
         * Constructs a new Gui, optionally applying a theme given in the form
         * of a class name or file path to a JSON.
         * @example
         * 
         * g := Gui("Theme:src/themes/DarkMode.json")
         * 
         * @example
         * 
         * g := Gui("Theme:Catppuccin")
         * 
         * class Catppuccin {
         * 
         * }
         * 
         * @param   {String?}  Opt       additional options
         * @param   {String?}  Title     title of the Gui
         * @param   {Object}   EventObj  event sink of the Gui
         */
        __New(Opt := "", Title?, EventObj?) {
            HasTheme := Tanuki.ParseGuiOptions(&Opt, &Theme)
            (Tanuki.Gui_Old.Prototype.__New)(this, Opt, Title?, EventObj?)
            (HasTheme && (this.Theme := Theme))
        }

        /**
         * Sets various options and styles for the appearance and behaviour of
         * the window, now supporting Gui themes.
         * 
         * @example
         * 
         * g := Gui("Theme:src/themes/DarkMode.json")
         * 
         * @example
         * 
         * g := Gui("Theme:Catppuccin")
         * 
         * class Catppuccin {
         * 
         * }
         * 
         * @param   {String}  Options  zero or more options and styles
         */
        Opt(Options) {
            HasTheme := Tanuki.ParseGuiOptions(&Options, &Theme)
            (Tanuki.Gui_Old.Prototype.Opt)(this, Options)
            (HasTheme && (this.Theme := Theme))
        }

        /**
         * Defines new properties and methods for class `Gui.Control`.
         */
        class Control {
            /**
             * Sets various options and styles for the appearance and behaviour
             * of the control, additionally allowing the use of Gui themes.
             */
            Opt(Options) {
                HasTheme := Tanuki.ParseGuiOptions(&Options, &Theme)
                (Tanuki.Gui_Old.Control.Prototype.Opt)(this, Options)
                (HasTheme && (this.Theme := Theme))
            }

            /**
             * Sets the theme of the Gui control.
             * 
             * @param   {Object/String}  value  the theme to apply
             */
            Theme {
                set {
                    Theme := this.ApplyTheme(Tanuki.LoadTheme(value))
                    this.DefineProp("Theme", {
                        Get: (Instance) => Theme.Clone()
                    })
                }
            }

            /**
             * Shared `.ApplyTheme()` between Gui controls that does nothing.
             * 
             * @param   {Object}  Theme  the theme to apply
             */
            ApplyTheme(Theme) {
                return
            }

            /**
             * Returns the character length of the control text.
             * 
             * @return  {Integer}
             */
            TextLength { ; TODO rename to `StrLen()`?
                get {
                    static WM_GETTEXTLENGTH := 0x000E
                    return SendMessage(WM_GETTEXTLENGTH, 0, 0, this)
                }
            }

            /**
             * 
             */
            Style {
                get {
                    return ControlGetStyle(this)
                }
                set {
                    ControlSetStyle(value, this)
                }
            }

            /**
             * 
             */
            ExStyle {
                get {
                    return ControlGetExStyle(this)
                }
                set {
                    return ControlSetExStyle(value, this)
                }
            }

            ; TODO a bunch of other common control messages
        }

        /**
         * Adds a control to the Gui, optionally applying a Gui theme.
         * 
         * @param   {String}   ControlType  type of the Gui control to add
         * @param   {String?}  Opt          additional options
         * @param   {String?}  Txt          text to display in the control
         * @return  {Gui.Control}
         */
        Add(ControlType, Opt := "", Txt?) {
            Ctl := (Tanuki.Gui_Old.Prototype.Add)(this, ControlType, Opt, Txt?)
            Ctl.ApplyTheme(this.Theme)
            return Ctl
        }

        #Include "%A_LineFile%/../Button.ahk"
        #Include "%A_LineFile%/../CheckBox.ahk"

        /**
         * Adds a ComboBox control to the Gui.
         * 
         * @param   {String?}  Gui    additional options
         * @param   {Array?}   Items  a list of items
         * @return  {Gui.ComboBox}
         */
        AddComboBox(Opt?, Items?) => this.Add("ComboBox", Opt?, Items?)

        /**
         * Adds a DateTime control to the Gui.
         * 
         * @param   {String?}  Opt     additional options
         * @param   {String?}  Format  format string
         * @return  {Gui.DateTime}
         */
        AddDateTime(Opt?, Format?) => this.Add("DateTime", Opt?, Format?)

        /**
         * Adds a group box control to the Gui.
         * 
         * @param   {String?}  Opt  additional options
         * @param   {String?}  Txt  text to display in the group box
         * @return  {Gui.GroupBox}
         */
        AddGroupBox(Opt?, Txt?) => this.Add("GroupBox", Opt?, Txt?)

        /**
         * Adds a hotkey control to the Gui.
         * 
         * @param   {String?}  Opt  additional options
         * @param   {String?}  Txt  the text to display
         * @return  {Gui.Hotkey}
         */
        AddHotkey(Opt?) => this.Add("Hotkey", Opt?)

        /**
         * Adds a text control to the Gui which can contain links.
         * 
         * @param   {String?}  Opt  additional options
         * @param   {String?}  Txt  the text to display
         * @return  {Gui.Link}
         */
        AddLink(Opt?, Txt?) => this.Add("Link", Opt?, Txt?)

        /**
         * Adds a ListView control to the Gui.
         * 
         * @param   {String?}  Opt    additional options
         * @param   {Array?}   Items  a list of items
         * @return  {Gui.ListView}
         */
        AddListView(Opt?, Items?) => this.Add("ListView", Opt?, Items?)

        /**
         * Adds a calendar control to the Gui.
         * 
         * @param   {String?}  Opt   additional options
         * @param   {String?}  Date  the range of dates available
         * @return  {Gui.MonthCal}
         */
        AddMonthCal(Opt?, Date?) => this.Add("MonthCal", Opt?, Date?)

        /**
         * 
         */
        AddPicture(Opt?, FileName?) => this.Add("Picture", Opt?, FileName?)

        /**
         * 
         */
        AddProgress(Opt?, StartVal?) => this.Add("Progress", Opt?, StartVal?)

        /**
         * 
         */
        AddRadio(Opt?, Txt?) => this.Add("Radio", Opt?, Txt?)

        /**
         * 
         */
        AddSlider(Opt?, StartVal?) => this.Add("Slider", Opt?, StartVal?)

        /**
         * 
         */
        AddStatusBar(Opt?, Txt?) => this.Add("StatusBar", Opt?, Txt?)

        /**
         * 
         */
        AddTab(Opt?, Items?) => this.Add("Tab", Opt?, Items?)

        /**
         * 
         */
        AddTab2(Opt?, Items?) => this.Add("Tab2", Opt?, Items?)

        /**
         * 
         */
        AddTab3(Opt?, Items?) => this.Add("Tab3", Opt?, Items?)

        /**
         * 
         */
        AddTreeView(Opt?) => this.Add("TreeView", Opt?)

        /**
         * ; TODO allow nested objects
         * 
         * Applies a theme to the Gui. Valid arguments include
         * 1. Any object
         * 2. The name of an object at global scope (preferably a class object)
         * 3. The path to a JSON file
         * 
         * @param   {Object/String}  value  object, name of object or JSON file
         */
        Theme {
            set {
                Theme := Tanuki.LoadTheme(value)

                if (HasProp(Theme, "DarkMode")) {
                    this.DarkMode := Theme.DarkMode
                }

                if (HasProp(Theme, "Background")) {
                    this.BackColor := Theme.Background
                }

                if (HasProp(Theme, "Title")) {
                    if (HasProp(Theme.Title, "Background")) {
                        this.TitleColor := Theme.Title.Background
                    }
                    if (HasProp(Theme.Title, "Foreground")) {
                        this.TitleTextColor := Theme.Title.Foreground
                    }
                }

                ; and then loop through all controls
                for GuiControl in this {
                    GuiControl.ApplyTheme(Theme)
                }

                this.DefineProp("Theme", {
                    Get: (Instance) => Theme.Clone()
                })
            }
        }

        /**
         * Enables or disables dark mode for the window and its child controls.
         * When set to `true`, the system theme is overridden to use dark
         * styling.
         * 
         * Note: Requires Windows 10 1809+ (build 17763).
         * 
         * @param   {Boolean}  value  switch dark mode on/off
         * @return  {Boolean}
         */
        DarkMode {
            get {
                static DWMWA_USE_IMMERSIVE_DARK_MODE := (
                    19 + (VerCompare(A_OSVersion, "10.0.18985") >= 0)
                )

                DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", this.Hwnd,
                        "Int", DWMWA_USE_IMMERSIVE_DARK_MODE,
                        "Int*", &(Result := 0),
                        "UInt", 4)
                return !!Result
            }
            set {
                static DWMWA_USE_IMMERSIVE_DARK_MODE := (
                    19 + (VerCompare(A_OSVersion, "10.0.18985") >= 0)
                )
                
                OnOff := !!value
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Hwnd,
                        "Int", DWMWA_USE_IMMERSIVE_DARK_MODE,
                        "Int*", OnOff,
                        "UInt", 4)
            }
        }

        /**
         * Sets and retrieves the background color of the window's title bar.
         * This properties expects RGB values.
         * 
         * Requires Windows 11.
         * @param   {Integer}  value  RGB value of title bar background
         * @return  {Integer}
         */
        TitleColor {
            get {
                static DWMWA_CAPTION_COLOR := 0x0035
                DllCall("dwmapi\DwmGetWindowAttribute", "Ptr", this.Hwnd,
                        "Int", DWMWA_CAPTION_COLOR,
                        "Int*", &(Result := 0),
                        "UInt", 4)
                return Result
            }
            set {
                static DWMWA_CAPTION_COLOR := 0x0035
                Color := Tanuki.Swap_RGB_BGR(value)
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Hwnd,
                        "Int", DWMWA_CAPTION_COLOR,
                        "Int*", Color,
                        "UInt", 4)
            }
        }

        /**
         * Sets and retrieves the text color of the window's title bar.
         * This property expected RGB values.
         * 
         * Requires Windows 11.
         * @param   {Integer}  value  RGB value of title bar text color
         * @return  {Integer}
         */
        TitleTextColor {
            get {
                static DWMWA_TEXT_COLOR := 0x0036               
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Hwnd,
                        "Int", DWMWA_TEXT_COLOR,
                        "Int*", &(Result := 0),
                        "UInt", 4)
                return Result
            }
            set {
                static DWMWA_TEXT_COLOR := 0x0036
                Color := Tanuki.Swap_RGB_BGR(value)
                DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", this.Hwnd,
                        "Int", DWMWA_TEXT_COLOR,
                        "Int*", Color,
                        "UInt", 4)
            }
        }

        #Include "%A_LineFile%/../Button.ahk"

        class ComboBox {
            ApplyTheme(Theme) {

            }
        }

        class DateTime {
            ApplyTheme(Theme) {

            }
        }

        #Include %A_LineFile%/../DDL.ahk
        #Include %A_LineFile%/../Edit.ahk

        class GroupBox {
            ApplyTheme(Theme) {

            }
        }

        class Hotkey {
            ApplyTheme(Theme) {

            }
        }

        class Link {
            ApplyTheme(Theme) {

            }
        }

        /**
         * 
         */
        AddListBox(Opt?, Items?) => this.Add("ListBox", Opt?, Items?)

        class ListBox {
            ApplyTheme(Theme) {
                Theme := Tanuki.PrepareSubTheme(Theme, "ListBox")
                Tanuki.ApplyFont(this, Theme)
                if (HasProp(Theme, "Background")) {
                    this.Opt("Background" . Theme.Background)
                }
            }
        }

        class ListView {
            ; TODO Font.Color should override Foreground
            ApplyTheme(Theme) {
                static LVS_EX_DOUBLEBUFFER := 0x00010000
                static NM_CUSTOMDRAW      := -12
                static UIS_SET            := 0x0001
                static UISF_HIDEFOCUS     := 0x0001

                static WM_CHANGEUISTATE   := 0x0127
                static WM_NOTIFY          := 0x004E
                static WM_THEMECHANGED    := 0x031A

                static LVM_SETBKCOLOR     := 0x1001
                static LVM_SETTEXTCOLOR   := 0x1024
                static LVM_SETTEXTBKCOLOR := 0x1026
                static LVM_GETHEADER      := 0x101F

                DllCall("uxtheme\SetWindowTheme",
                        "Ptr", this.Hwnd,
                        "Str", "",
                        "Ptr", 0)
                
                Theme := Tanuki.PrepareSubTheme(Theme, "ListView")

                if (HasProp(Theme, "Background")) {
                    this.Opt("Background" . Theme.Background)
                    Background := Tanuki.Swap_RGB_BGR(Theme.Background)
                    SendMessage(LVM_SETBKCOLOR, 0, Background, this)

                    if (!HasProp(Theme, "TextBackground")) {
                        SendMessage(LVM_SETTEXTBKCOLOR, 0, Background, this)
                    }
                }

                if (HasProp(Theme, "TextBackground")) {
                    TextBackground := Tanuki.Swap_RGB_BGR(Theme.TextBackground)
                    SendMessage(LVM_SETTEXTBKCOLOR, 0, TextBackground, this)
                }

                this.OnMessage(WM_THEMECHANGED, (*) => 0)

                HeaderHwnd := SendMessage(LVM_GETHEADER, 0, 0, this)
                DllCall("uxtheme\SetWindowTheme",
                        "Ptr", HeaderHwnd,
                        "Str", "",
                        "Ptr", 0)

                if (HasProp(Theme, "Foreground")) {
                    Foreground := Tanuki.Swap_RGB_BGR(Theme.Foreground)
                    SendMessage(LVM_SETTEXTCOLOR, 0, Foreground, this)
        ; >>>>
        this.OnMessage(WM_NOTIFY, (Hwnd, wParam, lParam, Msg) {
            static CDDS_PREPAINT          := 0x00000001
            static CDDS_POSTPAINT         := 0x00000002
            static CDDS_ITEMPREPAINT      := 0x00010001
            static CDDS_SUBITEM           := 0x00020000

            static CDRF_DODEFAULT         := 0x00000000
            static CDRF_NEWFONT           := 0x00000002
            static CDRF_SKIPDEFAULT       := 0x00000004
            static CDRF_NOTIFYPOSTPAINT   := 0x00000010
            static CDRF_NOTIFYITEMDRAW    := 0x00000020
            static CDRF_NOTIFYSUBITEMDRAW := 0x00000020

            static DCBrush := DllCall("GetStockObject", "UInt", 18)

            Code := StructFromPtr(Tanuki.NMHDR, lParam).Code
            if (Code != NM_CUSTOMDRAW) {
                return
            }

            nmcd  := StructFromPtr(Tanuki.NMCUSTOMDRAW, lParam)
            if (nmcd.hdr.HwndFrom != HeaderHwnd) {
                return CDRF_DODEFAULT
            }
            Stage := nmcd.dwDrawStage

            if (Stage == CDDS_PREPAINT) {
                return CDRF_NOTIFYITEMDRAW | CDRF_NOTIFYPOSTPAINT
            }
            if (Stage == CDDS_ITEMPREPAINT) {
                hDC := nmcd.hDC
                rc  := nmcd.rc

                Item := Tanuki.HDITEM()
                VarSetStrCapacity(&ItemTxt, 520)
                Item.mask := 0x86
                Item.pszText := StrPtr(ItemTxt)
                Item.cchTextMax := 260
                SendMessage(0x120B, nmcd.dwItemSpec, ObjGetDataPtr(Item), HeaderHwnd)

                VarSetStrCapacity(&ItemTxt, -1)
                
                DC := Gdi32.DeviceContext(hDC)


                DllCall("SetDCBrushColor", "Ptr", hDC, "UInt", TextBackground)
                DllCall("FillRect", "Ptr", hDC, Tanuki.RECT, nmcd.rc, "Ptr", DCBrush)

                NewRc := Tanuki.RECT()
                DllCall("CopyRect", Tanuki.RECT, NewRc, Tanuki.RECT, Rc)

                DllCall("SetBkMode", "Ptr", hDC, "UInt", 0)
                DllCall("SetTextColor", "Ptr", hDC, "Uint", Foreground)

                DllCall("DrawText", "Ptr", hDC, "Ptr", StrPtr(ItemTxt),
                        "Int", StrLen(ItemTxt), Tanuki.RECT, NewRc, "UInt", 0x0204)
                
                return CDRF_SKIPDEFAULT
            }
            if (Stage == CDDS_POSTPAINT) {
                ClientRc   := Tanuki.RECT()
                LastItemRc := Tanuki.RECT()

                DllCall("GetClientRect", "Ptr", HeaderHwnd, Tanuki.RECT, ClientRc)
                Count := SendMessage(0x1200, 0, 0, HeaderHwnd)
                SendMessage(0x1207, Count - 1, ObjGetDataPtr(LastItemRc), HeaderHwnd)

                R1 := ClientRc.Right
                R2 := LastItemRc.Right
                if (R2 < R1) {
                    hDC           := nmcd.hDC
                    ClientRc.Left := R2

                    DllCall("SetDCBrushColor", "Ptr", hDC, "UInt", TextBackground)
                    DllCall("FillRect", "Ptr", hDC, Tanuki.RECT, ClientRc, "Ptr", DCBrush)
                }
                return CDRF_SKIPDEFAULT
            }
            return CDRF_DODEFAULT
        })
        ; <<<<
                }

                this.Opt("+LV" . LVS_EX_DOUBLEBUFFER)
                UIState := (UIS_SET << 8) | UISF_HIDEFOCUS
                SendMessage(WM_CHANGEUISTATE, UIState, 0, this)

            }
        }

        class MonthCal {
            ApplyTheme(Theme) {
                Theme := Tanuki.PrepareSubTheme(Theme, "MonthCal")
                DllCall("uxtheme\SetWindowTheme",
                        "Ptr", this.Hwnd,
                        "Str", "",
                        "Str", "")

                if (HasProp(Theme, "Background")) {
                    SetColor(0, Theme.Background)
                }

                if (HasProp(Theme, "Font") && HasProp(Theme.Font, "Color")) {
                    SetColor(1, Theme.Font.Color)
                } else if (HasProp(Theme, "Foreground")) {
                    SetColor(1, Theme.Foreground)
                }

                if (HasProp(Theme, "Title") && HasProp(Theme.Title, "Background")) {
                    SetColor(2, Theme.Title.Background)
                } else if (HasProp(Theme, "Background")) {
                    SetColor(2, Theme.Background)
                }

                if (HasProp(Theme, "Title") && HasProp(Theme.Title, "Foreground")) {
                    SetColor(3, Theme.Title.Foreground)
                } else if (HasProp(Theme, "Foreground")) {
                    SetColor(3, Theme.Foreground)
                }

                if (HasProp(Theme, "MonthBackground")) {
                    SetColor(4, Theme.MonthBackground)
                } else if (HasProp(Theme, "Background")) {
                    SetColor(4, Theme.Background)
                }
                
                if (HasProp(Theme, "TrailingText")) {
                    SetColor(5, Theme.TrailingText)
                }

                SetColor(Opt, Color) {
                    static MCM_SETCOLOR := 0x100A
                    SendMessage(0x100A, Opt, Tanuki.Swap_RGB_BGR(Color), this)
                }
            }
        }

        class Picture {
            ApplyTheme(Theme) {
                return
            }
        }

        class Progress {
            ApplyTheme(Theme) {

            }
        }

        ; TODO font doesn't change
        class Radio {
            ApplyTheme(Theme) {

            }
        }

        ; TODO still looks weird
        class Slider {
            ApplyTheme(Theme) {
                Theme := Tanuki.PrepareSubTheme(Theme, "Slider")

                if (HasProp(Theme, "Background")) {
                    this.Opt("Background" . Theme.Background)
                }
                if (HasProp(Theme, "Foreground")) {
                    this.Opt("c" . Theme.Foreground)
                }
            }
        }

        class StatusBar {
            ApplyTheme(Theme) {

            }
        }

        class Tab {
            ApplyTheme(Theme) {

            }
        }

        /**
         * 
         */
        AddText(Opt?, Txt?) => this.Add("Text", Opt?, Txt?)

        /**
         * 
         */
        class Text {
            /**
             * 
             */
            ApplyTheme(Theme) {
                Theme := Tanuki.PrepareSubTheme(Theme, "Text")
                Tanuki.ApplyFont(this, Theme)
                if (HasProp(Theme, "Background")) {
                    this.Opt("Background" . Theme.Background)
                }
                return Theme
            }
        }

        class TreeView {
            ApplyTheme(Theme) {

            }
        }

        /**
         * 
         */
        AddUpDown(Opt?, StartVal?) => this.Add("UpDown", Opt?, StartVal?)

        class UpDown {
            ApplyTheme(Theme) {
                Theme := Tanuki.PrepareSubTheme(Theme, "UpDown")
                Tanuki.ApplyFont(this, Theme)
                if (HasProp(Theme, "Background")) {
                    this.Opt("Background" . Theme.Background)
                }
                return Theme
            }
        }
    }

    /**
     * Returns an object which represents the GUI theme, associated
     * with the given class name or JSON file.
     * 
     * @param   {Object/String}  Theme  theme object, class name or JSON file
     */
    static LoadTheme(Theme) {
        if (IsObject(Theme)) {
            return Theme
        }

        static Deref1(a) => %a%
        static Deref2(b) => %b%
        try return (Theme != "a") ? Deref1(Theme) : Deref2(Theme)

        if (!FileExist(Theme)) {
            throw TargetError("unable to find Gui theme",, Theme)
        }
        ; TODO get a JSON lib somewhere
        ; return Json.Parse(FileRead(Theme))
    }

    /**
     * Finds and removes a theme from inside a string used for Gui options.
     * If the string contains a theme, this method will remove the argument from
     * the option string, outputting it into the `&Theme` variable. Returns
     * `true`, if a theme was found.
     * 
     * @example
     * 
     * ; name of an object
     * g := Gui("Theme:Obsidian")
     * 
     * ; file path to a JSON
     * g := Gui('Theme:"path/to/myTheme.json"')
     * 
     * @param   {&String}  Opt  zero or more Gui options
     * @return  {Boolean}
     */
    static ParseGuiOptions(&Opt, &Theme) {
        static Pattern := "ix) Theme: (?>  `" ([^`"]++) `" | (\S++) )"
        if (RegExMatch(Opt, Pattern, &Match)) {
            Theme := Match[1] || Match[2]
            Opt   := RegExReplace(Opt, Pattern, "", unset, 1)
            return true
        }
        return false
    }

    /**
     * Returns a modified version of the theme object that behaves in such a
     * way to allow subthemes to derive properties from the base theme.
     * @example
     * 
     * Obj := {
     *     Font: { Size: 10 }
     *     Edit: {
     *         ; `Obj.Edit.Font` inherits from `Obj.Font`
     *         Font: { Color: "0x202020" }
     *     }
     * }
     * 
     * @param   {Object}  Theme  the theme to prepare
     * @param   {String}  Name   the subtheme to resolve
     * @return  {Object}
     */
    static PrepareSubTheme(Theme, Name) {
        if (!HasProp(Theme, Name)) {
            return Theme.Clone()
        }

        BaseTheme := Theme.Clone()
        Theme     := Theme.%Name%.Clone()
        ObjSetBase(Theme, BaseTheme)

        ; if present in both objects, gather both `Font` properties, let the
        ; font of the subtheme inherit from the base theme, and then
        ; redefine the property of the theme.
        if (ObjHasOwnProp(Theme, "Font") && ObjHasOwnProp(BaseTheme, "Font"))
        {
            Font     := Theme.Font.Clone()
            BaseFont := BaseTheme.Font.Clone()
            ObjSetBase(Font, BaseFont)

            Theme.DefineProp("Font", { Get: (Instance) => Font })
        }
        return Theme
    }

    /**
     * Converts an RGB color into BGR and vice versa.
     * 
     * @param   {Integer}  Color  the color to convert
     * @return  {Integer}
     */
    static Swap_RGB_BGR(Color) => ((Color & 0xFF0000) >> 16)
                                | ((Color & 0x00FF00)      )
                                | ((Color & 0x0000FF) << 16)
    
    /**
     * Applies changes in font settings to a Gui or Gui control.
     * 
     * @param   {Gui/Gui.Control}  GuiObj  the target Gui or Gui control
     * @param   {Object}           Theme   the theme to apply
     */
    static ApplyFont(GuiObj, Theme) {
        if (!HasProp(Theme, "Font")) {
            return
        }
        Font := Theme.Font
        Name := unset
        Opt  := ""

        if (HasProp(Font, "Name")) {
            Name := Font.Name
        }
        if (HasProp(Font, "Color")) {
            Opt .= "c" . Font.Color . " "
        }
        if (HasProp(Font, "Format")) {
            Opt .= Font.Format . " "
        }
        if (HasProp(Font, "Size")) {
            Opt .= "s" . Font.Size . " "
        }
        if (HasProp(Font, "Weight")) {
            Opt .= "w" . Font.Weight . " "
        }
        if (HasProp(Font, "Quality")) {
            Quality := ResolveFontQuality(Font.Quality)
            Opt .= "q" . Quality . " "
        }
        GuiObj.SetFont(Opt, Name?)

        static ResolveFontQuality(Quality) {
            if (IsInteger(Quality)) {
                return Quality
            }
            if (IsObject(Quality)) {
                throw TypeError("invalid type",, Type(Quality))
            }
            switch (StrLower(Quality)) {
                case "default":        return 0
                case "draft":          return 1
                case "proof":          return 2
                case "nonantialiased": return 3
                case "antialiased":    return 4
                case "cleartype":      return 5
                default: throw ValueError("invalid font quality",, Quality)
            }
        }
    }

    class RECT extends AquaHotkey_Ignore {
        left   : i32
        top    : i32
        right  : i32
        bottom : i32
    }

    class NMHDR extends AquaHotkey_Ignore {
        hwndFrom : uptr
        idFrom   : uptr
        code     : i32
    }

    class NMCUSTOMDRAW extends AquaHotkey_Ignore {
        hdr         : Tanuki.NMHDR
        dwDrawStage : u32
        hdc         : uptr
        rc          : Tanuki.RECT
        dwItemSpec  : uptr
        uItemState  : u32
        lItemlParam : iptr
    }

    class HDITEM extends AquaHotkey_Ignore {
        mask       : u32
        cxy        : i32
        pszText    : uptr
        hbm        : uptr
        cchTextMax : i32
        fmt        : i32
        lParam     : uPtr
        iImage     : i32
        iOrder     : i32
        type       : u32
        pvFilter   : uPtr
    }

}

class RECT {
    Left   : i32
    Top    : i32
    Right  : i32
    Bottom : i32

    __New(Left := 0, Top := 0, Right := 0, Bottom := 0) {
        this.Left   := Left
        this.Top    := Top
        this.Right  := Right
        this.Bottom := Bottom
    }

    Copy() {
        Rc := RECT()
        if (!DllCall("CopyRect", RECT, Rc, RECT, this)) {
            throw Error("Unable to copy RECT")
        }
        return Rc
    }

    static CopyFrom(Rc) {
        if (IsInteger(Rc)) {
            Rc := StructFromPtr(RECT, Rc)
        }
        if (!(Rc is RECT)) {
            throw TypeError("Expected a RECT",, Type(Rc))
        }
        ; TODO
    }

    TrimSystemBorder() {
        static cx := SysGet(5)
        static cy := SysGet(6)

        this.Left   += cx
        this.Right  -= cx
        this.Top    += cy
        this.Bottom -= cy
        return this
    }

    static OfClient(Control) {
        if (IsObject(Control)) {
            Control := Control.Hwnd
        }
        if (!IsInteger(Control)) {
            throw TypeError("Expected an Integer",, Type(Control))
        }
        Rc := RECT()
        if (!DllCall("GetClientRect", "Ptr", Control, RECT, Rc)) {
            throw OSError("Unable to retrieve client RECT")
        }
        return Rc
    }

    static OfWindow(Window) {
        if (IsObject(Window)) {
            Window := Window.Hwnd
        }
        if (!IsInteger(Window)) {
            throw TypeError("Expected an Integer",, Type(Window))
        }
        Rc := RECT()
        if (!DllCall("GetWindowRect", "Ptr", Window, RECT, Rc)) {
            throw OSError("Unable to retrieve window RECT")
        }
        return Rc
    }

}

class Gdi32 {
    class DeviceContext {
        ; TODO replace this with whatever is in `static Create()` ?
        __New(hDC) {
            if (!IsInteger(hDC)) {
                throw TypeError("Expected an Integer",, Type(hDC))
            }

            this.DefineProp("Ptr", {
                Get: (Instance) => hDC
            })
        }

        static FromHandle(Handle) {
            DC := Object()

            if (!IsInteger(Handle)) {
                throw TypeError("Expected an Integer",, Type(Handle))
            }
            ObjSetBase(DC, Gdi32.DeviceContext.Prototype)
            DC.DefineProp("Ptr", {
                Get: (Instance) => Handle
            })
            return DC
        }

        FillRect(Rc, Brush) {
            ; TODO make Brush a new type?
            DllCall("FillRect", "Ptr", this.Ptr, RECT, Rc, "Ptr", Brush)
            return this
        }

        BrushColor {
            set {
                DllCall("SetDCBrushColor",
                        "Ptr", this.Ptr,
                        "UInt", Gdi32.Swap_RGB_BGR(value))
            }
        }

        BackgroundMode {
            set {
                DllCall("SetBkMode", "Ptr", this.Ptr, "UInt", value)
            }
        }

        BackgroundColor {
            set {
                DllCall("SetBkMode", "Ptr", this.Ptr, "UInt", Gdi32.Swap_RGB_BGR(value))
            }
        }

        Cancel() {
            DllCall("CancelDC", "Ptr", this.Ptr)
        }

        ; ChangeDisplaySettings
        ; ChangeDisplaySettingsEx

        CreateCompatibleDC() {
            return DllCall("CreateCompatibleDC", "Ptr", this.Ptr)
        }

        static Create(Driver, Device, Port, DevMode) {

        }

        Delete() {

        }

        DrawEscape(Escape, Input) {

        }
    }

    static DeleteObject(Obj) {

    }

    static SolidBrush(Color) {
        return DllCall("CreateSolidBrush", "UInt", Gdi32.Swap_RGB_BGR(Color))
    }

    static Swap_RGB_BGR(Color) => ((Color & 0x00FF0000) >> 16)
                                | ((Color & 0x0000FF00)      )
                                | ((Color & 0x000000FF) << 16)

    static DCBrush {
        get {
            static DC_BRUSH := 18
            return DllCall("GetStockObject", "UInt", DC_BRUSH)
        }
    }

    static InformationContext(Driver, Device, Port, DevMode) {

    }

    DeviceCapabilities(Device, Port, Capability, DevMode) {

    }

    class DisplayDevices {
        __New() {

        }
        __Enum() {

        }
    }

    class DisplaySettings {
        __New() {

        }
        __Enum() {

        }
    }

    class DisplaySettingsEx {
        __New() {

        }
        __Enum() {

        }
    }


}


class NMHDR {
    hwndFrom : uptr
    idFrom   : uptr
    code     : i32
}

class NMCUSTOMDRAW {
    hdr         : NMHDR
    dwDrawStage : u32
    hdc         : uptr
    rc          : RECT
    dwItemSpec  : uptr
    uItemState  : u32
    lItemlParam : iptr
}

g        := Gui("Theme:Catppuccin")
Btn      := g.AddButton(unset, "Hello, world!")
DDLCtl   := g.AddDropDownList(unset, Array("this", "is", "a", "test"))
Edt      := g.AddEdit("r4 w380")
MonthCal := g.AddMonthCal()
SldrCtl  := g.AddSlider("r1 w350", 50)
RadioCtl := g.AddRadio(unset, "Click me?")
LVCtl    := g.AddListView(unset, StrSplit("Apple Banana Carrot Date Eggplant", A_Space))

g.Show()

Edt.BalloonTip.Show("Very cool title",
                    "Very cool text",
                    Gui.Edit.BalloonTip.Icon.WarningLarge)

; ...


^x:: {
    
}
esc:: {
    ExitApp()
}
