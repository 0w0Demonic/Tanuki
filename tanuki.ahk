#Requires AutoHotkey >=v2.1-alpha.10

; https://www.github.com/0w0Demonic/AquaHotkey
#Include "%A_LineFile%/../lib/AquaHotkey.ahk"
#Include "%A_LineFile%/../lib/AquaHotkey_Backup.ahk"
#Include "%A_LineFile%/../lib/AquaHotkey_Ignore.ahk"
#Include "%A_LineFile%/../lib/AquaHotkey_MultiApply.ahk"

#Include "%A_LineFile%/../util/ThemeObject.ahk"

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
{
/**
 * Creates a snapshot of the previous state of the `Gui` class.
 */
class GuiOld extends AquaHotkey_Backup {
    static __New() => super.__New(Gui)
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
        Tanuki.Theme.Parse(&Opt, &Theme)
        (Tanuki.GuiOld.Prototype.__New)(this, Opt, Title?, EventObj?)

        if (Theme) {
            this.Theme := Theme
        }
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
        Tanuki.Theme.Parse(&Options, &Theme)
        (Tanuki.GuiOld.Prototype.Opt)(this, Options)
        if (Theme) {
            this.Theme := Theme
        }
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
        Ctl := (Tanuki.GuiOld.Prototype.Add)(this, ControlType, Opt, Txt?)

        ; TODO this (kinda) sucks
        Theme := this.Theme
        if (!ObjOwnPropCount(Theme)) {
            Theme := ObjGetBase(Ctl).Theme
        }

        Ctl.ApplyTheme(Theme)
        return Ctl
    }


    /**
     * Applies a theme to the Gui. Valid arguments include
     * 1. Any object
     * 2. The name of an object at global scope (preferably a class object)
     * 3. The path to a JSON file
     * 
     * @param   {Object/String}  value  object, name of object or JSON file
     */
    Theme {
        get => Object()
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

            this.DefineProp("Theme", { Get: (_) => Theme.Clone() })
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

    #Include "%A_LineFile%/../controls/ALL_CONTROLS.ahk"

    #Include "%A_LineFile%/../util/Util.ahk"
} ; class Gui
} ; class Tanuki

#Include "%A_LineFile%/../util/EnumClass.ahk"

#Include "%A_LineFile%/../RECT.ahk"
#Include "%A_LineFile%/../Box.ahk"
#Include "%A_LineFile%/../Gdi.ahk"
#Include "%A_LineFile%/../util.ahk"

#Include "%A_LineFile%/../util/GuiEvent.ahk"