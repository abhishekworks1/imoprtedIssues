//
//  EditProfilePicViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 07/07/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit
import AVKit

class EditProfilePicViewController: UIViewController {
    
    // MARK: - Outlets declaration
    @IBOutlet weak var imgProfilePic: UIImageView!
    
    // MARK: - Variables declaration
    private var localImageUrl: URL?
    private var imagePicker = UIImagePickerController()
    var storyCameraVCInstance = StoryCameraViewController()
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
            imgProfilePic.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
        } else {
            imgProfilePic.image = R.image.user_placeholder()
        }
        imgProfilePic.layer.cornerRadius = imgProfilePic.bounds.width / 2
        imgProfilePic.contentMode = .scaleAspectFill
    }
    
    // MARK: - Action Methods
    @IBAction func btnBackTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnUpdateTapped(_ sender: UIButton) {
        self.showActionSheet()
    }
    
}

// MARK: - Camera and Photo gallery methods
extension EditProfilePicViewController {
    
    /// get image from source type
    private func getImage(fromSourceType sourceType: UIImagePickerController.SourceType) {
        /// Check is source type available
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            imagePicker.delegate = self
            imagePicker.sourceType = sourceType
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /// Delete Image
    private func deleteImage() {
        self.imgProfilePic.image = UIImage()
    }
    
    /// Show ActionSheet for selecting Image
    private func showActionSheet() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: R.string.localizable.gallery(), style: .default, handler: { _ in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.camera(), style: .default, handler: { _ in
            self.getImage(fromSourceType: .camera)
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension EditProfilePicViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// Get selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        self.localImageUrl = info[.imageURL] as? URL
        imgProfilePic.image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        if let img = imgProfilePic.image,
           let compressedImg = img.jpegData(compressionQuality: 1) {
            let imageSize: Int = compressedImg.count
            let imgSizeInKb = Double(imageSize) / 1000.0
            if imgSizeInKb > 8000.0 {
                imgProfilePic.image = imgProfilePic.image?.resizeWithWidth(width: 2000)
            }
            self.dismiss(animated: true, completion: nil)
            if let img = imgProfilePic.image {
                self.showHUD()
                self.view.isUserInteractionEnabled = false
                self.updateProfilePic(image: img)
            }
        }
    }
    
}

// MARK: - API Methods
extension EditProfilePicViewController {
    
    func updateProfilePic(image: UIImage) {
        ProManagerApi.uploadPicture(image: image).request(Result<EmptyModel>.self).subscribe(onNext: { (response) in
            self.dismissHUD()
            self.view.isUserInteractionEnabled = true
            if response.status == ResponseType.success {
                self.storyCameraVCInstance.syncUserModel()
            } else {
                self.showAlert(alertMessage: response.message ?? R.string.localizable.somethingWentWrongPleaseTryAgainLater())
            }
        }, onError: { error in
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
}
