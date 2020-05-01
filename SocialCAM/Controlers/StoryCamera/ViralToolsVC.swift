//
//  ViralToolsVC.swift
//  SocialCAM
//
//  Created by Viraj Patel on 28/04/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import Foundation
import UIKit

struct ViralTagOption {
    var name: String
    var image: UIImage?
    var type: SSUTagType
    
    static let contents: [SSUTagOption] = [SSUTagOption(name: R.string.localizable.viralPolls(), image: R.image.icoViralpoll(), type: .viralCam), SSUTagOption(name: R.string.localizable.stat(), image: R.image.icoViralstat(), type: .referralLink), SSUTagOption(name: R.string.localizable.map(), image: R.image.icoViralWorld(), type: .social), SSUTagOption(name: R.string.localizable.quiz(), image: R.image.icoViralquiz(), type: .service), SSUTagOption(name: R.string.localizable.followFriday(), image: R.image.icoViralFollowFriday(), type: .challenges)]
}

class ViralToolsVC: UIViewController {

    @IBOutlet weak var navigationTitle: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
     
}

extension ViralToolsVC: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ViralTagOption.contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.ssuTagSelectionCell.identifier, for: indexPath) as? SSUTagSelectionCell else {
            return UICollectionViewCell()
        }
        cell.tagImageView.image = ViralTagOption.contents[indexPath.row].image
        cell.tagLabel.text = ViralTagOption.contents[indexPath.row].name
       
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.showAlert(alertMessage: R.string.localizable.comingSoon())
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width/3, height: 115)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
