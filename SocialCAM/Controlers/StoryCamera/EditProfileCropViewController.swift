//
//  EditProfileCropViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 08/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit
import CropPickerView

class EditProfileCropViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var cropContainerView: UIView!
    
    // MARK: - Variable Declarations
    private let cropPickerView: CropPickerView = {
        let cropPickerView = CropPickerView()
        cropPickerView.translatesAutoresizingMaskIntoConstraints = false
        cropPickerView.scrollMinimumZoomScale = 1
        cropPickerView.aspectRatio = 1
        cropPickerView.backgroundColor = .white
        return cropPickerView
    }()
    var croppedImage: UIImage?
    var inputImage: UIImage?
    var delegate: SharingSocialTypeDelegate?
    
    // MARK: - View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupCropContainerView()
        if let img = self.inputImage {
            self.cropPickerView.image(img)
        }
    }
    
    func setupCropContainerView() {
        self.cropContainerView.addSubview(self.cropPickerView)
        self.cropContainerView.addConstraints([
            NSLayoutConstraint(item: self.cropContainerView!, attribute: .top, relatedBy: .equal, toItem: self.cropPickerView, attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.cropContainerView!, attribute: .bottom, relatedBy: .equal, toItem: self.cropPickerView, attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.cropContainerView!, attribute: .leading, relatedBy: .equal, toItem: self.cropPickerView, attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: self.cropContainerView!, attribute: .trailing, relatedBy: .equal, toItem: self.cropPickerView, attribute: .trailing, multiplier: 1, constant: 0)
        ])
        self.cropPickerView.backgroundColor = .white
        self.cropPickerView.imageBackgroundColor = .white
    }
    
    // MARK: - Action Methods
    @IBAction func btnCancelTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDoneTapped(_ sender: UIButton) {
        self.cropPickerView.crop { (crop) in
            self.navigationController?.popViewController(animated: true, completion: {
                if let img = crop.image {
                    self.delegate?.setCroppedImage(croppedImg: img)
                }
            })
        }
    }
    
}
