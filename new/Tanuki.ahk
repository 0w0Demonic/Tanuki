#Requires AutoHotkey v2.0

; https://www.github.com/0w0Demonic/AquaHotkey
#Include <AquaHotkeyX>
; #Include "%A_LineFile%/../themes/theme_catppuccin.ahk"

#DllLoad "uxtheme.dll"
#DllLoad "dwmapi.dll"

/**
 * ```
 * ______________________,     /\ /\
 *                 - o x |    <_'u'_>
 * _|_ _ __      |/ o |  |     *0,.o*
 *  |_(_|| | |_| |\ | .  | <(((| ()|
 *                              \/\/
 * ```
 * https://www.github.com/0w0Demonic/Tanuki
 * 
 * ---
 * 
 * ### Tanuki - GUI Customization and Themes
 * 
 * Tanuki extends the built-in AutoHotkey v2 `Gui` types with a *lot* more
 * functionality. From quality-of-life tweaks over to features you didn't know
 * you needed (or even existed in the first place).
 * 
 * ### Themes
 * 
 * You can style entire GUIs by defining a single, large configuration object
 * or class.
 * 
 * ```
 * class MyTheme {
 *     ; overall settings
 *     static Background => "0x1E1E1E"
 *     static Foreground => "0xE0E0E0"
 *     static DarkMode   => true
 * 
 *     ; specific to `Gui.Edit` controls
 *     class Edit {
 *         static Background => "0x333333"
 *         
 *         ; font settings specific to `Gui.Edit`
 *         class Font {
 *             static Color => "0xB5C67C"
 *             static Name => "Cascadia Code"
 *         }
 *     }
 * 
 *     class MonthCal { ... }
 * 
 *     ...
 * }
 * ```
 * 
 * TODO
 */
class Tanuki extends AquaHotkey
{ ; <<<<
; <<<<

/**
 * Creates a snapshot of the previous `Gui` class.
 */
class GuiOld extends AquaHotkey_Backup {
    static __New() => super.__New(Gui)
}

/**
 * Defines all property and method extensions added to the `Gui` class.
 */
class Gui {
    /**
     * New, overridden GUI constructor with additional `Theme`-option.
     * 
     * Syntax: `Theme: (<variable name> | "<name of file>")`
     * 
     * @example
     * g := Gui("Theme:Dark")
     * g := Gui("Theme:'C:\Users\...\Desktop\theme.json'")
     * 
     * @param   {String?}  
     * @param   {String?}
     * @param   {Object}
     */
    __New(Opt := "", Title?, EventObj?) {
        ; old `__New()` method
        static __New := Tanuki.GuiOld.Prototype.__New

        HasTheme := Tanuki.Theme.Parse(&Opt, &Theme)
        __New(this, Opt, Title?, EventObj?)

        if (HasTheme) {
            this.Theme := Theme
        }
    }

    /**
     * Sets various options and styles for the appearance and behavior of the
     * window (now supporting the use of Gui themes).
     * 
     * @example
     * g.Opt("Theme:Catppuccin")
     * 
     * @param   {String}  OptionStr  zero or more options and styles
     */
    Opt(OptionStr) {
        ; old `.Opt()` method
        static Opt := Tanuki.GuiOld.Prototype.Opt

        HasTheme := Tanuki.Theme.Parse(&Opt, &Theme)
        Opt(this, OptionStr)

        if (HasTheme) {
            this.Theme := Theme
        }
    }

    /**
     * Adds a control to the Gui.
     * 
     * @param   {String}   ControlType  type of control to be added
     * @param   {String?}  Opt          additional options
     * @param   {String?}  Txt          text to be displayed inside the control
     * @return  {Gui.Control}
     */
    Add(ControlType, Opt := "", Txt?) {
        static Add := Tanuki.GuiOld.Prototype.Add ; old `.Add()` method

        Ctl := Add(this, ControlType, Opt, Txt?)
        Theme := this.Theme
        if (!ObjOwnPropCount(Theme := this.Theme)) {
            Theme := ObjGetBase(Ctl).Theme
        }
        Ctl.ApplyTheme(Theme)
        return Ctl
    }

    /**
     * Retrieves or applies a theme to the Gui. Valid arguments are...
     * 
     * 1. Any object
     * 2. The name of a global object (e.g., a class that resembles a theme)
     * 3. File path to a JSON that contains a theme
     */
    Theme {
        get {
            return Object()
        }
        set {
            Theme := Tanuki.Theme.Load(value)

            if (HasProp(Theme, "DarkMode")) {
                this.DarkMode := Theme.DarkMode
            }
            if (HasProp(Theme, "Background")) {
                this.BackColor := Theme.Background
            }
            if (HasProp(Theme, "Title")) {
                if (HasProp(Theme.Title, "Background")) {
                    this.TitleColor := Theme.Title.Color
                }
                if (HasProp(Theme.Title, "Foreground")) {
                    this.TitleTextColor := Theme.Title.Foreground
                }
            }
            ; TODO add more dwm stuff

            ; apply theme for every control in the Gui
            for GuiControl in this {
                GuiControl.ApplyTheme(Theme)
            }

            ; override the `Theme` property to retrieve a defensive copy of the
            ; theme object
            this.DefineProp("Theme", { Get: (_) => Theme.Clone() })
        }
    }

    ; TODO make this less repetitive. Maybe even generate this code over here.

    /**
     * Returns or changes whether dark mode is enabled for the Gui.
     * 
     * @param   {Boolean}  value  dark mode on/off
     * @return  {Boolean}
     */
    DarkMode {
        get {
            return !!Tanuki.Dwm.Get(this, Tanuki.Dwm.DarkMode)
        }
        set {
            Tanuki.Dwm.Set(this, Tanuki.Dwm.DarkMode, !!value)
        }
    }

    /**
     * Returns and changes the color of the window caption.
     * 
     * Requires Windows 11.
     * 
     * @param   {Integer}  value  RGB color
     * @return  {Integer}
     */
    CaptionColor {
        get {
            Color := Tanuki.Dwm.Get(this, Tanuki.Dwm.Color.Caption)
            return Tanuki.Color.SwapRB(Color)
        }
        set {
            Tanuki.Dwm.Set(
                    this,
                    Tanuki.Dwm.Color.Caption,
                    Tanuki.Color.SwapRB(value))
        }
    }

    /**
     * Returns and changes the color of the window borders.
     * 
     * Requires Windows 11.
     * 
     * @param   {Integer}  value  RGB color
     * @return  {Integer}
     */
    BorderColor {
        get {
            Color := Tanuki.Dwm.Get(this, Tanuki.Dwm.Color.Border)
            return Tanuki.Color.SwapRB(Color)
        }
        set {
            Tanuki.Dwm.Set(
                    this,
                    Tanuki.Dwm.Color.Border,
                    Tanuki.Color.SwapRB(value))
        }
    }

    /**
     * Returns and changes the color of the window text.
     * 
     * Requires Windows 11.
     * 
     * @param   {Integer}  value  RGB color
     * @return  {Integer}
     */
    TextColor {
        get {
            Color := Tanuki.Dwm.Get(this, Tanuki.Dwm.Color.Text)
            return Tanuki.Color.SwapRB(Color)
        }
        set {
            Tanuki.Dwm.Set(
                    this,
                    Tanuki.Dwm.Color.Text,
                    Tanuki.Color.SwapRB(value))
        }
    }

    /**
     * 
     */
    Corners {
        get => Tanuki.Dwm.Get(this, Tanuki.Dwm.Corners)
        set {
            Tanuki.Dwm.Set(
                    this,
                    Tanuki.Dwm.Corners,
                    Tanuki.Dwm.CornerPreference.Value[value])
        }
    }

    #Include "%A_LineFile%/../controls/Controls.ahk"
}

#Include "%A_LineFile%/../util/Util.ahk"

; >>>>
} ; >>>> class Tanuki extends AquaHotkey


class DarkMode {
    static DarkMode => true
    static Corners  => "Round"
}

