#Include <AquaHotkey>
#Include <AquaHotkey\Src\Extensions\Stream>
#Include <AquaHotkey\Src\Builtins\ToString>
/**
 * Quick and dirty util for property dumps.
 * 
 * ```
 * class Object
 * |- DumpProps() (v2.1-alpha.10+)
 * `- DumpOwnProps()
 * 
 * class ClipboardAll
 * `- DumpAll()
 * ```
 */
class Tanuki_Util_Dump extends AquaHotkey {
    class Object {
        static __New() {
            if (VerCompare(A_AhkVersion, "<v2.1-alpha.10")) {
                OutputDebug("[Aqua] unavailable: Object#DumpProps()")
                this.Prototype.DeleteProp("DumpProps")
            }
        }

        DumpProps() {
            return this.PropsStream()
                    .Map((K, V := "(empty)") => (K . " = " . String(V)))
                    .JoinLine()
        }

        DumpOwnProps() {
            return this.OwnPropsStream()
                    .Map((K, V := "(empty)") => (K . " = " . String(V)))
                    .JoinLine()
        }
    }

    class ClipboardAll {
        DumpAll() => Format("
        (
        -----
        {}
        -----

        {}
        )", this.HexDump(), this.DumpProps())
    }
}