//
//  CropViewController.swift
//  Mantis
//
//  Created by Echo on 10/30/18.
//  Copyright © 2018 Echo. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to
//  deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
//  IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit
import AVFoundation
import ColorSlider
public protocol CropViewControllerDelegate: class {
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, cropped: UIImage,croppedBGcolor:UIColor)
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, croppedURL: URL,croppedBGcolor:UIColor)
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, updatedVideoSegments: [SegmentVideos],croppedBGcolor:UIColor)
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage)
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage)
    func cropViewControllerWillDismiss(_ cropViewController: CropViewController)
}

public extension CropViewControllerDelegate {
    func cropViewControllerWillDismiss(_ cropViewController: CropViewController) {}
    func cropViewControllerDidFailToCrop(_ cropViewController: CropViewController, original: UIImage) {}
    func cropViewControllerDidCancel(_ cropViewController: CropViewController, original: UIImage) {}
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, croppedURL: URL,croppedBGcolor:UIColor) {}
    func cropViewControllerDidCrop(_ cropViewController: CropViewController, updatedVideoSegments: [SegmentVideos],croppedBGcolor:UIColor) {}
}

public enum CropViewControllerMode {
    case normal
    case customizable    
}

class VideoTimeSliderContainer: UIView {
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    private lazy var remainTimeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    private lazy var slider: UISlider = {
        let slider = UISlider()
        slider.minimumTrackTintColor = .white
        slider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)
        return slider
    }()
    
    public var timeChanged: (_ time: CMTime) -> Void = { _ in }

    public var minimumValue: Float = 0.0 {
        didSet {
            slider.minimumValue = minimumValue
            currentTimeLabel.text = hmsString(from: minimumValue)
        }
    }
    
    public var maximumValue: Float = 1.0 {
        didSet {
            slider.maximumValue = maximumValue
            remainTimeLabel.text = "-\(hmsString(from: maximumValue))"
        }
    }
    
    public var value: Float = 0.5 {
        didSet {
            slider.value = value
            currentTimeLabel.text = hmsString(from: value)
            remainTimeLabel.text = "-\(hmsString(from: maximumValue - value))"
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(currentTimeLabel)
        addSubview(remainTimeLabel)
        addSubview(slider)
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        remainTimeLabel.translatesAutoresizingMaskIntoConstraints = false

        currentTimeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        currentTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        
        remainTimeLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8).isActive = true
        remainTimeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true

        slider.topAnchor.constraint(equalTo: currentTimeLabel.bottomAnchor, constant: 10).isActive = true
        slider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8).isActive = true
        slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20).isActive = true
        slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20).isActive = true
    }
    
    private func hmsString(from seconds: Float) -> String {
        let roundedSeconds = Int(seconds.rounded())
        let hours = (roundedSeconds / 3600)
        let minutes = (roundedSeconds % 3600) / 60
        let seconds = (roundedSeconds % 3600) % 60
        func timeString(_ time: Int) -> String {
            return time < 10 ? "0\(time)" : "\(time)"
        }
        if hours > 0 {
            return "\(timeString(hours)):\(timeString(minutes)):\(timeString(seconds))"
        }
        return "\(timeString(minutes)):\(timeString(seconds))"
    }
    
    @objc func sliderValueChanged(_ sender: UISlider) {
        self.value = sender.value
        timeChanged(CMTime(value: CMTimeValue(self.value*10000), timescale: 10000))
    }
    
}
public class CropViewController: UIViewController {
    /// When a CropViewController is used in a storyboard,
    /// passing an image to it is needed after the CropViewController is created.
    public var image: UIImage! {
        didSet {
            cropView.image = image
        }
    }
    
    public var avAsset: AVAsset? {
        didSet {
            cropView.avAsset = avAsset
        }
    }
    public var videoSegments: [SegmentVideos] = []
    
    public var currentIndex: Int = 0

    public weak var delegate: CropViewControllerDelegate?
    public var mode: CropViewControllerMode = .normal
    public var config = MantisConfig()
    
    private var orientation: UIInterfaceOrientation = .unknown
    private lazy var cropView = CropView(image: image, viewModel: CropViewModel())
    private lazy var cropToolbar = CropToolbar(frame: CGRect.zero)
    private lazy var sliderContainer = VideoTimeSliderContainer(frame: .zero)
    private var ratioPresenter: RatioPresenter?
    private var stackView: UIStackView?
    private var initialLayout = false
    private var isFlipped = false
    private var colorSlider: ColorSlider!
    private var croppedBGcolor: UIColor = .black
    var blurButton: UIButton!
    var blurImageview: UIImageView!
    deinit {
        print("Deinit \(self.description)")
    }
    
    init(image: UIImage, config: MantisConfig = MantisConfig(), mode: CropViewControllerMode = .normal) {
        self.image = image
        self.config = config
        self.mode = mode
        super.init(nibName: nil, bundle: nil)
        self.sliderContainer.isHidden = true
    }
    
    init(avAsset: AVAsset, config: MantisConfig = MantisConfig(), mode: CropViewControllerMode = .normal) {
        self.avAsset = avAsset
        self.image = avAsset.thumbnailImage()
        self.config = config
        self.mode = mode
        
        super.init(nibName: nil, bundle: nil)
        cropView.avAsset = self.avAsset
        sliderContainer.minimumValue = 0
        sliderContainer.maximumValue = Float(avAsset.duration.seconds)
        sliderContainer.timeChanged = { [weak self] time in
            self?.image = self?.avAsset?.thumbnailImage(at: time)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    fileprivate func setPresetFixedRatio() {
        let fixedRatioManager = getFixedRatioManager()
        
        var ratioItem: RatioItemType
        if fixedRatioManager.ratios.isEmpty {
            ratioItem = fixedRatioManager.getOriginalRatioItem()
        } else {
            ratioItem = fixedRatioManager.ratios[0]
        }

        let ratioValue = (fixedRatioManager.type == .horizontal) ? ratioItem.ratioH : ratioItem.ratioV
        setFixedRatio(ratioValue)
    }
    
    fileprivate func createCropToolbar() {
        cropToolbar.backgroundColor = .clear
        
        cropToolbar.selectedCancel = {[weak self] in self?.handleCancel() }
        cropToolbar.selectedMirror = {[weak self] in self?.handleMirror() }
        cropToolbar.selectedRotate = {[weak self] in self?.handleRotate() }
        cropToolbar.selectedReset = {[weak self] in self?.handleReset() }
        cropToolbar.selectedSetRatio = {[weak self] in self?.handleSetRatio() }
        cropToolbar.selectedCrop = {[weak self] in self?.handleCrop() }
        
        let showRatioButton: Bool
        
        if config.alwaysUsingOnePresetFixedRatio {
            showRatioButton = false
            setPresetFixedRatio()
        } else {
            showRatioButton = true
        }
        
        if mode == .normal {
            cropToolbar.createToolbarUI(mode: .normal, includeSetRatioButton: showRatioButton)
        } else {
            cropToolbar.createToolbarUI(mode: .simple, includeSetRatioButton: showRatioButton)
        }
    }
    
    fileprivate func createToolbarUI() {
        if mode == .normal {
            cropToolbar.createToolbarUI()
        } else {
            cropToolbar.createToolbarUI(mode: .simple)
        }
    }
    
    fileprivate func getFixedRatioManager() -> FixedRatioManager {
        let type: RatioType = cropView.getRatioType(byImageIsOriginalisHorizontal: cropView.image.isHorizontal())
        
        let ratio = cropView.getImageRatioH()
        
        return FixedRatioManager(type: type,
                                 originalRatioH: ratio,
                                 ratioOptions: config.ratioOptions,
                                 customRatios: config.getCustomRatioItems())
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        createCropToolbar()
        createCropView()
        initLayout()
        updateLayout()
        setupColorSlider()
        createBlurButton()
        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIApplication.didChangeStatusBarOrientationNotification, object: nil)
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if initialLayout == false {
            initialLayout = true
            view.layoutIfNeeded()
            cropView.adaptForCropBox()
        }
    }
    
    public override var prefersStatusBarHidden: Bool {
        return true
    }
    
    public override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
        return [.top, .bottom]
    }
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        cropView.prepareForDeviceRotation()
    }    
    func setupColorSlider() {
        colorSlider = ColorSlider(orientation: .horizontal, previewSide: .top)
        colorSlider.addTarget(self, action: #selector(colorSliderValueChanged(_:)), for: UIControl.Event.valueChanged)
        view.addSubview(colorSlider)
        let colorSliderHeight = CGFloat(175)
        colorSlider.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            colorSlider.centerXAnchor.constraint(equalTo:self.view.centerXAnchor, constant: 0),
            colorSlider.bottomAnchor.constraint(equalTo:self.view.bottomAnchor, constant: -120),
            colorSlider.widthAnchor.constraint(equalToConstant: colorSliderHeight),
            colorSlider.heightAnchor.constraint(equalToConstant: 15)
        ])
        if Defaults.shared.enableBlurVideoBackgroud{
            colorSlider.isHidden = true
        }else{
            colorSlider.isHidden = false
        }
       
    }
    @objc func colorSliderValueChanged(_ sender: ColorSlider) {
        
        self.cropView.cropMaskViewManager.setVisualEffectBGColor(color:sender.color,opacity:1.0)
        croppedBGcolor = sender.color
     //   self.cropView.cropMaskViewManager.hideBackground()
    }
    private func createBlurButton() {
       let blurText = R.string.localizable.blur()
       
        let blurButtonview = UIView()
        blurImageview = UIImageView()
        blurImageview.image = R.image.checkOff()
        blurButton = createOptionButton(withTitle: blurText, andAction: #selector(blur))
        blurButtonview.addSubview(blurButton)
        blurButtonview.addSubview(blurImageview)
        self.view.addSubview(blurButtonview)
        
        blurButtonview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurButtonview.leadingAnchor.constraint(equalTo:self.view.leadingAnchor, constant: 0),
            blurButtonview.centerYAnchor.constraint(equalTo:self.colorSlider.centerYAnchor, constant: 0),
            blurButtonview.widthAnchor.constraint(equalToConstant: 75),
            blurButtonview.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        blurButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurButton.leadingAnchor.constraint(equalTo:blurButtonview.leadingAnchor, constant: 0),
            blurButton.trailingAnchor.constraint(equalTo:blurButtonview.trailingAnchor, constant: 0),
            blurButton.topAnchor.constraint(equalTo:blurButtonview.topAnchor, constant:0),
            blurButton.bottomAnchor.constraint(equalTo:blurButtonview.bottomAnchor, constant: 0),
        ])
        
        blurImageview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurImageview.trailingAnchor.constraint(equalTo:blurButtonview.trailingAnchor, constant: -5),
            blurImageview.centerYAnchor.constraint(equalTo:blurButtonview.centerYAnchor, constant: 0),
            blurImageview.widthAnchor.constraint(equalToConstant: 14),
            blurImageview.heightAnchor.constraint(equalToConstant: 14)
        ])
        
        if Defaults.shared.enableBlurVideoBackgroud{
            self.colorSlider.isHidden = true
            self.blurImageview.image = R.image.checkOn()
        }else{
            self.colorSlider.isHidden = false
            self.blurImageview.image = R.image.checkOff()
        }
    }
    @objc private func blur(_ sender: UIButton){
        sender.isSelected = !sender.isSelected
        Defaults.shared.enableBlurVideoBackgroud = sender.isSelected
        if Defaults.shared.enableBlurVideoBackgroud{
            self.colorSlider.isHidden = true
            self.blurImageview.image = R.image.checkOn()
            self.cropView.cropMaskViewManager.setVisualEffectBGColor(color:.black,opacity:0.5)
        }else{
            self.colorSlider.isHidden = false
            self.blurImageview.image = R.image.checkOff()
            self.cropView.cropMaskViewManager.setVisualEffectBGColor(color:colorSlider.color,opacity:1.0)
        }
    }
    private func createOptionButton(withTitle title: String?, andAction action: Selector) -> UIButton {
        let buttonColor = UIColor.white
        let buttonFontSize: CGFloat = (UIDevice.current.userInterfaceIdiom == .pad) ? 20 : 14
        let buttonFont = UIFont.systemFont(ofSize: buttonFontSize)
        let button = UIButton(type: .system)
        button.tintColor = .clear
        button.titleLabel?.font = buttonFont
        if let title = title {
            button.setTitle(title, for: .normal)
            button.setTitleColor(buttonColor, for: .normal)
            button.setTitle(title, for: .selected)
            button.setTitleColor(buttonColor, for: .selected)
        }
        button.addTarget(self, action: action, for: .touchUpInside)
        button.contentEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        return button
    }
    @objc func rotated() {
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        
        guard statusBarOrientation != .unknown else { return }
        guard statusBarOrientation != orientation else { return }
        
        orientation = statusBarOrientation
        
        if UIDevice.current.userInterfaceIdiom == .phone
            && statusBarOrientation == .portraitUpsideDown {
            return
        }
        
        updateLayout()
        view.layoutIfNeeded()
        
        // When it is embedded in a container, the timing of viewDidLayoutSubviews
        // is different with the normal mode.
        // So delay the execution to make sure handleRotate runs after the final
        // viewDidLayoutSubviews
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.cropView.handleRotate()
        }
    }
    
    func setFixedRatio(_ ratio: Double) {
        cropToolbar.setRatioButton?.tintColor = nil
        cropView.aspectRatioLockEnabled = true
        cropView.viewModel.aspectRatio = CGFloat(ratio)
        UIView.animate(withDuration: 0.5) {
            self.cropView.setFixedRatioCropBox()
        }
    }
    
    private func createCropView() {
        cropView.delegate = self
        cropView.clipsToBounds = true
    }
    
    private func handleCancel() {
        delegate?.cropViewControllerWillDismiss(self)
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.cropViewControllerDidCancel(self, original: self.image)
        }
    }
    
    private func resetRatioButton() {
        cropView.aspectRatioLockEnabled = false
        cropToolbar.setRatioButton?.tintColor = .white
    }
    
    @objc private func handleSetRatio() {
        if cropView.aspectRatioLockEnabled {
            resetRatioButton()
            return
        }
        
        let fixedRatioManager = getFixedRatioManager()
        
        guard !fixedRatioManager.ratios.isEmpty else { return }
        
        if fixedRatioManager.ratios.count == 1 {
            let ratioItem = fixedRatioManager.ratios[0]
            let ratioValue = (fixedRatioManager.type == .horizontal) ? ratioItem.ratioH : ratioItem.ratioV
            setFixedRatio(ratioValue)
            return
        }
        
        ratioPresenter = RatioPresenter(type: fixedRatioManager.type, originalRatioH: fixedRatioManager.originalRatioH, ratios: fixedRatioManager.ratios)
        ratioPresenter?.didGetRatio = {[weak self] ratio in
            self?.setFixedRatio(ratio)
        }
        ratioPresenter?.present(by: self, in: cropToolbar.setRatioButton!)
    }
    
    private func handleReset() {
        resetRatioButton()
        cropView.reset(forceFixedRatio: config.alwaysUsingOnePresetFixedRatio)
    }
    
    private func handleRotate() {
        cropView.counterclockwiseRotate90()
    }
    
    private func handleMirror() {
        if let flippedImage = image.flippedImage(isHorizontal: true) {
            isFlipped = !isFlipped
            image = flippedImage
        }
    }
    
    private func handleCrop() {
        let isFlipped = (avAsset == nil) ? false : self.isFlipped
        cropView.crop(isFlipped: isFlipped) { [weak self] croppedObject in
            guard let `self` = self else {
                return
            }
            guard let croppedObject = croppedObject else {
                self.delegate?.cropViewControllerDidFailToCrop(self, original: self.cropView.image)
                return
            }
            self.delegate?.cropViewControllerWillDismiss(self)
            if let image = croppedObject as? UIImage {
                self.delegate?.cropViewControllerDidCrop(self, cropped: image,croppedBGcolor:self.croppedBGcolor)
            } else if let url = croppedObject as? URL {
                self.delegate?.cropViewControllerDidCrop(self, croppedURL: url,croppedBGcolor:self.croppedBGcolor)
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
}

// Auto layout
extension CropViewController {
    fileprivate func initLayout() {
        stackView = UIStackView()
        view.addSubview(stackView!)
        
        stackView?.translatesAutoresizingMaskIntoConstraints = false
        cropToolbar.translatesAutoresizingMaskIntoConstraints = false
        cropView.translatesAutoresizingMaskIntoConstraints = false
        sliderContainer.translatesAutoresizingMaskIntoConstraints = false
        
        stackView?.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        stackView?.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        stackView?.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        stackView?.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
    }
    
    fileprivate func setStackViewAxis() {
        if UIApplication.shared.statusBarOrientation.isPortrait {
            stackView?.axis = .vertical
        } else if UIApplication.shared.statusBarOrientation.isLandscape {
            stackView?.axis = .horizontal
        }
    }
    
    fileprivate func changeStackViewOrder() {
        stackView?.removeArrangedSubview(cropToolbar)
        stackView?.removeArrangedSubview(cropView)
        stackView?.removeArrangedSubview(sliderContainer)
        
        if UIApplication.shared.statusBarOrientation.isPortrait || UIApplication.shared.statusBarOrientation == .landscapeRight {
            stackView?.addArrangedSubview(cropToolbar)
            stackView?.addArrangedSubview(cropView)
            stackView?.addArrangedSubview(sliderContainer)
        } else if UIApplication.shared.statusBarOrientation == .landscapeLeft {
            stackView?.addArrangedSubview(cropView)
            stackView?.addArrangedSubview(cropToolbar)
            stackView?.addArrangedSubview(sliderContainer)
        }
    }
    
    fileprivate func updateLayout() {
        setStackViewAxis()
        cropToolbar.checkOrientation()
        changeStackViewOrder()
    }
}

extension CropViewController: CropViewDelegate {
    func cropViewDidBecomeResettable(_ cropView: CropView) {
        cropToolbar.resetButton?.isHidden = false
    }
    
    func cropViewDidBecomeNonResettable(_ cropView: CropView) {
        cropToolbar.resetButton?.isHidden = true
    }
}

extension AVAsset {
    
    func thumbnailImage(at time: CMTime = CMTime(value: 0, timescale: 1)) -> UIImage? {
        do {
            let imgGenerator = AVAssetImageGenerator(asset: self)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            return thumbnail
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
    
}
