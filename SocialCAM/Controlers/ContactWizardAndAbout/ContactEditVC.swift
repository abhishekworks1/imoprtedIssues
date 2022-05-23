//
//  ContactEditVC.swift
//  SocialCAM
//
//  Created by Navroz Huda on 08/04/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit
import Alamofire


struct EditContact:Codable{
    var name: String = ""
    init(name:String) {
        self.name = name
    }
    
}
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
    var delegate:ContactImportDelegate?
   
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
        
        txtEmail.text = contact?.email
        txtName.text = contact?.name
        txtPhone.text = contact?.mobile
        
        txtPhone.isUserInteractionEnabled = false
        txtEmail.isUserInteractionEnabled = false
    }
    @IBAction func doneClicked(sender:UIButton){
        let editContact = EditContact(name:txtName.text!)
        let jsonEncoder = JSONEncoder()
        do {
            let jsonData = try jsonEncoder.encode(editContact)
            self.editContact(data:jsonData)
           
        } catch {
            print("error")
        }
    }
    @IBAction func cancelClicked(sender:UIButton){
        self.dismiss(animated:true, completion: nil)
    }
    private func editContact(data:Data){
       
        let path = API.shared.baseUrlV2 + "contact-list/\(contact?.Id ?? "")/user/info"
        print(path)
        var request = URLRequest(url:URL(string:path)!)
        //some header examples
        request.httpMethod = "PUT"
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
                self.delegate?.didFinishEdit(contact:self.contact!)
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
extension ContactEditVC: UITextFieldDelegate {
   
    
}
extension UIView {
    
    func dropShadowNew(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOpacity = 0.9
        layer.shadowOffset = .zero
        layer.shadowRadius = 1
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 1
    func dropShadow(scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: -1, height: 1)
        layer.shadowRadius = 1
        
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    // OUTPUT 2
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = offSet
        layer.shadowRadius = radius
        
        layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}
