//
//  ContactEditVC.swift
//  SocialCAM
//
//  Created by Navroz Huda on 08/04/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class ContactEditVC: UIViewController {

    @IBOutlet weak var userImageview: UIImageView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    var isEmail = true
    var contact:ContactResponse?
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    
    func setUI(){
        if isEmail{
            phoneView.isHidden = true
        }else{
            emailView.isHidden = true
        }
        txtPhone.delegate = self
        txtName.delegate = self
        txtEmail.delegate = self
    }
    @IBAction func doneClicked(sender:UIButton){
        
    }
    @IBAction func cancelClicked(sender:UIButton){
        self.dismiss(animated:true, completion: nil)
    }
    private func editContact(){
        
    }
}
