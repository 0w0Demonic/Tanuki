#Requires AutoHotkey v2.0
#Include <Tanuki\Util\MapChain>
/**
 * A reusable framework for dispatching window messages and notifications.
 * 
 * It offers a clean and object-oriented way to register messages,
 * notifications and commands, inheriting down a chain of maps for reuse and
 * specialization.
 * 
 * The class can be used directly or subclassed to build reusable window
 * procedures.
 * 
 * At its core, {@link WindowProcedure#Call `Call()`} is responsible for
 * dispatching all of the messages, notifications and commands set by the
 * user. To apply this method as function pointer, use
 * {@link WindowProcedure#CallbackCreate `CallbackCreate()`}.
 */
class WindowProcedure {
    ;@region Construction
    /**
     * Initializes static members for the prototype.
     * 
     * It defines maps `Messages`, `Notifs` and `Commands` that inherit
     * from the parent class's maps, and outputs the bound instance methods
     * `OnMessage`, `OnNotify` and `OnCommand` as `VarRef` for convenience.
     * 
     * @example
     * class DialogProc extends WindowProcedure {
     *     static __New() {
     *         super.__New(&Msg, &Ntf, &Cmd)
     *         Msg(WM_MOVE, (*) => ToolTip("moving..."))
     *         Cmd(BN_CLICKED, "Click")
     *     }
     *     Click(Hwnd) => MsgBox("button clicked!")
     * }
     * @param   {VarRef<Func>?}  Msg  (out) `OnMessage()` method
     * @param   {VarRef<Func>?}  Ntf  (out) `OnNotify()` method
     * @param   {VarRef<Func>?}  Cmd  (out) `OnCommand()` method
     */
    static __New(&Msg?, &Ntf?, &Cmd?) {
        static CreateGetter(Value) => { Get: (_) => Value }
        static Nop(*) => false

        static Properties := Array("Messages", "Notifs", "Commands")
        static Define := {}.DefineProp

        Msg := ObjBindMethod(this.Prototype, "OnMessage")
        Ntf := ObjBindMethod(this.Prototype, "OnNotify")
        Cmd := ObjBindMethod(this.Prototype, "OnCommand")

        if (this == WindowProcedure) {
            for Property in Properties {
                BaseMap := MapChain.Base()
                BaseMap.Default := Nop
                Define(this.Prototype, Property, CreateGetter(BaseMap))
            }
        } else {
            for Property in Properties {
                BaseMap := ObjGetBase(this).Prototype.%Property%
                DerivingMap := MapChain.Extend(BaseMap)
                Define(this.Prototype, Property, CreateGetter(DerivingMap))
            }
        }
    }

    /**
     * Initializes a new window procedure.
     * 
     * @param   {VarRef<Func>?}  Msg    (out) `OnMessage()` method
     * @param   {VarRef<Func>?}  Notif  (out) `OnNotify()` method
     * @param   {VarRef<Func>?}  Cmd    (out) `OnCommand()` method
     */
    __New(&Msg?, &Ntf?, &Cmd?) {
        Msg := ObjBindMethod(this, "OnMessage")
        Ntf := ObjBindMethod(this, "OnNotify")
        Cmd := ObjBindMethod(this, "OnCommand")
    }

    /**
     * Creates a function pointer for this window procedure.
     * 
     * An external reference to the object must be kept in order to keep the
     * function pointer valid.
     * 
     * @returns {Integer}
     */
    CallbackCreate() => CallbackCreate(this.Call, "Fast", 4)
    ;@endregion

    ;@region Entry Point
    /**
     * Dispatch entry point. Use {@link WindowProcedure#CallbackCreate} to
     * create a function pointer.
     * 
     * @param   {Integer}  Hwnd    a handle to the window
     * @param   {Integer}  Msg     the message code
     * @param   {Integer}  wParam  wParam of the message
     * @param   {Integer}  lParam  lParam of the message
     * @returns {Integer}
     */
    Call(Hwnd, Msg, wParam, lParam) {
        switch (Msg) {
            ; WM_NOTIFY
            case 0x004E:
                ControlId := NumGet(lParam + 8, "Ptr")
                Code := NumGet(lParam + 16, "UInt")
                ControlHwnd := NumGet(lParam, "Ptr")
                if (Fn := (this.Notifs).Get(ControlId << 32 | Code, 0)) {
                    return Fn(ControlHwnd, lParam)
                }
                return (this.Notifs)[Code](ControlHwnd, lParam)
            ; WM_COMMAND
            case 0x0111:
                if (Fn := (this.Commands).Get(wParam, 0)) {
                    return Fn(lParam)
                }
                return (this.Commands)[wParam >>> 16](lParam)
            default:
                if (Fn := (this.Messages).Get(Msg, 0)) {
                    return Fn(wParam, lParam, Msg, Hwnd)
                }
                return (this.Messages)[0](wParam, lParam, Msg, Hwnd)
        }
    }
    ;@endregion

    ;@region Event Registering
    /**
     * Registers a message callback.
     * 
     * @example
     * MessageCallback(wParam, lParam, Msg, Hwnd) {
     *     ; ...
     * }
     * 
     * @param   {Integer}      Msg        the message to register a callback for
     * @param   {Func/String}  Callback   the function to be called/method name
     * @returns {this}
     */
    OnMessage(Msg, Callback) {
        Callback := this._Validate(Callback, Msg, 32)
        this._CreateIfAbsent("Messages")
        (this.Messages).Set(Msg, Callback)
        return this
    }

    /**
     * Registers a notification.
     * 
     * @example
     * NotifCallback(Hwnd, lParam) {
     *     ; ...
     * }
     * 
     * @param   {Integer}      ControlId  control ID of the control
     * @param   {Integer}      Msg        the message to register a callback for
     * @param   {Func/String}  Callback   the function to be called/method name
     * @returns {this}
     */
    OnNotify(ControlId, Notif, Callback) {
        Callback := this._Validate(Callback, Notif, 32, ControlId)
        this._CreateIfAbsent("Notifications")
        (this.Notifs).Set((ControlId << 32) | Notif, Callback)
        return this
    }

    /**
     * Registers a message callback.
     * 
     * @example
     * CommandCallback(Hwnd) {
     *     ; ...
     * }
     * 
     * @param   {Integer}      ControlId  control ID of the control
     * @param   {Integer}      Msg        the message to register a callback for
     * @param   {Func/String}  Callback   the function to be called/method name
     * @returns {this}
     */
    OnCommand(ControlID, Cmd, Callback) {
        Callback := this._Validate(Callback, Cmd, 16, ControlId)
        this._CreateIfAbsent("Commands")
        (this.Commands).Set(Cmd << 16 | ControlID, Callback)
        return this
    }

    ; param validation for `OnMessage`, `OnNotify`, `OnCommand`
    _Validate(Callback, Num, NumSizeBits, ControlId := 0) {
        if (!IsInteger(Num)) {
            throw TypeError("Expected an Integer",, Type(Callback))
        }
        if (Num >>> NumSizeBits) {
            throw ValueError("Must be a " . NumSizeBits "-bit value",, Num)
        }
        if (!IsInteger(ControlId)) {
            throw TypeError("Expected an Integer",, Type(ControlId))
        }
        if (ControlId >>> 16) {
            throw ValueError("Must be a 16-bit value",, ControlId)
        }
        if (Callback is String) {
            if (!HasProp(this, Callback)) {
                throw UnsetError("Has no method named " . Callback)
            }
            Callback := ObjBindMethod(this, Callback)
        }
        GetMethod(Callback)
        return Callback
    }

    ; if absent, creates an own map that inherits from the parent class's map
    _CreateIfAbsent(PropertyName) {
        if (!ObjHasOwnProp(this, PropertyName)) {
            DerivingMap := MapChain.Extend(this.Messages)
            ({}.DefineProp)(this, PropertyName, { Value: DerivingMap })
        }
    }
    ;@endregion
}
