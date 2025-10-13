#Requires AutoHotkey v2.0

/**
 * A subclass of `Buffer` that adds an internal write position and convenience
 * methods for appending data sequentially. It's useful for creating binary
 * payloads without manually tracking offsets.
 */
class AppendableBuffer extends Buffer {
    /**
     * Internal write position.
     * 
     * @type {Integer}
     */
    Pos := 0

    /**
     * Aligns to the next boundary of the specified byte size.
     * If the current position isn't already aligned, the method advances `Pos`
     * to the next multiple of `Align`, padding with `0`.
     * 
     * `Align` must be a power of 2.
     * 
     * @param   {Integer}  Align  the byte size to align with
     * @returns {this}
     */
    Align(Align) {
        if (Align & (Align - 1)) {
            throw ValueError("Must be a power of 2",, Format("{:#X}", Align))
        }
        Mask := (Align - 1)
        NewPos := (this.Pos + Mask) & ~Mask
        Size := NewPos - this.Pos
        this.EnsureCapacity(Size)

        Loop (Size) {
            Offset := (A_Index - 1)
            NumPut("UChar", 0, this, this.Pos + Offset)
        }
        this.Pos += Size
        return this
    }

    /**
     * Adds a `Char` to the buffer.
     * 
     * @param   {Integer}  Value  a `Char` value
     * @returns {this}
     */
    AddChar(Value) => this.Add(Value, "Char", 1)

    /**
     * Adds a `UChar` to the buffer.
     * 
     * @param   {Integer}  Value  a `UChar` value
     * @returns {this}
     */
    AddUChar(Value) => this.Add(Value, "UChar", 1)

    /**
     * Adds a `Short` to the buffer.
     * 
     * @param   {Integer}  Value  a `Short` value
     * @returns {this}
     */
    AddShort(Value) => this.Add(Value, "Short", 2)

    /**
     * Adds a `UShort` to the buffer.
     * 
     * @param   {Integer}  Value  a `UShort` value
     * @returns {this}
     */
    AddUShort(Value) => this.Add(Value, "UShort", 2)

    /**
     * Adds an `Int` to the buffer.
     * 
     * @param   {Integer}  Value  an `Int` value
     * @returns {this}
     */
    AddInt(Value) => this.Add(Value, "Int", 4)

    /**
     * Adds a `UInt` to the buffer.
     * 
     * @param   {Integer}  Value  a `UInt` value
     * @returns {this}
     */
    AddUInt(Value) => this.Add(Value, "UInt", 4)

    /**
     * Adds an `Int64` to the buffer.
     * 
     * @param   {Integer}  Value  an `Int64` value
     * @returns {this}
     */
    AddInt64(Value) => this.Add(Value, "Int64", 8)

    /**
     * Adds a `UInt64` to the buffer.
     * 
     * @param   {Integer}  Value  a `UInt64` value
     * @returns {this}
     */
    AddUInt64(Value) => this.Add(Value, "UInt64", 8)

    /**
     * Adds a `Ptr` to the buffer.
     * 
     * @param   {Integer}  Value  a `Ptr` value
     * @returns {this}
     */
    AddPtr(Value) => this.Add(Value, "Ptr", A_PtrSize)

    /**
     * Adds a `UPtr` to the buffer.
     * 
     * @param   {Integer}  Value  a `UPtr` value
     * @returns {this}
     */
    AddUPtr(Value) => this.Add(Value, "UPtr", A_PtrSize)

    /**
     * Adds a `Float` to the buffer.
     * 
     * @param   {Float}  Value  a `Float` value
     * @returns {this}
     */
    AddFloat(Value) => this.Add(Value, "Float", 4)

    /**
     * Adds a `Double` to the buffer.
     * 
     * @param   {Float}  Value  a `Double` value
     * @returns {this}
     */
    AddDouble(Value) => this.Add(Value, "Double", 8)

    /**
     * Adds a memory block to the buffer.
     * 
     * @param   {Buffer/Integer}  Mem   pointer or buffer object
     * @param   {Integer?}        Size  size in bytes
     * @returns {this}
     */
    AddData(Mem, Size := Mem.Size) {
        this.EnsureCapacity(Size)
        Loop Size {
            Offset := (A_Index - 1)
            Value := NumGet(Mem, Offset, "UChar")
            NumPut("UChar", Value, this, this.Pos + Offset)
        }
        this.Pos += Size
        return this
    }

    /**
     * Adds a string to the buffer.
     * 
     * @param   {String}            Str       the string to be written
     * @param   {Integer?/String?}  Encoding  encoding of the string
     * @returns {this}
     */
    AddString(Str, Encoding := "UTF-16") {
        Size := StrPut(Str, Encoding)
        this.EnsureCapacity(Size)
        StrPut(Str, this.Ptr + this.Pos, Encoding)
        this.Pos += Size
        return this
    }

    /**
     * Adds a number to the buffer.
     * 
     * @param   {Integer}  Value     the number to be set
     * @param   {String}   DataType  number type
     * @param   {Integer}  Size      size in bytes
     * @returns {this}
     */
    Add(Value, DataType, Size) {
        this.EnsureCapacity(Size)
        NumPut(DataType, Value, this, this.Pos)
        this.Pos += Size
        return this
    }

    /**
     * Ensures that the write position can be advanced by `Size`, increasing
     * the buffer size when the maximum capacity is reached.
     * 
     * @param   {Integer}  Size  the number of bytes to advance
     * @returns {this}
     */
    EnsureCapacity(Size) {
        while ((this.Pos + Size) > this.Size) {
            this.Size *= 2
        }
        return this
    }
}
