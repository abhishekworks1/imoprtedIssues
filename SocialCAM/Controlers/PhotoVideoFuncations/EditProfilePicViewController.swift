//
//  EditProfilePicViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 07/07/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit

class EditProfilePicViewController: UIViewController {
    
    // MARK: - Outlets declaration
    @IBOutlet weak var imgProfilePic: UIImageView!
    
    // MARK: - Variables declaration
    private var localImageUrl: URL?
    private var imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let userImageURL = Defaults.shared.currentUser?.profileImageURL {
            imgProfilePic.sd_setImage(with: URL.init(string: userImageURL), placeholderImage: R.image.user_placeholder())
        } else {
            imgProfilePic.image = R.image.user_placeholder()
        }
    }
    
    // MARK: - Action Methods
    @IBAction func btnBackTapped(_ sender: UIButton) {
        var userProfile = Defaults.shared.currentUser?.profileImageURL
        userProfile = "\(String(describing: localImageUrl))"
        Defaults.shared.currentUser?.profileImageURL = userProfile
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
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    /// Delete Image
    private func deleteImage() {
        self.imgProfilePic.image = nil
    }
    
    /// Show ActionSheet for selecting Image
    private func showActionSheet() {
        let alert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: R.string.localizable.gallery(), style: .default, handler: { _ in
            self.getImage(fromSourceType: .photoLibrary)
        }))
        alert.addAction(UIAlertAction(title: R.string.localizable.camera(), style: .default, handler: { _ in
            self.getImage(fromSourceType: .camera)
        }))
        if imgProfilePic.image != nil {
            alert.addAction(UIAlertAction(title: R.string.localizable.remove(), style: .destructive, handler: { _ in
                self.deleteImage()
            }))
        }
        alert.addAction(UIAlertAction(title: R.string.localizable.cancel(), style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension EditProfilePicViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    /// Get selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        self.localImageUrl = info[.imageURL] as? URL
        imgProfilePic.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
    }
    
}
