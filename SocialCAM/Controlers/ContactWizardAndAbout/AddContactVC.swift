//
//  AddContactVC.swift
//  SocialCAM
//
//  Created by Navroz Huda on 27/09/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit
import Alamofire
struct AddContact:Codable{
    var name: String = ""
    var mobile: String?
    var email: String?
    init(name:String,mobile:String?,email:String) {
        self.name = name
        self.mobile = mobile
        self.email = email
    }
}
class AddContactVC: UIViewController {

    @IBOutlet weak var userImageview: UIImageView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    var isEmail = true
    var contact:ContactResponse?
    var delegate:ContactImportDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUI()
    }
    
    func setUI(){
       
//        txtPhone.delegate = self
//        txtName.delegate = self
//        txtEmail.delegate = self
        
        txtEmail.text = ""
        txtName.text = ""
        txtPhone.text = ""
        
        txtPhone.isUserInteractionEnabled = true
        txtEmail.isUserInteractionEnabled = true
        
        txtEmail.keyboardType = .emailAddress
        txtPhone.keyboardType = .phonePad
    }
    @IBAction func doneClicked(sender:UIButton){
        if txtPhone.text!.count < 10 && isEmail == false{
            DispatchQueue.runOnMainThread {
                Utils.customaizeToastMessage(title: "Please enter valid mobile number.", toastView: (Utils.appDelegate?.window)!)
            }
            return

        }
        if txtEmail.text!.isValidEmail() == false{
            DispatchQueue.runOnMainThread {
                Utils.customaizeToastMessage(title: "Please enter valid email.", toastView: (Utils.appDelegate?.window)!)
            }
            return
        }
        let editContact = AddContact(name:txtName.text!, mobile: txtPhone.text!,email: txtEmail.text!)
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(editContact)
            self.addContact(data:jsonData)
           
        } catch {
            print("error")
        }
    }
    @IBAction func cancelClicked(sender:UIButton){
        self.dismiss(animated:true, completion: nil)
    }
    private func addContact(data:Data){
       
        let path = API.shared.baseUrlV2 + "contact-list/new-contact"
        print(path)
        var request = URLRequest(url:URL(string:path)!)
        //some header examples
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(Defaults.shared.currentUser?.id ?? "", forHTTPHeaderField: "userid")
        request.setValue(Defaults.shared.sessionToken ?? "", forHTTPHeaderField: "x-access-token")
        request.setValue("1", forHTTPHeaderField: "deviceType")
        request.httpBody = data
        AF.request(request).responseJSON { response in
            print(response)
            switch (response.result) {
            case .success:
              //  self.showLoader()
                self.contact?.name = self.txtName.text!
                self.contact?.mobile = self.txtPhone.text!
                self.contact?.email = self.txtEmail.text!
               // self.delegate?.didFinishEdit(contact:self.contact!)
                DispatchQueue.runOnMainThread {
                    Utils.customaizeToastMessage(title: "Contact added.", toastView: (Utils.appDelegate?.window)!)
                }

                self.dismiss(animated:true, completion: nil)
                break
               
            case .failure(let error):
                print(error)
                break

                //failure code here
            }
        }
    }

}
