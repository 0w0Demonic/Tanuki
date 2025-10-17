#Requires AutoHotkey v2.0
#Include <AquaHotkey>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\Apis>
#Include <AhkWin32Projection\Windows\Win32\UI\Controls\PBRANGE>

/**
 * Extension class for progress bars.
 * 
 * ```
 * class Gui
 * |- AddMarqueeProgress(Opt?, Interval := 30)
 * |
 * |- class Progress
 * |  |- Step(Value?)
 * |  |- Step { get; set; }
 * |  |- BarColor { get; set; }
 * |  |- BackColor { get; set; }
 * |  |
 * |  |- class State
 * |  |  |- static Normal { get; }
 * |  |  |- static Paused { get; }
 * |  |  `- static Error { get; }
 * |  |
 * |  |- State { get; set; }
 * |  |- Value { get; set; }
 * |  |- Min { get; set; }
 * |  |- Max { get; set; }
 * |  |- GetRange(&Low, &High)
 * |  `- SetRange(Low, High)
 * | 
 * `- class MarqueeProgress extends Gui.Progress
 *    |- Interval { get; set; }
 *    |- IsRunning { get; }
 *    |- Start()
 *    `- Stop()
 * ```
 */
class Tanuki_ProgressBar extends AquaHotkey {
class Gui {
    /**
     * Adds a marquee style progress bar to the GUI.
     * 
     * The highlighted part of the progress bar moves repeatedly along the
     * length of the bar, animated in a way that shows activity without showing
     * the proportion of the task.
     * 
     * @param   {String?}   Opt       options string
     * @param   {Integer?}  Interval  update interval of the animation in ms
     * @returns {Gui.MarqueeProgress}
     */
    AddMarqueeProgress(Opt?, Interval := 30) {
        Prog := this.AddProgress(Opt?)
        ControlSetStyle("+" . Controls.PBS_MARQUEE, Prog)
        ObjSetBase(Prog, Gui.MarqueeProgress.Prototype)
        if (!IsInteger(Interval)) {
            throw TypeError("Expected an Integer",, Type(Interval))
        }
        Prog.Interval := Interval
        return Prog
    }

    class Progress {
        /**
         * Advanced the current position by the step increment and redraws the
         * bar to reflect the new position. You can change the default step
         * increment by setting the `Step` property, or by passing `Value`
         * to advance the current position by the given amount.
         * 
         * Not supported for marquee progress bars.
         * 
         * @param   {Integer?}  Value  the amount to increment
         */
        Step(Value?) {
            if (this is Gui.MarqueeProgress) {
                throw TypeError("not supported for marquee progress bars")
            }
            if (!IsSet(Value)) {
                return SendMessage(Controls.PBM_STEPIT, 0, 0, this)
            }
            if (!IsInteger(Value)) {
                throw TypeError("Expected an Integer",, Type(Value))
            }
            this.Step := Value
            SendMessage(Controls.PBM_DELTAPOS, Value, 0, this)
        }

        /**
         * Gets and sets the increment from the progress bar. The step increment
         * is the amount by which the progress bar increases when the `Step()`
         * method is called.
         * 
         * @param   {Integer}  Value  the new step increment
         * @returns {Integer}
         */
        Step {
            get => SendMessage(Controls.PBM_GETSTEP, 0, 0, this)
            set => SendMessage(Controls.PBM_SETSTEP, value, 0, this)
        }

        /**
         * Gets and sets the color of the progress bar.
         * `Controls.CLR_DEFAULT` is used as default color.
         * 
         * @param   {Integer}  Value  the COLORREF value that specifies color
         * @returns {Integer}
         */
        BarColor {
            get => SendMessage(Controls.PBM_GETBARCOLOR, 0, 0, this)
            set => SendMessage(Controls.PBM_SETBARCOLOR, 0, value, this)
        }

        /**
         * Gets and sets the background color of the progress bar.
         * `Controls.CLR_DEFAULT` is used as default color.
         * 
         * @param   {Integer}  Value  the COLORREF value that specifies color
         * @returns {Integer}
         */
        BackColor {
            get => SendMessage(Controls.PBM_GETBKCOLOR, 0, 0, this)
            set => SendMessage(Controls.PBM_SETBKCOLOR, 0, value, this)
        }

        /**
         * Progress bar states.
         */
        class State {
            static Normal => Controls.PBST_NORMAL
            static Pause => Controls.PBST_PAUSED
            static Error => Controls.PBST_ERROR
        }

        /**
         * Gets and sets the state of the progress bar.
         * 
         * It can be one of the values in `Gui.Progress.State.*` or
         * `Controls.PBST*`.
         * 
         * @param   {Integer}  Value  the new state
         * @returns {Integer}
         */
        State {
            get => SendMessage(Controls.PBM_GETSTATE, 0, 0, this)
            set => SendMessage(Controls.PBM_SETSTATE, value, 0, this)
        }

        /**
         * Gets and sets the current position for the progress bar.
         * 
         * Not supported for marquee progress bars.
         * 
         * @param   {Integer}  Value  the new position
         * @returns {Integer}
         */
        Value {
            get => SendMessage(Controls.PBM_GETPOS, 0, 0, this)
            set {
                if (!IsInteger(value)) {
                    throw TypeError("Expected an Integer",, Type(value))
                }
                if (this is Gui.MarqueeProgress) {
                    throw TypeError("Not supported for marquee progress bars")
                }
                SendMessage(Controls.PBM_SETPOS, value, 0, this)
            }
        }

        /**
         * Gets and sets the lower limit of the progress bar.
         * 
         * @param   {Integer}  Value  the lower limit
         * @returns {Integer}
         */
        Min {
            get => SendMessage(Controls.PBM_GETRANGE, true, 0, this)
            set => this.SetRange(value, this.Max)
        }

        /**
         * Gets and sets the upper limit of the progress bar.
         * 
         * @param   {Integer}  Value  the upper limit
         * @returns {Integer}
         */
        Max {
            get => SendMessage(Controls.PBM_GETRANGE, false, 0, this)
            set => this.SetRange(this.Min, value)
        }

        /**
         * Retrieves information about the current upper and lower limits of the
         * progress bar.
         * 
         * @param   {VarRef<Integer>}  Min  (out) the lower limit
         * @param   {VarRef<Integer>}  Max  (out) the higher limit
         */
        GetRange(&Min, &Max) {
            SendMessage(Controls.PBM_GETRANGE, 0, Range := PBRANGE(), this)
            Min := Range.iLow
            Max := Range.iHigh
        }

        /**
         * Sets the minimum and maximum values for a progress bar.
         * 
         * @param   {Integer}  Min  the lower limit
         * @param   {Integer}  Max  the upper limit
         */
        SetRange(Min, Max) {
            if (!IsInteger(Min)) {
                throw TypeError("Expected an Integer",, Type(Min))
            }
            if (!IsInteger(Max)) {
                throw TypeError("Expected an Integer",, Type(Max))
            }
            SendMessage(Controls.PBMSETRANGE32, Min, Max, this)
        }
    } ; class Progress

    /**
     * A marquee style progress bar is a type of progress bar in which the
     * highlighted part moves repeated along the length of the bar, animated
     * in a way that shows activity without showing the proportion of the task.
     * 
     * Use `Gui#AddMarqueeProgress()` to create a new marquee progress bar.
     */
    class MarqueeProgress extends Gui.Progress {
        /**
         * Gets and sets the interval in milliseconds in which the marquee
         * animation updates.
         * 
         * @param   {Integer}  Value  the interval in milliseconds
         * @returns {Integer}
         */
        Interval {
            get => 30
            set {
                if (!IsInteger(value)) {
                    throw TypeError("Expected an Integer",, Type(value))
                }
                this.DefineProp("Interval", { Get: (_) => value })
                SendMessage(Controls.PBM_SETMARQUEE, value, this.Interval, this)
            }
        }

        /**
         * Determines whether the marquee animation is running.
         * 
         * @param   {Boolean}  Value  whether the marquee animation is running
         * @returns {Boolean}
         */
        IsRunning {
            get => false
            set {
                value := !!value
                this.DefineProp("IsRunning", { Get: (_) => value })
                SendMessage(Controls.PBM_SETMARQUEE, value, this.Interval, this)
            }
        }

        /**
         * Starts the marquee animation.
         */
        Start() {
            SendMessage(Controls.PBM_SETMARQUEE, true, this.Interval, this)
            this.DefineProp("IsRunning", { Get: (_) => true })
        }

        /**
         * Stops the marquee animation.
         */
        Stop() {
            SendMessage(Controls.PBM_SETMARQUEE, false, this.Interval, this)
            this.DefineProp("IsRunning", { Get: (_) => false })
        }

        /**
         * Returns the type of GUI control.
         * @returns {String}
         */
        Type => "MarqueeProgress"
    } ; class MarqueeProgress extends Gui.Progress
} ; class Gui
} ; class Tanuki_ProgressBar extends AquaHotkey