#Requires AutoHotkey v2.0

class AppendableBuffer extends Buffer {
    Offset {
        get {
            this.DefineProp("Offset", { Value: 0 })
            return 0
        }
    }

    ; TODO add more
    AppendUShort(Value) {
        if (!IsInteger(Value)) {
            throw TypeError("Expected an Integer",, Type(Value))
        }
        this.EnsureCapacity(2)
        NumPut("UShort", Value, this, Offset)
        Offset += 2
        return this
    }

    AppendData(Mem, Size := Mem.Size) {
        this.EnsureCapacity(Size)
        Offset := this.Offset
        Loop Size {
            Num := NumGet(Mem, Offset, "UChar")
            NumPut("UChar", Num, this, Offset)
            Offset++
        }
        this.Offset := Offset
        return this
    }

    AppendString(Str, Encoding?) {
        if (!(Str is String)) {
            throw TypeError("Expected a String",, Type(Str))
        }
        if (IsSet(Encoding)) {
            Size := StrPut(Str, Encoding?)
        } else {
            Size := StrPut(Str)
        }
        this.EnsureCapacity(Size)
        StrPut(Str, this.Ptr + this.Offset, Size)
        return this
    }

    Align(Size) {
        ; asserts that this is a 2^n integer
        if (!(Size & (Size - 1))) {
            throw ValueError("Expected a poewr of 2",, Size)
        }
    }

    /**
     * 
     */
    EnsureCapacity(Size) {
        Size := Abs(Size & Size)
        while ((this.Offset + Size) > this.Size) {
            this.Size *= 2
        }
        return this
    }
}