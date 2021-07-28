//
//  SearchChannelViewController.swift
//  ViralCam
//
//  Created by Viraj Patel on 26/03/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import NSObject_Rx

class SearchChannelViewController: UIViewController {
    
    @IBOutlet var searchView: UIView!
    @IBOutlet var txtField: UITextField!
    @IBOutlet var tblSearch: UITableView!
    @IBOutlet var topImgViewBgConstraint: NSLayoutConstraint!
    @IBOutlet var lblEmpty: UIView!
    @IBOutlet weak var btnClear: UIButton!
    
    var channels: [Channel] = []
    var ChanelHandler: ((_ channel:Channel)->Void)?
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.dismissHUD()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblSearch.delegate = self
        txtField.delegate = self
        self.searchView.isHidden = false
        self.changeClearButton(shouldShow: !(txtField.text?.isEmpty ?? false))
        self.tblSearch.rowHeight = UITableView.automaticDimension
        self.tblSearch.estimatedRowHeight = 80
        txtField.returnKeyType = .search
        self.lblEmpty.isHidden = true
        
        let result = self.txtField.rx.text.orEmpty.throttle(0.5, scheduler:MainScheduler.instance).distinctUntilChanged().flatMapLatest { (q:String) -> Observable<ResultArray<Channel>> in
            self.showHUD()
            return ProManagerApi
                .search(channel:q, channelId: "")
                .request(ResultArray<Channel>.self)
        }
        
        result.subscribe(onNext: { response in
            self.dismissHUD()
            let ch: [Channel] = response.result!
            if ch.count > 0 {
                self.lblEmpty.isHidden = true
            } else {
                self.lblEmpty.isHidden = false
            }
            self.channels = ch
            self.tblSearch.reloadData()
        }, onError: { error in
            self.dismissHUD()
            self.lblEmpty.isHidden = false
        }, onCompleted: {
            
        }).disposed(by: (rx.disposeBag))
    }
    
    /// Hide clear button when search is complete
    private func changeClearButton(shouldShow: Bool) {
        btnClear.isHidden = !shouldShow
    }
    
    @IBAction func closeViewClicked() {
        self.view.endEditing(true)
    }
    
    @IBAction func backBtnClicked(_ sender:Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func searchClose(_ sender:Any) {
        self.changeClearButton(shouldShow: false)
        self.txtField.text = ""
        self.txtField.becomeFirstResponder()
        self.txtField.resignFirstResponder()
    }
    
    @IBAction func searchOpen(_ sender:Any) {
        self.searchView.isHidden = false
    }
    
}

// MARK: - TextField Delegate
extension SearchChannelViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.changeClearButton(shouldShow: true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.changeClearButton(shouldShow: !(txtField.text?.isEmpty ?? false))
    }
    
}

extension SearchChannelViewController : UITableViewDataSource , UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.chanelCell.identifier) as? ChanelCell else {
            fatalError("ChanelCell Not Found")
        }
        cell.channel = self.channels[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let ch = ChanelHandler {
            ch(self.channels[indexPath.row])
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.tblSearch {
            self.topImgViewBgConstraint.constant = -(scrollView.contentOffset.y - 5)
        }
    }
    
}
