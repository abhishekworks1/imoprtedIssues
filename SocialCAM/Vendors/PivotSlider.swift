import UIKit


/// PivotSlider shows the track of value from the pivot.
open class PivotSlider: UIControl {
    open var track: UIView!

    /// The track of `value` from `pivotValue`.
    open var valueTrack: UIView!

    open var thumb: UIView!

    override open var frame: CGRect {
        didSet {
            // Make sure subviews are centered.
            if self.track != nil {
                self.track.center.y = self.frame.height / 2
                self.track.frame.size.width = self.frame.width
                self.valueTrack.center.y = self.frame.height / 2
                self.thumb.center.y = self.frame.height / 2
                self.moveThumb()
            }
        }
    }

    /// The default value is `-1.0`.
    open var minimumValue: Float = -1.0 {
        didSet {
            if self.maximumValue < self.minimumValue {
                self.maximumValue = self.minimumValue
            }

            self.value = self.validValue(of: self.value)
        }
    }

    /// The default value is `1.0`.
    open var maximumValue: Float = 1.0 {
        didSet {
            if self.minimumValue > self.maximumValue {
                self.minimumValue = self.maximumValue
            }

            self.value = self.validValue(of: self.value)
        }
    }

    /// The value that is one of the endpoints of `valueTrack`. The default value is `0.0`.
    open var pivotValue: Float = 0.0 {
        didSet {
            self.pivotValue = self.validValue(of: self.pivotValue)
            self.moveThumb()
        }
    }

    /// The default value is `0.0`.
    open var value: Float = 0.0 {
        didSet {
            self.value = self.validValue(of: self.value)
            self.moveThumb()
        }
    }

    /// A Boolean value indicating whether changes in the pivot slider’s value generate continuous update events. The default value is `true`.
    open var isContinuous: Bool = true

    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.track = UIView(frame: CGRect(x: 15, y: self.frame.height / 2 - 1.5, width: self.frame.width - 30, height: 3))
        self.track.backgroundColor = UIColor(white: 0.5, alpha: 1)
        self.track.isUserInteractionEnabled = false
        self.addSubview(self.track)

        self.valueTrack = UIView(frame: CGRect(x: self.frame.width / 2, y: self.frame.height / 2 - 1.5, width: 0, height: 3))
        self.valueTrack.backgroundColor = ApplicationSettings.appWhiteColor
        self.valueTrack.isUserInteractionEnabled = false
        self.addSubview(self.valueTrack)

        self.thumb = UIView(frame: CGRect(x: self.frame.width / 2 - 15, y: self.frame.height / 2 - 15, width: 30, height: 30))
        self.thumb.backgroundColor = ApplicationSettings.appWhiteColor
        self.thumb.layer.cornerRadius = 15
        self.thumb.layer.borderColor = UIColor(white: 0.5, alpha: 1).cgColor
        self.thumb.layer.borderWidth = 1
        self.thumb.isUserInteractionEnabled = false
        self.addSubview(self.thumb)
    }

    required public init(coder: NSCoder) {
        super.init(coder: coder)!
    }

    /// Make sure the value is within the range between `minimumValue` and `maximumValue`.
    private func validValue(of value: Float) -> Float {
        if value < self.minimumValue {
            return self.minimumValue
        }

        if value > self.maximumValue {
            return self.maximumValue
        }

        return value
    }

    /// Convert the value to the `x` of `origin`.
    private func x(for value: Float) -> CGFloat {
        if self.maximumValue == self.minimumValue {
            return self.thumb.frame.width / 2
        }

        return CGFloat((value - self.minimumValue) / (self.maximumValue - self.minimumValue)) * (self.frame.width - self.thumb.frame.width) + self.thumb.frame.width / 2
    }

    /// Convert the value to the `width` of `valueTrack`.
    private func width(for value: Float) -> CGFloat {
        if self.maximumValue == self.minimumValue {
            return 0
        }

        return CGFloat(abs(value - self.pivotValue) / (self.maximumValue - self.minimumValue)) * (self.frame.width - self.thumb.frame.width)
    }

    /// Convert the x of `origin` to the correspoding `value`.
    private func value(for x: CGFloat) -> Float {
        if self.maximumValue == self.minimumValue {
            return self.minimumValue
        }

        return self.minimumValue + Float((x - (self.thumb.frame.width / 2)) / (self.frame.width - self.thumb.frame.width)) * (self.maximumValue - self.minimumValue)
    }

    /// Move `thumb` to the correspoding position of `value`.
    private func moveThumb() {
        if self.value < self.pivotValue {
            self.valueTrack.frame.origin.x = self.x(for: self.value)
            self.valueTrack.frame.size.width = self.width(for: self.value)
        } else {
            self.valueTrack.frame.origin.x = self.x(for: self.pivotValue)
            self.valueTrack.frame.size.width = self.width(for: self.value)
        }

        self.thumb.center.x = self.x(for: self.value)
    }

    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return self.thumb.frame.contains(touch.location(in: self))
    }

    override open func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        self.value = self.value(for: location.x)

        if self.isContinuous {
            self.sendActions(for: .valueChanged)
        }

        return true
    }
    
    override open func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        self.sendActions(for: .valueChanged)
        self.sendActions(for: .touchDragExit)
    }
    
}
