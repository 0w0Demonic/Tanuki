; class Tanuki {

/**
 * Utility class used for handling and parsing theme objects.
 */
class Theme extends AquaHotkey_Ignore {
    ; TODO
    static Load(Theme) {
        if (!IsObject(Theme)) {
            try {
                Theme := (Theme != "a" ? Deref1(Theme) : Deref2(Theme))
            } catch {
                throw UnsetError("Theme not found",, Type(Theme))
            }
        }
        if (!IsObject(Theme)) {
            throw TypeError("Expected an Object",, Type(Theme))
        }
        return Theme

        static Deref1(a) => %a%
        static Deref2(b) => %b%
    }

    ; TODO
    static Parse(&OptionStr, &Theme) {
        static Pattern := "Theme: ( \S++ )"
        ; static Pattern := "
        ; (
        ; ix)
        ; Theme: ( " [^"]++ " # file path enclosed in "
        ;        | ' [^']++ ' # file path enclosed in '
        ;        |     \S++ ) # any existing (global) theme object
        ; )"
        if (RegExMatch(OptionStr, Pattern, &Match)) {
            Theme  := Match[1]
            Before := SubStr(OptionStr, 1, Match.Pos[0] - 1)
            After  := SubStr(OptionStr, Match.Pos[0] + Match.Len[0])
            OptionStr := Before . After
            return true
        }
        Theme := false
        return false
    }

    ; TODO move this somewhere else, make it prettier
    /**
     * Applies a font represented as object to the targeted GUI or GUI
     * control.
     * 
     * Fields:
     * - `FontName`
     * - `FontColor`
     * - `FontFormat`
     * - `FontSize`
     * - `FontWeight`
     * - `FontQuality`
     * 
     * The `FontQuality` field additionally supports verbose values:
     * 
     * - `Default`
     * - `Draft`
     * - `Proof`
     * - `NonAntiAliased`
     * - `AntiAliased`
     * - `ClearType`
     */
    static ApplyFont(GuiObj, Theme) {
        Name := unset
        Opt  := ""

        if (HasProp(Theme, "FontName")) {
            Name := Theme.Name
        }
        if (HasProp(Theme, "FontColor")) {
            ; TODO support numbers directly using `Format()`
            Opt .= "c" . Theme.Color . " "
        }
        if (HasProp(Theme, "FontFormat")) {
            Opt .= Theme.FontFormat . " "
        }
        if (HasProp(Theme, "FontSize")) {
            Opt .= "s" . Theme.FontSize . " "
        }
        if (HasProp(Theme, "FontWeight")) {
            Opt .= "w" . Theme.FontWeight . " "
        }
        if (HasProp(Theme, "FontQuality")) {
            Quality := ResolveFontQuality(Theme.FontQuality)
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
}

; TODO code gen for this based on a bunch of default methods and constants
/**
 * Utility class for the Desktop Window Manager API.
 */
class Dwm extends AquaHotkey_Ignore {
    /**
     * Value of the immersive dark mode window attribute, which is either
     * 19 or 20 based on the current Windows version.
     */
    static DarkMode => (19 + (VerCompare(A_OSVersion, "10.0.18985") >= 0))

    /** Value of corner rounding pref window attribute. */
    static Corners  => 33

    /** Contains window attribute constants that relate to coloring. */
    class Color {
        static Border  => 34
        static Caption => 35
        static Text    => 36
    }

    /** Represents the DWM corner rounding preference enum. */
    class CornerPreference extends Tanuki.Enum {
        static Default    => 0
        static DoNotRound => 1
        static Round      => 2
        static RoundSmall => 3
    }

    /**
     * Retrieves a window attribute from the given HWND.
     * 
     * @param   {Integer/Object}  Target  HWND, or object with `HWND` prop
     * @param   {Integer}         Attr    DWM window attribute to retrieve
     * @param   {Integer?}        Size    size of the output in bytes
     * @return  {Primitive}
     */
    static Get(Target, Attr, Size := 4) {
        ; TODO method that retrieves Hwnd regardless of type?
        Hwnd := IsObject(Target) ? Target.Hwnd : Target
        Result := DllCall("dwmapi\DwmGetWindowAttribute",
                "Ptr", Hwnd,
                "Int", Attr,
                "Int*", &(Result := 0),
                "UInt", Size)
        if (Result) {
            throw OSError(Result)
        }
        return Result
    }

    /**
     * Sets a window attribute of the given HWND.
     * 
     * @param   {Integer/Object}  Target  HWND, or object with `HWND` prop
     * @param   {Integer}         Attr    DWM window attribute to set
     * @param   {Primitive}       Value   new value to set
     * @param   {Integer?}        Size    size in bytes
     */
    static Set(Target, Attr, Value, Size := 4) {
        Hwnd := IsObject(Target) ? Target.Hwnd : Target
        Result := DllCall("dwmapi\DwmSetWindowAttribute",
                "Ptr", Hwnd,
                "Int", Attr,
                "Int*", Value,
                "UInt", Size)
        if (Result) {
            throw OSError(Result,, Format("
            (
            Hwnd: {1}
            AttributeType: {2}
            Value: {3}
            Size: {4}
            )", Hwnd, Attr, Value, Size))
        }
        return this ; allows chaining calls together
    }
}

/**
 * Utility that generates useful methods for classes that are meant to be
 * used as enums.
 */
class Enum extends AquaHotkey_Ignore {
    /**
     * Static init. Adds all read-only static members of the class into two
     * maps `Name` and `Value`, which return the name or value of the enum
     * member.
     */
    static __New() {
        static GetOwnPropDesc := (Object.Prototype.GetOwnPropDesc)
        static Define := (Object.Prototype.DefineProp)

        if (this == Tanuki.Enum) {
            return
        }

        Names := Map()
        Values := Map()
        Names.CaseSense := false
        Values.CaseSense := false

        for Name in ObjOwnProps(this) {
            PropDesc := GetOwnPropDesc(this, Name)
            if (ObjOwnPropCount(PropDesc) != 1) {
                continue
            }
            if (!ObjHasOwnProp(PropDesc, "Get")) {
                continue
            }

            Value := (PropDesc.Get)(this)
            Values.Set(Name, Value)
            Values.Set(Value, Value)
            Names.Set(Name, Name)
            Names.Set(Value, Name)
        }

        Define(this, "Value", { Get: (_, Key) => Values.Get(Key) })
        Define(this, "Name",  { Get: (_, Key) => Names.Get(Key)  })
    }
}

/**
 * 
 */
class Color extends AquaHotkey_Ignore {
    static SwapRB(ColorRGB) {
        return ((ColorRGB & 0xFF0000) >> 16)
             | ((ColorRGB & 0x00FF00)      )
             | ((ColorRGB & 0x0000FF) << 16)
    }

    ; TODO Brighter / Darker
}

; } class Tanuki