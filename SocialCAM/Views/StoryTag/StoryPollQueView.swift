//
//  StoryPollQueView.swift
//  ProManager
//
//  Created by Jasmin Patel on 27/12/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import Foundation
import UIKit

class FillView: UIView {
    
    private let fillView = UIView(frame: CGRect.zero)
    
    private var coeff: CGFloat = 0 {
        didSet {
            // Make sure the fillView frame is updated everytime the coeff changes
            updateFillViewFrame()
        }
    }
    
    var fillColor: UIColor = ApplicationSettings.appLightGrayColor {
        didSet {
            fillView.backgroundColor = fillColor
        }
    }
    
    var roundCorners: UIRectCorner = .allCorners
    
    var radius: CGFloat = 0
    
    // Only needed if view isn't created in xib or storyboard
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Only needed if view isn't created in xib or storyboard
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    override func awakeFromNib() {
        setupView()
    }
    
    private func setupView() {
        // Setup the layer
        layer.masksToBounds = true
        
        fillView.backgroundColor = fillColor
        // Setup filledView backgroundColor and add it as a subview
        addSubview(fillView)
        
        // Update fillView frame in case coeff already has a value
        updateFillViewFrame()
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        updateFillViewFrame()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.roundCorners(roundCorners, radius: radius)
    }
    
    func updateFillViewFrame() {
        fillView.frame = CGRect.init(x: bounds.width/2 * (1-coeff),
                                     y: 0,
                                     width: bounds.width*coeff,
                                     height: bounds.height)
    }
    
    // Setter function to set the coeff animated. If setting it not animated isn't necessary at all, consider removing this func and animate updateFillViewFrame() in coeff didSet
    func setCoeff(coeff: CGFloat, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.5, animations: {
                self.coeff = coeff
            })
        } else {
            self.coeff = coeff
        }
    }
    
}

class StoryPollQueView: BaseQuestionTagView {
    
    lazy var textView: StoryQueTextView = {
        let txtView = StoryQueTextView(frame: CGRect.zero)
        txtView.font = UIFont.systemFont(ofSize: 26)
        txtView.textColor = ApplicationSettings.appWhiteColor
        txtView.isScrollEnabled = false
        txtView.textAlignment = .center
        txtView.backgroundColor = ApplicationSettings.appClearColor
        txtView.textContainer.maximumNumberOfLines = 10
        return txtView
    }()
    
    lazy var firstOptionTextView: StoryQueTextView = {
        let txtView = StoryQueTextView(frame: CGRect.zero)
        txtView.font = UIFont.systemFont(ofSize: 44)
        txtView.placeHolder = "YES"
        txtView.isScrollEnabled = false
        txtView.textAlignment = .center
        txtView.backgroundColor = ApplicationSettings.appClearColor
        txtView.isResizableFont = true
        txtView.textContainer.maximumNumberOfLines = 2
        txtView.clipsToBounds = false
        txtView.backgroundColor = ApplicationSettings.appClearColor
        return txtView
    }()
    
    lazy var secondOptionTextView: StoryQueTextView = {
        let txtView = StoryQueTextView(frame: CGRect.zero)
        txtView.font = UIFont.systemFont(ofSize: 44)
        txtView.placeHolder = "NO"
        txtView.isScrollEnabled = false
        txtView.textAlignment = .center
        txtView.backgroundColor = ApplicationSettings.appClearColor
        txtView.isResizableFont = true
        txtView.textContainer.maximumNumberOfLines = 2
        return txtView
    }()
    
    lazy var separator: UIView = {
        let sView = UIView()
        sView.backgroundColor = ApplicationSettings.appLightGrayColor
        
        return sView
    }()
    
    lazy var baseOptionView: UIView = {
        let view = UIView()
        view.backgroundColor = ApplicationSettings.appWhiteColor
        view.layer.cornerRadius = 7.0
        return view
    }()
    
    lazy var firstAnswerLabel: UILabel = {
        let sView = self.labelFor(text: "", textAlignment: .center, fontSize: 25, textColor: ApplicationSettings.appBlackColor)
        return sView
    }()
    
    lazy var secondAnswerLabel: UILabel = {
        let sView = self.labelFor(text: "", textAlignment: .center, fontSize: 25, textColor: ApplicationSettings.appBlackColor)
        return sView
    }()
    
    lazy var firstOptionView: FillView = {
        let view = FillView()
        view.fillColor = ApplicationSettings.appLightGrayColor
        view.roundCorners = [.topLeft, .bottomLeft]
        view.radius = 7
        return view
    }()
    
    lazy var secondOptionView: FillView = {
        let view = FillView()
        view.fillColor = ApplicationSettings.appLightGrayColor
        view.roundCorners = [.topRight, .bottomRight]
        view.radius = 7
        return view
    }()
    
    lazy var firstOptionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = ApplicationSettings.appClearColor
        button.tag = 1
        button.addTarget(self, action: #selector(tapOption(_:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    lazy var secondOptionButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = ApplicationSettings.appClearColor
        button.tag = 2
        button.addTarget(self, action: #selector(tapOption(_:)), for: UIControl.Event.touchUpInside)
        return button
    }()
    
    var questionText: String {
        get { return textView.text }
        set {
            textView.setTextViewWith(newValue)
        }
    }
    
    var firstOptionText: String {
        get {
            if firstOptionTextView.text.isEmpty {
                return firstOptionTextView.placeHolder ?? ""
            }
            return firstOptionTextView.text
        }
        set {
            firstOptionTextView.setTextViewWith(newValue)
        }
    }
    
    var secondOptionText: String {
        get {
            if secondOptionTextView.text.isEmpty {
                return secondOptionTextView.placeHolder ?? ""
            }
            return secondOptionTextView.text
        }
        set {
            secondOptionTextView.setTextViewWith(newValue)
        }
    }
    
    var firstOptionWidthConstraint: NSLayoutConstraint?
    
    var startUpdateAnswer: (() -> Swift.Void)?
    
    var didUpdateAnswer: ((Int, StoryTags?, StoryPollQueView) -> Swift.Void)?
    
    var storyTag: StoryTags?
    
    var isAnswerView: Bool = false {
        didSet {
            self.tapEnable = !isAnswerView
            textView.isUserInteractionEnabled = !isAnswerView
        }
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
        
        self.addSubview(textView)
        self.addSubview(baseOptionView)
        
        baseOptionView.addSubview(firstOptionView)
        baseOptionView.addSubview(separator)
        baseOptionView.addSubview(secondOptionView)
        
        firstOptionView.addSubview(firstOptionTextView)
        firstOptionView.addSubview(firstAnswerLabel)
        firstOptionView.addSubview(firstOptionButton)
        
        secondOptionView.addSubview(secondOptionTextView)
        secondOptionView.addSubview(secondAnswerLabel)
        secondOptionView.addSubview(secondOptionButton)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        textView.topAnchor.constraint(equalTo: topAnchor, constant: 0).isActive = true
        textView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        
        baseOptionView.translatesAutoresizingMaskIntoConstraints = false
        baseOptionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0).isActive = true
        baseOptionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0).isActive = true
        baseOptionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0).isActive = true
        baseOptionView.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 10).isActive = true
        baseOptionView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        firstOptionView.translatesAutoresizingMaskIntoConstraints = false
        firstOptionView.widthAnchor.constraint(equalTo: baseOptionView.widthAnchor, multiplier: 0.5).isActive = true
        firstOptionView.leadingAnchor.constraint(equalTo: baseOptionView.leadingAnchor, constant: 0).isActive = true
        firstOptionView.bottomAnchor.constraint(equalTo: baseOptionView.bottomAnchor, constant: 0).isActive = true
        firstOptionView.topAnchor.constraint(equalTo: baseOptionView.topAnchor, constant: 0).isActive = true
        
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.widthAnchor.constraint(equalToConstant: 1).isActive = true
        separator.leadingAnchor.constraint(equalTo: firstOptionView.trailingAnchor, constant: 0).isActive = true
        separator.bottomAnchor.constraint(equalTo: baseOptionView.bottomAnchor, constant: 0).isActive = true
        separator.topAnchor.constraint(equalTo: baseOptionView.topAnchor, constant: 0).isActive = true
        
        secondOptionView.translatesAutoresizingMaskIntoConstraints = false
        secondOptionView.trailingAnchor.constraint(equalTo: baseOptionView.trailingAnchor, constant: 0).isActive = true
        secondOptionView.leadingAnchor.constraint(equalTo: separator.trailingAnchor, constant: 0).isActive = true
        secondOptionView.bottomAnchor.constraint(equalTo: baseOptionView.bottomAnchor, constant: 0).isActive = true
        secondOptionView.topAnchor.constraint(equalTo: baseOptionView.topAnchor, constant: 0).isActive = true
        
        firstOptionTextView.translatesAutoresizingMaskIntoConstraints = false
        firstOptionTextView.leadingAnchor.constraint(equalTo: firstOptionView.leadingAnchor, constant: 0).isActive = true
        firstOptionTextView.topAnchor.constraint(equalTo: firstOptionView.topAnchor, constant: 0).isActive = true
        firstOptionTextView.trailingAnchor.constraint(equalTo: firstOptionView.trailingAnchor, constant: 0).isActive = true
        firstOptionTextView.bottomAnchor.constraint(equalTo: firstOptionView.bottomAnchor, constant: 0).isActive = true
        
        firstAnswerLabel.translatesAutoresizingMaskIntoConstraints = false
        firstAnswerLabel.leadingAnchor.constraint(equalTo: firstOptionView.leadingAnchor, constant: 0).isActive = true
        firstAnswerLabel.trailingAnchor.constraint(equalTo: firstOptionView.trailingAnchor, constant: 0).isActive = true
        firstAnswerLabel.bottomAnchor.constraint(equalTo: firstOptionView.bottomAnchor, constant: 0).isActive = true
        
        firstOptionButton.translatesAutoresizingMaskIntoConstraints = false
        firstOptionButton.leadingAnchor.constraint(equalTo: firstOptionView.leadingAnchor, constant: 0).isActive = true
        firstOptionButton.topAnchor.constraint(equalTo: firstOptionView.topAnchor, constant: 0).isActive = true
        firstOptionButton.trailingAnchor.constraint(equalTo: firstOptionView.trailingAnchor, constant: 0).isActive = true
        firstOptionButton.bottomAnchor.constraint(equalTo: firstOptionView.bottomAnchor, constant: 0).isActive = true
        
        secondOptionTextView.translatesAutoresizingMaskIntoConstraints = false
        secondOptionTextView.leadingAnchor.constraint(equalTo: secondOptionView.leadingAnchor, constant: 0).isActive = true
        secondOptionTextView.topAnchor.constraint(equalTo: secondOptionView.topAnchor, constant: 0).isActive = true
        secondOptionTextView.trailingAnchor.constraint(equalTo: secondOptionView.trailingAnchor, constant: 0).isActive = true
        secondOptionTextView.bottomAnchor.constraint(equalTo: secondOptionView.bottomAnchor, constant: 0).isActive = true
        
        secondAnswerLabel.translatesAutoresizingMaskIntoConstraints = false
        secondAnswerLabel.leadingAnchor.constraint(equalTo: secondOptionView.leadingAnchor, constant: 0).isActive = true
        secondAnswerLabel.trailingAnchor.constraint(equalTo: secondOptionView.trailingAnchor, constant: 0).isActive = true
        secondAnswerLabel.bottomAnchor.constraint(equalTo: secondOptionView.bottomAnchor, constant: 0).isActive = true
        
        secondOptionButton.translatesAutoresizingMaskIntoConstraints = false
        secondOptionButton.leadingAnchor.constraint(equalTo: secondOptionView.leadingAnchor, constant: 0).isActive = true
        secondOptionButton.topAnchor.constraint(equalTo: secondOptionView.topAnchor, constant: 0).isActive = true
        secondOptionButton.trailingAnchor.constraint(equalTo: secondOptionView.trailingAnchor, constant: 0).isActive = true
        secondOptionButton.bottomAnchor.constraint(equalTo: secondOptionView.bottomAnchor, constant: 0).isActive = true
        
        self.layoutIfNeeded()
        self.firstAnswerLabel.alpha = 0
        self.secondAnswerLabel.alpha = 0
        self.firstOptionButton.isHidden = true
        self.secondOptionButton.isHidden = true
        startEdit()
    }
    
    func showAnswerButtons() {
        self.firstOptionButton.isHidden = false
        self.secondOptionButton.isHidden = false
    }
    
    @objc func tapOption(_ sender: UIButton) {
        self.startUpdateAnswer?()
        updateOptionAnswer(optionNumber: sender.tag)
        self.didUpdateAnswer?(sender.tag, storyTag, self)
    }
    
    func updateOptionAnswer(optionNumber: Int) {
        self.firstOptionView.layoutIfNeeded()
        self.secondOptionView.layoutIfNeeded()
        DispatchQueue.main.async {
            switch optionNumber {
            case 1:
                self.firstOptionView.setCoeff(coeff: 1.0, animated: true)
            case 2:
                self.secondOptionView.setCoeff(coeff: 1.0, animated: true)
            default:
                break
            }
        }
    }
    
    func updateOptionsColors() {
        firstOptionTextView.textColor = UIColor
            .gradientColorFrom(colors: [R.color.quetag_brightLightGreen() ?? UIColor.red,
                                        R.color.quetag_darkPastelGreen() ?? UIColor.green],
                               and: firstOptionTextView.bounds.size)
        secondOptionTextView.textColor = UIColor
            .gradientColorFrom(colors: [R.color.quetag_lightishPurple() ?? UIColor.blue,
                                        R.color.quetag_pinkish() ?? UIColor.green],
                               and: secondOptionTextView.bounds.size)
        firstOptionTextView.placeholderColor = firstOptionTextView.textColor?.withAlphaComponent(0.5) ?? ApplicationSettings.appLightGrayColor
        secondOptionTextView.placeholderColor = secondOptionTextView.textColor?.withAlphaComponent(0.5) ?? ApplicationSettings.appLightGrayColor
        textView.placeHolder = R.string.localizable.askMeAQuestion()
    }
    
    func updateValues() {
        if questionText.isEmpty {
            textView.placeHolder = nil
        }
        if firstOptionTextView.text.isEmpty {
            firstOptionTextView.placeholderColor = firstOptionTextView.textColor ?? ApplicationSettings.appBlackColor
        }
        if secondOptionTextView.text.isEmpty {
            secondOptionTextView.placeholderColor = secondOptionTextView.textColor ?? ApplicationSettings.appBlackColor
        }
    }
    
    func updateAnswerValues(firstOptionAnswer: Int, secondOptionAnswer: Int) {
        self.firstAnswerLabel.text = "\(firstOptionAnswer)%"
        self.secondAnswerLabel.text = "\(secondOptionAnswer)%"
        UIView.animate(withDuration: 0.5) {
            self.firstAnswerLabel.alpha = 1.0
            self.secondAnswerLabel.alpha = 1.0
            self.secondOptionTextView.layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.8)
            self.secondOptionTextView.transform = CGAffineTransform.identity.scaledBy(x: 0.65, y: 0.65)
            self.firstOptionTextView.layer.anchorPoint = CGPoint.init(x: 0.5, y: 0.8)
            self.firstOptionTextView.transform = CGAffineTransform.identity.scaledBy(x: 0.65, y: 0.65)
        }
    }
    
    func completeEdit() {
        self.tapEnable = true
        textView.resignFirstResponder()
        firstOptionTextView.resignFirstResponder()
        secondOptionTextView.resignFirstResponder()
        self.updateValues()
    }
    
    func startEdit() {
        self.tapEnable = false
        textView.becomeFirstResponder()
    }
}
