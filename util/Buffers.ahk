#Requires AutoHotkey 2.0

/**
 * Buffer utilities.
 */
class Buffers extends Any {
    /**
     * Creates a `Buffer` that contains the given string.
     * 
     * @param   {String}          Str       string to be written into the buffer
     * @param   {String/Integer}  Encoding  target encoding (default UTF-16)
     * @returns {Buffer}
     */
    static FromString(Str, Encoding := "UTF-16") {
        if (!(Str is String)) {
            throw TypeError("Expected a String",, Type(Str))
        }
        Size := StrPut(Str, Encoding)
        Buf := Buffer(Size, 0)
        StrPut(Str, Buf, Encoding)
        return Buf
    }
}