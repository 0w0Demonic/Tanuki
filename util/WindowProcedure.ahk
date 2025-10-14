#Requires AutoHotkey v2.0
#Include <Tanuki\util\MapChain>
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
 * At its core, {@link WindowProcedure#Call} is responsible for dispatching
 * all of the messages, notifications and commands set up by the user.
 * To apply this method as function pointer, 
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
     *         super.__New(&Msg, &Notif, &Cmd)
     *         Msg(WM_MOVE, (*) => ToolTip("moving..."))
     *         Cmd(BN_CLICKED, "Click")
     *     }
     *     Click(Hwnd) => MsgBox("button clicked!")
     * }
     * @param   {VarRef<Func>?}  Msg    (out) `OnMessage()` method
     * @param   {VarRef<Func>?}  Notif  (out) `OnNotify()` method
     * @param   {VarRef<Func>?}  Cmd    (out) `OnCommand()` method
     */
    static __New(&Msg?, &Notif?, &Cmd?) {
        static CreateGetter(Value) => { Get: (_) => Value }
        static Nop(*) => false

        static Properties := Array("Messages", "Notifs", "Commands")
        static Define := {}.DefineProp

        Msg   := ObjBindMethod(this.Prototype, "OnMessage")
        Notif := ObjBindMethod(this.Prototype, "OnNotify")
        Cmd   := ObjBindMethod(this.Prototype, "OnCommand")

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
    __New(&Msg?, &Notif?, &Cmd?) {
        Msg   := ObjBindMethod(this, "OnMessage")
        Notif := ObjBindMethod(this, "OnNotify")
        Cmd   := ObjBindMethod(this, "OnCommand")
    }

    /**
     * Creates a function pointer for this window procedure.
     * 
     * An external reference to the object must be kept in order to keep the
     * function pointer valid.
     * 
     * @returns {Integer}
     */
    CreateCallback() => CallbackCreate(this.Call, "Fast", 4)
    ;@endregion

    ;@region Entry Point
    /**
     * Dispatch entry point. Use {@link WindowProcedure#CreateCallback} to
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
            case 0x0000004E:
                ; ((NMHDR)lParam)->code
                return (this.Notifs)[NumGet(lParam, 16, "UInt")](Hwnd, lParam)
            ; WM_COMMAND
            case 0x00000111:
                ; upper WORD as control-specific command
                return (this.Commands)[wParam >>> 16](Hwnd)
            default:
                return (this.Messages)[Msg](wParam, lParam, Msg, Hwnd)
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
     * @param   {Integer}      Msg       the message to register a callback for
     * @param   {Func/String}  Callback  the function to be called/method name
     * @returns {this}
     */
    OnMessage(Msg, Callback) {
        Callback := this._Validate(Msg, Callback)
        if (!ObjHasOwnProp(this, "Messages")) {
            DerivingMap := MapChain.Extend(this.Message)
            ({}.DefineProp)(this, "Messages", { Value: DerivingMap })
        }
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
     * @param   {Integer}      Msg       the message to register a callback for
     * @param   {Func/String}  Callback  the function to be called/method name
     * @returns {this}
     */
    OnNotify(Notif, Callback) {
        Callback := this._Validate(Notif, Callback)
        if (!ObjHasOwnProp(this, "Messages")) {
            DerivingMap := MapChain.Extend(this.Message)
            ({}.DefineProp)(this, "Messages", { Value: DerivingMap })
        }
        (this.Notifs).Set(Notif, Callback)
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
     * @param   {Integer}      Msg       the message to register a callback for
     * @param   {Func/String}  Callback  the function to be called/method name
     * @returns {this}
     */
    OnCommand(Cmd, Callback) {
        Callback := this._Validate(Cmd, Callback)
        if (!ObjHasOwnProp(this, "Messages")) {
            DerivingMap := MapChain.Extend(this.Message)
            ({}.DefineProp)(this, "Messages", { Value: DerivingMap })
        }
        (this.Commands).Set(Cmd, Callback)
        return this
    }

    ; param validation for `OnMessage`, `OnNotify`, `OnCommand`
    _Validate(Num, Callback) {
        if (!IsInteger(Num)) {
            throw TypeError("Expected an Integer",, Type(Callback))
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
    ;@endregion
}
