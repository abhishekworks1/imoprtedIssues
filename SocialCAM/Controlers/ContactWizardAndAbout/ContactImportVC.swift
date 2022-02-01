//
//  ContactImportVC.swift
//  SocialCAM
//
//  Created by Gaurang Pandya on 26/01/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit
import SafariServices

class ContactImportVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet weak var line1: UILabel!
    @IBOutlet weak var line2: UILabel!
    @IBOutlet weak var line3: UILabel!

    @IBOutlet weak var lblNum2: UILabel!
    @IBOutlet weak var lblNum3: UILabel!
    @IBOutlet weak var lblNum4: UILabel!

    @IBOutlet weak var page1view: UIView!
    @IBOutlet weak var page2view: UIView!
    @IBOutlet weak var page3view: UIView!
    @IBOutlet weak var page4view: UIView!

    @IBOutlet weak var frwrdarrow1: UIImageView!
    @IBOutlet weak var frwrdarrow2: UIImageView!
    @IBOutlet weak var frwrdarrow3: UIImageView!
    
    @IBOutlet weak var page3NextBtn: UIButton!


    let blueColor = UIColor(red: 13/255, green: 94/255, blue: 255/255, alpha: 1.0)
    let grayColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
    var pageNo : Int = 1
    var isSelectSMS : Bool = false
    
    let messageArr : [String] = ["Check out this cool new app, QuickCam!", "Download this new camera app and create awesome cool videos.", "Make money sharing this hot new app!"]
    
    @IBOutlet weak var itemsTableView: UITableView!
    var selectedTitleRow : Int = 0
    
    fileprivate static let CELL_IDENTIFIER = "messageTitleCell"

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupUI()
        self.setupPage()
    }
    // MARK: - UI setup
    func setupUI(){
        frwrdarrow1.setImageColor(color: UIColor(hexString: "007DFF"))
        frwrdarrow2.setImageColor(color: UIColor(hexString: "7D46F5"))
        frwrdarrow3.setImageColor(color: UIColor(hexString: "E48C4C"))

        itemsTableView.register(UINib.init(nibName: ContactImportVC.CELL_IDENTIFIER, bundle: nil), forCellReuseIdentifier: ContactImportVC.CELL_IDENTIFIER)
        
        itemsTableView.allowsSelection = true
        itemsTableView.dataSource = self
        itemsTableView.delegate = self
        itemsTableView.reloadData()
    }
    func setupPage(){
        if pageNo == 1 {
            page1view.isHidden = false
            page2view.isHidden = true
            page3view.isHidden = true
            page4view.isHidden = true
            line1.backgroundColor = grayColor
            line2.backgroundColor = grayColor
            line3.backgroundColor = grayColor
            lblNum2.textColor = grayColor
            lblNum3.textColor = grayColor
            lblNum4.textColor = grayColor
            lblNum2.backgroundColor = .white
            lblNum3.backgroundColor = .white
            lblNum4.backgroundColor = .white
        }
        if pageNo == 2{
            page1view.isHidden = true
            page2view.isHidden = false
            page3view.isHidden = true
            page4view.isHidden = true
            line1.backgroundColor = blueColor
            line2.backgroundColor = grayColor
            line3.backgroundColor = grayColor
            lblNum2.textColor = .white
            lblNum3.textColor = grayColor
            lblNum4.textColor = grayColor
            lblNum2.backgroundColor = blueColor
            lblNum3.backgroundColor = .white
            lblNum4.backgroundColor = .white
        }
        
        if pageNo == 3{
            page1view.isHidden = true
            page2view.isHidden = true
            page3view.isHidden = false
            page4view.isHidden = true
            line1.backgroundColor = blueColor
            line2.backgroundColor = blueColor
            line3.backgroundColor = grayColor
            lblNum2.textColor = .white
            lblNum3.textColor = .white
            lblNum4.textColor = grayColor
            lblNum2.backgroundColor = blueColor
            lblNum3.backgroundColor = blueColor
            lblNum4.backgroundColor = .white
            if isSelectSMS {
                page3NextBtn.setTitle("Next", for: .normal)
            }else{
                page3NextBtn.setTitle("Done", for: .normal)
            }
        }
        
        if pageNo == 4{
            page1view.isHidden = true
            page2view.isHidden = true
            page3view.isHidden = true
            page4view.isHidden = false
            line1.backgroundColor = blueColor
            line2.backgroundColor = blueColor
            line3.backgroundColor = blueColor
            lblNum2.textColor = .white
            lblNum3.textColor = .white
            lblNum4.textColor = .white
            lblNum2.backgroundColor = blueColor
            lblNum3.backgroundColor = blueColor
            lblNum4.backgroundColor = blueColor
        }
    }
    func fetchTitleMessages(){
        ProManagerApi.userSync.request(Result<UserSyncModel>.self).subscribe(onNext: { (response) in
            if response.status == ResponseType.success {
                //print("***userSync***\(response)")
                
            }
        }, onError: { error in
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)

    }
    
    
    // MARK: - tableview Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:messageTitleCell = self.itemsTableView.dequeueReusableCell(withIdentifier: ContactImportVC.CELL_IDENTIFIER) as! messageTitleCell
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        let item = self.self.messageArr[indexPath.row]
        cell.textLbl.text = item
        print(item)
        if selectedTitleRow == indexPath.row {
            cell.selectionImageView.image = UIImage.init(named: "radioSelected")
        }else{
            cell.selectionImageView.image = UIImage.init(named: "radioDeselected")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTitleRow = indexPath.row
        itemsTableView.reloadData()
    }
    // MARK: - Button Methods
    @IBAction func onBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func previousClick(_ sender: UIButton) {
        if sender.tag == 1 {
            pageNo = 1
            self.setupPage()
        }else if sender.tag == 2 {
            pageNo = 2
            self.setupPage()
        }else if sender.tag == 3 {
            pageNo = 3
            self.setupPage()
        }
    }
    
    @IBAction func nextClick(_ sender: UIButton) {
        if sender.tag == 1 {
            pageNo = 3
            self.setupPage()
        }
       else if sender.tag == 2 {
           if isSelectSMS {
               pageNo = 4
               self.setupPage()
           }else{
               navigationController?.popViewController(animated: true)
           }
        }
        else if sender.tag == 3 {
            navigationController?.popViewController(animated: true)
        }
        
    }
    @IBAction func mainOptionsClick(_ sender: UIButton) {
        if sender.tag == 1 {
            isSelectSMS = false
            pageNo = 2
            self.setupPage()
        }else if sender.tag == 2 {
            isSelectSMS = true
            pageNo = 2
            self.setupPage()
        }else if sender.tag == 3 {
            if let token = Defaults.shared.sessionToken {
                let urlString = "\(websiteUrl)/share-wizard?token=\(token)&platformType=ios&redirect_uri=\(redirectUri)"
                print(urlString)
                guard let url = URL(string: urlString) else {
                    return
                }
                presentSafariBrowser(url: url)
            }
        }
    }
    func presentSafariBrowser(url: URL) {
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true, completion: nil)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
