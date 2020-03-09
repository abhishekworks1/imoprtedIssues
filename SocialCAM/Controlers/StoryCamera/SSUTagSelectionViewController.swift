//
//  SSUTagSelectionViewController.swift
//  SocialCAM
//
//  Created by Jasmin Patel on 06/03/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

enum SSUTagType {
    case referralLink
    case social
}

struct SSUTagOption {
    var name: String
    var image: UIImage
    var type: SSUTagType
    
    static let contents: [SSUTagOption] = [SSUTagOption(name: R.string.localizable.referralLink(), image: #imageLiteral(resourceName: "ssuReferLink"), type: .referralLink),
                                           SSUTagOption(name: R.string.localizable.social(), image: #imageLiteral(resourceName: "ssuSocial"), type: .social)]
}

class SSUTagSelectionCell: UICollectionViewCell {
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
}

protocol SSUTagSelectionDelegate {
    func didSelect(type: SSUTagType)
}

class SSUTagSelectionViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    public var delegate: SSUTagSelectionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func onBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

}

extension SSUTagSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return SSUTagOption.contents.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SSUTagSelectionCell", for: indexPath) as! SSUTagSelectionCell
        cell.tagImageView.image = SSUTagOption.contents[indexPath.row].image
        cell.tagLabel.text = SSUTagOption.contents[indexPath.row].name
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelect(type: SSUTagOption.contents[indexPath.row].type)
        navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: UIScreen.width/3, height: 91)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}
