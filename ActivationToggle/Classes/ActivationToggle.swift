//
//  ActivationToggle.swift
//
//  Created by Nikta Belosludtcev on 08.06.2018.
//  Copyright © 2018 Nikta Belosludtcev. All rights reserved.
//

import UIKit

private extension CGPoint {
    static func -(l: CGPoint, r: CGPoint) -> CGPoint { return CGPoint(x: l.x - r.x, y: l.y - r.y) }
    static func +(l: CGPoint, r: CGPoint) -> CGPoint { return CGPoint(x: l.x + r.x, y: l.y + r.y) }
    
    static func -(l: CGPoint, r: CGFloat) -> CGPoint { return CGPoint(x: l.x - r, y: l.y - r) }
    static func +(l: CGPoint, r: CGFloat) -> CGPoint { return CGPoint(x: l.x + r, y: l.y + r) }
    static func *(l: CGPoint, r: CGFloat) -> CGPoint { return CGPoint(x: l.x * r, y: l.y * r) }
    static func /(l: CGPoint, r: CGFloat) -> CGPoint { return CGPoint(x: l.x / r, y: l.y / r) }
}

class ToggleLayer: CAShapeLayer, CAAnimationDelegate {
    
    private(set) var isOn = false
    
    func setIsOn(_ isOn: Bool, animated: Bool) {
        isOn ? setOn(animated: animated) : setOff(animated: animated)
    }
    
    override var frame: CGRect {
        didSet {
            path = pathToggle(center: CGPoint(x: bounds.height / 2, y: bounds.height / 2))
        }
    }
    
    var activateAnimationDuration: CFTimeInterval = 0.3
    var deactivateAnimationDuration: CFTimeInterval = 0.3
    
    var toggleColor: UIColor = UIColor.white {
        didSet {
           fillColor = toggleColor.cgColor
        }
    }
    
    var isShowSadow: Bool = true {
        didSet {
            shadowColor = isShowSadow ? UIColor.black.cgColor : UIColor.clear.cgColor
            shadowOpacity = isShowSadow ? 0.5 : 0.0
            shadowOffset = isShowSadow ?  CGSize(width: 0, height: 1) : CGSize(width: 0, height: 0)
        }
    }
    
    var inset: CGFloat = 2
    var toggleRadius: CGFloat {
        return bounds.height / 2 - inset
    }
    
    override init() {
        super.init()
        commonInit()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        fillColor = toggleColor.cgColor
        path = pathToggle(center: CGPoint(x: bounds.height / 2, y: bounds.height / 2))
        
        isShowSadow = true
        lineCap = kCALineCapRound
        lineJoin = kCALineJoinRound
        lineWidth = 2
    }
    
    // MARK: - Pathes for toggle states
    
    private func pathToggle(center: CGPoint) -> CGPath {
        let path = UIBezierPath(roundedRect: CGRect(x: center.x - toggleRadius, y: center.y - toggleRadius, width: 2 * toggleRadius, height: 2 * toggleRadius), cornerRadius: toggleRadius)
        
        return path.cgPath
    }
    
    private func pathMinus(center: CGPoint) -> CGPath {
        let path = UIBezierPath(roundedRect: CGRect(x: center.x - 9, y: center.y - 1, width: 18, height: 2), cornerRadius: 1)
        return path.cgPath
    }
    
    private func pathSeparatedMinus(center: CGPoint) -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: center.x - 8, y: center.y))
        path.addLine(to: CGPoint(x: center.x - 3, y: center.y))
        path.addLine(to: CGPoint(x: center.x + 8, y: center.y))
        return path.cgPath
    }
    
    private func pathCheckmark(center: CGPoint) -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.344, y: 0.531) * bounds.height + center - CGPoint(x: bounds.height / 2, y: bounds.height / 2))
        path.addLine(to: CGPoint(x: 0.438, y: 0.625) * bounds.height + center - CGPoint(x: bounds.height / 2, y: bounds.height / 2))
        path.addLine(to: CGPoint(x: 0.656, y: 0.406) * bounds.height + center - CGPoint(x: bounds.height / 2, y: bounds.height / 2))
        
        return path.cgPath
    }
    
    // MARK: - Forward animations
    
    private let moveToggleRightAnimationKey = "MoveToggleRight"
    private let convertToggleToMinusAnimationKey = "ConvertToggleToMinus"
    private let convertMinusToCheckmarkAnimationKey = "ConvertMinusToCheckmark"
    
    func setOn(animated: Bool) {
        if isOn { return }
        isOn = true
        removeAllAnimations()
        if animated {
            moveToggleRight()
        } else {
            fillColor = nil
            strokeColor = toggleColor.cgColor
            let center = CGPoint(x: bounds.width - bounds.height / 2, y: bounds.height / 2)
            path = pathCheckmark(center: center)
        }
    }
    
    private func moveToggleRight() {
        path = pathToggle(center: CGPoint(x: bounds.width - bounds.height / 2, y: bounds.height / 2))
        
        let moveAnimation = CABasicAnimation(keyPath: "path")
        moveAnimation.fromValue = pathToggle(center: CGPoint(x: bounds.height / 2, y: bounds.height / 2))
        moveAnimation.toValue = pathToggle(center: CGPoint(x: bounds.width - bounds.height / 2, y: bounds.height / 2))
        moveAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        moveAnimation.duration = activateAnimationDuration
        moveAnimation.fillMode = kCAFillModeForwards
        moveAnimation.isRemovedOnCompletion = false
        moveAnimation.delegate = self
        add(moveAnimation, forKey: moveToggleRightAnimationKey)
    }
    
    private func convertToggleToMinus() {
        let center = CGPoint(x: bounds.width - bounds.height / 2, y: bounds.height / 2)
        path = pathMinus(center: center)
        
        let convertAnimation = CABasicAnimation(keyPath: "path")
        convertAnimation.fromValue = pathToggle(center: center)
        convertAnimation.toValue = pathMinus(center: center)
        convertAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        convertAnimation.duration = activateAnimationDuration * 0.7
        convertAnimation.fillMode = kCAFillModeForwards
        convertAnimation.isRemovedOnCompletion = false
        convertAnimation.delegate = self
        add(convertAnimation, forKey: convertToggleToMinusAnimationKey)
    }
    
    private func convertMinusToCheckmark() {
        let center = CGPoint(x: bounds.width - bounds.height / 2, y: bounds.height / 2)
        path = pathCheckmark(center: center)
        
        let convertAnimation = CABasicAnimation(keyPath: "path")
        convertAnimation.fromValue = pathSeparatedMinus(center: center)
        convertAnimation.toValue = pathCheckmark(center: center)
        convertAnimation.duration = activateAnimationDuration * 0.7
        convertAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        convertAnimation.fillMode = kCAFillModeForwards
        convertAnimation.isRemovedOnCompletion = false
        convertAnimation.delegate = self
        add(convertAnimation, forKey: convertMinusToCheckmarkAnimationKey)
    }
    
    // MARK: - Reverse animations
    
    private let convertCheckmarkToMinusAnimationKey = "ConvertCheckmarkToMinus"
    private let convertMinusToToggleAnimationKey = "ConvertMinusToToggle"
    private let moveToggleLeftAnimationKey = "MoveToggleLeft"
    
    func setOff(animated: Bool) {
        if !isOn { return }
        isOn = false
        removeAllAnimations()
        if animated {
            convertCheckmarkToMinus()
        } else {
            fillColor = toggleColor.cgColor
            strokeColor = nil
            let center = CGPoint(x: bounds.height / 2, y: bounds.height / 2)
            path = pathToggle(center: center)
        }
    }
    
    private func convertCheckmarkToMinus() {
        let center = CGPoint(x: bounds.width - bounds.height / 2, y: bounds.height / 2)
        path = pathSeparatedMinus(center: center)
        
        let convertAnimation = CABasicAnimation(keyPath: "path")
        convertAnimation.fromValue = pathCheckmark(center: center)
        convertAnimation.toValue = pathSeparatedMinus(center: center)
        convertAnimation.duration = deactivateAnimationDuration * 0.3
        convertAnimation.fillMode = kCAFillModeForwards
        convertAnimation.isRemovedOnCompletion = false
        convertAnimation.delegate = self
        add(convertAnimation, forKey: convertCheckmarkToMinusAnimationKey)
    }
    
    private func convertMinusToToggle() {
        let center = CGPoint(x: bounds.width - bounds.height / 2, y: bounds.height / 2)
        path = pathToggle(center: center)
        
        let convertAnimation = CABasicAnimation(keyPath: "path")
        convertAnimation.fromValue = pathMinus(center: center)
        convertAnimation.toValue = pathToggle(center: center)
        convertAnimation.duration = deactivateAnimationDuration * 0.2
        convertAnimation.fillMode = kCAFillModeForwards
        convertAnimation.isRemovedOnCompletion = false
        convertAnimation.delegate = self
        add(convertAnimation, forKey: convertMinusToToggleAnimationKey)
    }
    
    private func moveToggleLeft() {
        path = pathToggle(center: CGPoint(x: bounds.height / 2, y: bounds.height / 2))
        
        let moveAnimation = CABasicAnimation(keyPath: "path")
        moveAnimation.fromValue = pathToggle(center: CGPoint(x: bounds.width - bounds.height / 2, y: bounds.height / 2))
        moveAnimation.toValue = pathToggle(center: CGPoint(x: bounds.height / 2, y: bounds.height / 2))
        moveAnimation.duration = deactivateAnimationDuration * 0.5
        moveAnimation.fillMode = kCAFillModeForwards
        moveAnimation.isRemovedOnCompletion = false
        moveAnimation.delegate = self
        add(moveAnimation, forKey: moveToggleLeftAnimationKey)
    }
    
    // MARK: - CAAnimationDelegate methods
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        // Forward animations
        if anim == animation(forKey: moveToggleRightAnimationKey) {
            removeAnimation(forKey: moveToggleRightAnimationKey)
            convertToggleToMinus()
            
        } else if anim == animation(forKey: convertToggleToMinusAnimationKey) {
            removeAnimation(forKey: convertToggleToMinusAnimationKey)
            fillColor = nil
            strokeColor = toggleColor.cgColor
            convertMinusToCheckmark()
            
        } else if anim == animation(forKey: convertMinusToCheckmarkAnimationKey) {
            removeAnimation(forKey: convertMinusToCheckmarkAnimationKey)
        }
            // Reverse animations
        else if anim == animation(forKey: convertCheckmarkToMinusAnimationKey) {
            removeAnimation(forKey: convertCheckmarkToMinusAnimationKey)
            convertMinusToToggle()
            fillColor = toggleColor.cgColor
            strokeColor = nil
            
        } else if anim == animation(forKey: convertMinusToToggleAnimationKey) {
            removeAnimation(forKey: convertMinusToToggleAnimationKey)
            moveToggleLeft()
            
        } else if anim == animation(forKey: moveToggleLeftAnimationKey) {
            removeAnimation(forKey: moveToggleLeftAnimationKey)
            
        }
    }
}

class ContainerLayer: CAShapeLayer, CAAnimationDelegate {
    
    private(set) var isOn = false
    
    override var frame: CGRect {
        didSet {
            path = isOn ? pathCollapsed() : pathExtended()
        }
    }
    
    var onColor = UIColor.blue {
        didSet {
            if isOn {
                fillColor = onColor.cgColor
            }
        }
    }
    var offColor = UIColor.lightGray {
        didSet {
            if !isOn {
                fillColor = offColor.cgColor
            }
        }
    }
    
    var activateAnimationDuration: CFTimeInterval = 0.3
    var deactivateAnimationDuration: CFTimeInterval = 0.3
    
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    override init() {
        super.init()
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        fillColor = offColor.cgColor
        path = pathExtended()
    }
    
    func setIsOn(_ isOn: Bool, animated: Bool) {
        if isOn == self.isOn { return }
        removeAllAnimations()
        if animated {
            isOn ? collapse() : extend()
        } else {
            if isOn {
                path = pathCollapsed()
                fillColor = onColor.cgColor
            } else {
                path = pathExtended()
                fillColor = offColor.cgColor
            }
        }
        self.isOn = isOn
    }
    
    // MARK: Paths for different states
    
    private func pathExtended() -> CGPath {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: bounds.height / 2, y: bounds.height))
        path.addArc(withCenter: CGPoint(x: bounds.width - bounds.height / 2, y: bounds.height / 2), radius: bounds.height / 2, startAngle: CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: false)
        path.addArc(withCenter: CGPoint(x: bounds.height / 2, y: bounds.height / 2), radius: bounds.height / 2, startAngle: 3 * CGFloat.pi / 2, endAngle: CGFloat.pi / 2, clockwise: false)
        path.close()
        
        return path.cgPath
    }
    
    private func pathCollapsed() -> CGPath {
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: bounds.width - bounds.height, y: bounds.height))
        path.addArc(withCenter: CGPoint(x: bounds.width - bounds.height / 2, y: bounds.height / 2), radius: bounds.height / 2, startAngle: CGFloat.pi / 2, endAngle: 3 * CGFloat.pi / 2, clockwise: false)
        path.addArc(withCenter: CGPoint(x: bounds.width - bounds.height / 2, y: bounds.height / 2), radius: bounds.height / 2, startAngle: 3 * CGFloat.pi / 2, endAngle: CGFloat.pi / 2, clockwise: false)
        path.close()
        
        return path.cgPath
    }
    
    // MARK: - Forward animations
    
    private let collapseAnimationKey = "PathCollapse"
    private let setEnabledColorAnimationKey = "SetEnabledColor"
    
    private func collapse() {
        path = pathCollapsed()
        let collapseAnimation = CABasicAnimation(keyPath: "path")
        collapseAnimation.fromValue = pathExtended
        collapseAnimation.toValue = pathCollapsed
        collapseAnimation.duration = activateAnimationDuration
        collapseAnimation.fillMode = kCAFillModeForwards
        collapseAnimation.isRemovedOnCompletion = false
        collapseAnimation.delegate = self
        collapseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        add(collapseAnimation, forKey: collapseAnimationKey)
        
        fillColor = onColor.cgColor
        let colorAnimation = CABasicAnimation(keyPath: "fillColor")
        colorAnimation.fromValue = offColor.cgColor
        colorAnimation.toValue = onColor.cgColor
        colorAnimation.duration = activateAnimationDuration
        colorAnimation.fillMode = kCAFillModeForwards
        colorAnimation.isRemovedOnCompletion = false
        colorAnimation.delegate = self
        add(colorAnimation, forKey: setEnabledColorAnimationKey)
    }
    
    // MARK: - Reverse animations
    
    private let extendAnimationKey = "PathExtend"
    private let setDisabledColorAnimationKey = "SetDisabledColor"
    
    private func extend() {
        path = pathExtended()
        let collapseAnimation = CABasicAnimation(keyPath: "path")
        collapseAnimation.fromValue = pathCollapsed()
        collapseAnimation.toValue = pathExtended()
        collapseAnimation.duration = deactivateAnimationDuration
        collapseAnimation.fillMode = kCAFillModeForwards
        collapseAnimation.isRemovedOnCompletion = false
        collapseAnimation.delegate = self
        add(collapseAnimation, forKey: extendAnimationKey)
        
        fillColor = offColor.cgColor
        let colorAnimation = CABasicAnimation(keyPath: "fillColor")
        colorAnimation.fromValue = onColor.cgColor
        colorAnimation.toValue = offColor.cgColor
        colorAnimation.duration = deactivateAnimationDuration
        colorAnimation.fillMode = kCAFillModeForwards
        colorAnimation.isRemovedOnCompletion = false
        colorAnimation.delegate = self
        add(colorAnimation, forKey: setDisabledColorAnimationKey)
    }
    
    // MARK: - CAAnimationDelegate methods
    
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if anim == animation(forKey: collapseAnimationKey) {
            removeAnimation(forKey: collapseAnimationKey)
        }
        if anim == animation(forKey: setEnabledColorAnimationKey) {
            removeAnimation(forKey: setEnabledColorAnimationKey)
        }
        // Revers animations
        if anim == animation(forKey: extendAnimationKey) {
            removeAnimation(forKey: extendAnimationKey)
        }
        if anim == animation(forKey: setDisabledColorAnimationKey) {
            removeAnimation(forKey: setDisabledColorAnimationKey)
        }
    }
}

/// A control that offers a binary choice, such as On/Off.
/// You can customize the appearance of the switch by changing the color of container, toggle.

public class ActivationToggle: UIControl {
    
    private let container = ContainerLayer()
    private let toggle = ToggleLayer()
    
    private static let DefaultAnimationDuration: TimeInterval = 0.2
    private static let DefaultContainerOnColor = UIColor(red: 76.0 / 255.0, green: 216.0 / 255.0, blue: 100.0 / 255.0, alpha: 1.0)
    private static let DefaultContainerOffColor = UIColor(red: 229.0 / 255.0, green: 229.0 / 255.0, blue: 229.0 / 255.0, alpha: 1.0)
    private static let DefaultToggleColor = UIColor.white
    
    public static let DefaultSize = CGSize(width: 50.0, height: 30.0)
    
    /// Toggle activation animation duaration.
    public var activateAnimationDuration: TimeInterval = ActivationToggle.DefaultAnimationDuration {
        didSet {
            container.activateAnimationDuration = activateAnimationDuration
            toggle.activateAnimationDuration = activateAnimationDuration
        }
    }
    
    /// Toggle deactivation animation duaration.
    public var deactivateAnimationDuration: TimeInterval = ActivationToggle.DefaultAnimationDuration {
        didSet {
            container.deactivateAnimationDuration = deactivateAnimationDuration
            toggle.deactivateAnimationDuration = deactivateAnimationDuration
        }
    }
    
    /// Toggle state.
    public private(set) var isOn: Bool = false
    
    public func setIsOn(_ isOn: Bool, animated: Bool) {
        if isOn == self.isOn { return }
        container.setIsOn(isOn, animated: animated)
        toggle.setIsOn(isOn, animated: animated)
        self.isOn = isOn
    }
    
    /// Allows set element to Off state after On state is activated.
    public var isDeactivatable: Bool = true
    
    /// Toggle container ON color.
    public var onColor = ActivationToggle.DefaultContainerOnColor {
        didSet {
            container.onColor = onColor
        }
    }
    
    /// Toggle container OFF color.
    public var offColor = ActivationToggle.DefaultContainerOffColor {
        didSet {
            container.offColor = offColor
        }
    }
    
    /// Toggle color.
    public var toggleColor = ActivationToggle.DefaultToggleColor {
        didSet {
            toggle.toggleColor = toggleColor
        }
    }
    
    /// Enable/disable toggle shadow.
    public var isShowToggleShadow = true {
        didSet {
            toggle.isShowSadow = isShowToggleShadow
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0,
                                y: 0,
                                width: ActivationToggle.DefaultSize.width,
                                height: ActivationToggle.DefaultSize.height))
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        container.frame = bounds
        toggle.frame = bounds
        addContainer()
        
        backgroundColor = nil
        
        onColor = ActivationToggle.DefaultContainerOnColor
        offColor = ActivationToggle.DefaultContainerOffColor
        toggleColor = ActivationToggle.DefaultToggleColor
        
        activateAnimationDuration = ActivationToggle.DefaultAnimationDuration
        deactivateAnimationDuration = ActivationToggle.DefaultAnimationDuration
        
        toggle.isShowSadow = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        container.frame = bounds
        toggle.frame = bounds
    }
    
    @objc
    private func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        if !isDeactivatable && isOn { return }
        setIsOn(!isOn, animated: true)
        sendActions(for: .valueChanged)
    }
    
    private func addContainer() {
        layer.addSublayer(container)
        layer.addSublayer(toggle)
    }
}
