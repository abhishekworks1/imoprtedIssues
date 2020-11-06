//
//  SSUTagSelectionViewController.swift
//  SocialCAM
//
//  Created by Jasmin Patel on 06/03/20.
//  Copyright © 2020 Viraj Patel. All rights reserved.
//

import UIKit

enum SSUTagType {
    case socialCam
    case viralCam
    case referralLink
    case social
    case service
    case challenges
    case poll
    case pic2art
    case timeSpeed
    case boomiCam
    case fastCam
    case soccerCam
    case futbolCam
    case quickCam
    case snapCam
    case viralCamLite
    case quickCamLite
    case fastCamLite
    case speedCam
    case speedCamLite
    case snapCamLite
}

enum SSUWaitingListOptionType {
    case socialCam
    case socialGames
    case secureSocialChat
    case okBoomer
    case influencerTool
    case socialSwipeUp
}

enum SSUTagScreen {
    case ssutTypes
    case ssutWaitingList
    case ssutSocial
}

struct SSUTagOption {
    var name: String
    var image: UIImage?
    var type: SSUTagType

    #if PIC2ARTAPP
    static let contents: [SSUTagOption] = [
        SSUTagOption(name: R.string.localizable.pic2Art(), image: R.image.ssuPic2Art(), type: .pic2art)]
    #elseif TIMESPEEDAPP
    static let contents: [SSUTagOption] = [
        SSUTagOption(name: R.string.localizable.timeSpeed(), image: R.image.ssuTimeSpeed(), type: .timeSpeed)]
    #elseif FASTCAMAPP
    static let contents: [SSUTagOption] = [SSUTagOption(name: R.string.localizable.fastCam(), image: R.image.ssuFastCam(), type: .fastCam)]
    #elseif BOOMICAMAPP
       static let contents: [SSUTagOption] = [
           SSUTagOption(name: R.string.localizable.boomiCam(), image: R.image.ssuBoomiCam(), type: .boomiCam)]
    #elseif FASTCAMAPP
    static let contents: [SSUTagOption] = [
        SSUTagOption(name: R.string.localizable.fastCam(), image: R.image.ssuFastCam(), type: .fastCam)]
    #elseif SOCCERCAMAPP
       static let contents: [SSUTagOption] = [
           SSUTagOption(name: R.string.localizable.soccerCam(), image: R.image.ssuSoccerCam(), type: .soccerCam)]
    #elseif FUTBOLCAMAPP
       static let contents: [SSUTagOption] = [
              SSUTagOption(name: R.string.localizable.futbolCam(), image: R.image.ssuSoccerCam(), type: .futbolCam)]
    #elseif QUICKCAMAPP
    static let contents: [SSUTagOption] = [
           SSUTagOption(name: R.string.localizable.quickCam(), image: R.image.ssuQuickCam(), type: .quickCam)]
    #elseif SNAPCAMAPP
    static let contents: [SSUTagOption] = [
           SSUTagOption(name: R.string.localizable.snapCam(), image: R.image.ssuSnapCam(), type: .snapCam)]
    #elseif SPEEDCAMAPP
    static let contents: [SSUTagOption] = [
           SSUTagOption(name: R.string.localizable.speedCam(), image: R.image.ssuSpeedCam(), type: .speedCam)]
    #elseif VIRALCAMLITEAPP
    static let contents: [SSUTagOption] = [
        SSUTagOption(name: R.string.localizable.viralCamLite(), image: R.image.ssuViralCamLite(), type: .viralCamLite)]
    #elseif FASTCAMLITEAPP
    static let contents: [SSUTagOption] = [
        SSUTagOption(name: R.string.localizable.fastCamLite(), image: R.image.ssuFastCamLite(), type: .fastCamLite)]
    #elseif QUICKCAMLITEAPP
    static let contents: [SSUTagOption] = [
        SSUTagOption(name: R.string.localizable.quickCamLite(), image: R.image.ssuQuickCamLite(), type: .quickCamLite)]
    #elseif SPEEDCAMLITEAPP
    static let contents: [SSUTagOption] = [
        SSUTagOption(name: R.string.localizable.speedCamLite(), image: R.image.speedcamLiteSsu(), type: .speedCamLite)]
    #elseif SNAPCAMLITEAPP
    static let contents: [SSUTagOption] = [
        SSUTagOption(name: R.string.localizable.snapCamLite(), image: R.image.snapCamLiteSSU(), type: .snapCamLite)]
    #else
    static let contents: [SSUTagOption] = [
        SSUTagOption(name: R.string.localizable.socialCam(), image: R.image.ssuSocialCam(), type: .socialCam),
        SSUTagOption(name: R.string.localizable.waitingList(), image: R.image.ssuWaiting(), type: .referralLink),
        SSUTagOption(name: R.string.localizable.social(), image: R.image.ssuSocialMedia(), type: .social),
        SSUTagOption(name: R.string.localizable.service(), image: R.image.service(), type: .service),
        SSUTagOption(name: R.string.localizable.challenges(), image: R.image.challenge(), type: .challenges),
        SSUTagOption(name: R.string.localizable.poll(), image: R.image.poll(), type: .poll)]
    #endif
}

struct SSUTagWaitingListOption {
    var name: String
    var image: UIImage?
    var type: SSUWaitingListOptionType

    static let contents: [SSUTagWaitingListOption] = [SSUTagWaitingListOption(name: R.string.localizable.socialGames(), image: R.image.ssuSocialGames(), type: .socialGames), SSUTagWaitingListOption(name: R.string.localizable.secureSocialChat(), image: R.image.ssuSecureChat(), type: .secureSocialChat), SSUTagWaitingListOption(name: R.string.localizable.okBoomer(), image: R.image.okBoomer(), type: .okBoomer), SSUTagWaitingListOption(name: R.string.localizable.influencerTool(), image: R.image.influencerTool(), type: .influencerTool), SSUTagWaitingListOption(name: R.string.localizable.socialSwipeUp(), image: R.image.socialSwipeUp(), type: .socialSwipeUp)]
}

struct SSUTagSocialOption {
    var name: String
    var image: UIImage?
    var type: SocialShare

    static let contents: [SSUTagSocialOption] = [SSUTagSocialOption(name: R.string.localizable.facebook(), image: R.image.icoFacebook(), type: .facebook),
                                                 SSUTagSocialOption(name: R.string.localizable.snapchat(), image: R.image.icoSnapchat(), type: .snapchat),
                                                 SSUTagSocialOption(name: R.string.localizable.instagram(), image: R.image.icoInstagram(), type: .instagram),
                                                 SSUTagSocialOption(name: R.string.localizable.tikTok(), image: R.image.icoTikTok(), type: .tiktok),
                                                 SSUTagSocialOption(name: R.string.localizable.twitter(), image: R.image.icoTwitter(), type: .twitter),
                                                 SSUTagSocialOption(name: R.string.localizable.youtube(), image: R.image.icoYoutube(), type: .youtube)]
}

class SSUTagSelectionCell: UICollectionViewCell {
    @IBOutlet weak var tagImageView: UIImageView!
    @IBOutlet weak var tagLabel: UILabel!
}

protocol SSUTagSelectionDelegate {
    func didSelect(type: SSUTagType?, waitingListOptionType: SSUWaitingListOptionType?, socialShareType: SocialShare?, screenType: SSUTagScreen)
}

class SSUTagSelectionViewController: UIViewController {

    @IBOutlet weak var navigationTitle: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    public var delegate: SSUTagSelectionDelegate?
    
    public var type: SSUTagScreen = SSUTagScreen.ssutTypes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTitle()
    }
    
    internal func setTitle() {
        var titleText: String?
        switch type {
        case .ssutTypes:
            titleText = R.string.localizable.socialSwipeUpTypes()
        case .ssutWaitingList:
            titleText = R.string.localizable.waitingList()
        case .ssutSocial:
            titleText = R.string.localizable.social()
        }
        navigationTitle.text = titleText
    }
    
    @IBAction func onBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
}

extension SSUTagSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch type {
        case .ssutTypes:
            return SSUTagOption.contents.count
        case .ssutWaitingList:
            return SSUTagWaitingListOption.contents.count
        case .ssutSocial:
            return SSUTagSocialOption.contents.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.ssuTagSelectionCell.identifier, for: indexPath) as? SSUTagSelectionCell else {
            return UICollectionViewCell()
        }
        
        switch type {
        case .ssutTypes:
            cell.tagImageView.image = SSUTagOption.contents[indexPath.row].image
            cell.tagLabel.text = SSUTagOption.contents[indexPath.row].name
        case .ssutWaitingList:
            cell.tagImageView.image = SSUTagWaitingListOption.contents[indexPath.row].image
            cell.tagLabel.text = SSUTagWaitingListOption.contents[indexPath.row].name
        case .ssutSocial:
            cell.tagImageView.image = SSUTagSocialOption.contents[indexPath.row].image
            cell.tagLabel.text = SSUTagSocialOption.contents[indexPath.row].name
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch type {
        case .ssutTypes:
            switch SSUTagOption.contents[indexPath.row].type {
            case .viralCam:
                self.dismiss(animated: true) {
                    self.delegate?.didSelect(type: SSUTagOption.contents[indexPath.row].type, waitingListOptionType: nil, socialShareType: nil, screenType: self.type)
                }
            case .referralLink:
                if let ssuTagSelectionViewController = R.storyboard.storyCameraViewController.ssuTagSelectionViewController() {
                    ssuTagSelectionViewController.delegate = self
                    ssuTagSelectionViewController.type = .ssutWaitingList
                    let navigation: UINavigationController = UINavigationController(rootViewController: ssuTagSelectionViewController)
                    navigation.isNavigationBarHidden = true
                    self.present(navigation, animated: true)
                }
            case .social:
                if let ssuTagSelectionViewController = R.storyboard.storyCameraViewController.ssuTagSelectionViewController() {
                    ssuTagSelectionViewController.delegate = self
                    ssuTagSelectionViewController.type = .ssutSocial
                    let navigation: UINavigationController = UINavigationController(rootViewController: ssuTagSelectionViewController)
                    navigation.isNavigationBarHidden = true
                    self.present(navigation, animated: true)
                }
            case .pic2art, .timeSpeed, .boomiCam, .soccerCam, .fastCam, .futbolCam, .socialCam, .snapCam, .quickCam, .quickCamLite, .viralCamLite, .fastCamLite, .speedCam, .speedCamLite, .snapCamLite:
                self.dismiss(animated: true) {
                    self.delegate?.didSelect(type: SSUTagOption.contents[indexPath.row].type, waitingListOptionType: nil, socialShareType: nil, screenType: self.type)
                }
            default:
                self.showAlert(alertMessage: R.string.localizable.comingSoon())
            }
        case .ssutWaitingList:
            switch SSUTagWaitingListOption.contents[indexPath.row].type {
            case .socialCam:
                self.dismiss(animated: true) {
                    self.delegate?.didSelect(type: nil, waitingListOptionType: SSUTagWaitingListOption.contents[indexPath.row].type, socialShareType: nil, screenType: self.type)
                }
            default:
                self.showAlert(alertMessage: R.string.localizable.comingSoon())
            }
        default:
            self.showAlert(alertMessage: R.string.localizable.comingSoon())
        }
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

extension SSUTagSelectionViewController: SSUTagSelectionDelegate {
    func didSelect(type: SSUTagType?, waitingListOptionType: SSUWaitingListOptionType?, socialShareType: SocialShare?, screenType: SSUTagScreen) {
        switch screenType {
        case .ssutTypes:
            self.dismiss(animated: false) {
                self.delegate?.didSelect(type: nil, waitingListOptionType: waitingListOptionType, socialShareType: nil, screenType: screenType)
            }
        case .ssutWaitingList:
            self.dismiss(animated: false) {
                self.delegate?.didSelect(type: nil, waitingListOptionType: waitingListOptionType, socialShareType: nil, screenType: screenType)
            }
        default:
            break
        }
    }
}
