//
//  CountryPickerViewController.swift
//  CountryPickerView
//
//  Created by Kizito Nwose on 18/09/2017.
//  Copyright © 2017 Kizito Nwose. All rights reserved.
//

import UIKit
import AVKit

private let animationDuration: TimeInterval = 0.3
private let listLayoutStaticCellHeight: CGFloat = 70
private let gridLayoutStaticCellHeight: CGFloat = 115

public protocol CountryPickerViewDelegate: class {
    /// Called when the user selects a country from the list.
    func countryPickerView(_ didSelectCountry : [Country])
}

class CountryPickerViewController: UIViewController {
    
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var searchBar: UISearchBar!
    @IBOutlet fileprivate weak var doneButton: UIButton!
    @IBOutlet fileprivate weak var layoutButton: UIButton!
    @IBOutlet fileprivate weak var lblCountryFlag: UILabel!
    @IBOutlet weak var lblPopup: UILabel!
    @IBOutlet weak var popupView: UIView!
    
    public weak var delegate: CountryPickerViewDelegate?
    public weak var statePickerDelegate: StatePickerViewDelegate?
    fileprivate var tap: UITapGestureRecognizer!
    public var selectedCountries: [Country] = [Country]()
    fileprivate var searchUsers = [Country]()
    public let users: [Country] = {
        var countries = [Country]()
        let bundle = Bundle.main
        guard let jsonPath = bundle.path(forResource: "CountryPickerView.bundle/Data/CountryCodes", ofType: "json"),
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
                return countries
        }
        
        if let jsonObjects = (try? JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization
            .ReadingOptions.allowFragments)) as? Array<Any> {
            
            for jsonObject in jsonObjects {
                
                guard let countryObj = jsonObject as? Dictionary<String, Any> else {
                    continue
                }
                
                guard let name = countryObj["name"] as? String,
                    let code = countryObj["code"] as? String,
                    let phoneCode = countryObj["dial_code"] as? String else {
                        continue
                }
                
                let country = Country(name: name, code: code, phoneCode: phoneCode, isState: false)
                countries.append(country)
            }
        }
        return countries
    }()
    
    fileprivate var isTransitionAvailable = true
    fileprivate lazy var listLayout = DisplaySwitchLayout(
        staticCellHeight: listLayoutStaticCellHeight,
        nextLayoutStaticCellHeight: gridLayoutStaticCellHeight,
        layoutState: .list
    )
    fileprivate lazy var gridLayout = DisplaySwitchLayout(
        staticCellHeight: gridLayoutStaticCellHeight,
        nextLayoutStaticCellHeight: listLayoutStaticCellHeight,
        layoutState: .grid
    )
    fileprivate var layoutState: LayoutState = .grid
    private lazy var storyCameraVC = StoryCameraViewController()
    var isClearFlagSelected = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        searchBar.delegate = self
        searchUsers = users
        layoutButton.isSelected = layoutState == .list
        setupCollectionView()
    }
    
    // MARK: - Private methods
    fileprivate func setupCollectionView() {
        collectionView.collectionViewLayout = gridLayout
        collectionView.register(CountryPickerViewCell.cellNib, forCellWithReuseIdentifier: CountryPickerViewCell.id)
    }
    
    private func showHidePopupView(isHide: Bool, text: String) {
        self.popupView.isHidden = isHide
        self.lblPopup.text = text
    }
    
    private func openStateView() {
        self.showHidePopupView(isHide: true, text: "")
        if let stateVc = R.storyboard.countryPicker.statePickerViewController() {
            stateVc.delegate = self
            stateVc.selectedStates = self.selectedCountries
            self.navigationController?.pushViewController(stateVc, animated: true)
        }
    }
    
    // MARK: - Actions
    @IBAction func btnBackTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonTapped(_ sender: AnyObject) {
        if !isTransitionAvailable {
            return
        }
        let transitionManager: TransitionManager
        if layoutState == .list {
            layoutState = .grid
            transitionManager = TransitionManager(
                duration: animationDuration,
                collectionView: collectionView!,
                destinationLayout: gridLayout,
                layoutState: layoutState
            )
        } else {
            layoutState = .list
            transitionManager = TransitionManager(
                duration: animationDuration,
                collectionView: collectionView!,
                destinationLayout: listLayout,
                layoutState: layoutState
            )
        }
        transitionManager.startInteractiveTransition()
        layoutButton.isSelected = layoutState == .list
    }
    
    // MARK: - Actions
    @IBAction func donebuttonTapped(_ sender: AnyObject) {
        if selectedCountries.isEmpty {
            self.isClearFlagSelected = true
            self.showHidePopupView(isHide: false, text: R.string.localizable.didYouWantToClearYourFlagSelection())
        } else {
            delegate?.countryPickerView(selectedCountries)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func tapRecognized() {
        view.endEditing(true)
    }
    
    fileprivate func maxCheck() -> Bool {
        if 2 <= self.selectedCountries.count {
            DispatchQueue.runOnMainThread {
                Utils.appDelegate?.window?.makeToast(R.string.localizable.youCanSelectMaximum2Country())
            }
            return true
        }
        return false
    }
    
    @IBAction func btnPopupYesTapped(_ sender: UIButton) {
        self.showHidePopupView(isHide: true, text: "")
        if isClearFlagSelected {
            self.isClearFlagSelected = false
            self.delegate?.countryPickerView(selectedCountries)
            self.navigationController?.popViewController(animated: true)
        } else {
            self.openStateView()
        }
    }
    
    @IBAction func btnPopupNoTapped(_ sender: UIButton) {
        self.showHidePopupView(isHide: true, text: "")
        if isClearFlagSelected {
            self.isClearFlagSelected = false
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

// MARK: - API Methods
extension CountryPickerViewController {
    
    func setCountrys(_ countrys: [Country]) {
        var arrayCountry: [[String: Any]] = []
        for country in countrys {
            let material: [String: Any] = [
                "state": country.isState ? country.name : "",
                "stateCode": country.isState ? country.code : "",
                "country": country.isState ? StaticKeys.countryNameUS : country.name,
                "countryCode": country.isState ? StaticKeys.countryCodeUS: country.code
            ]
            arrayCountry.append(material)
        }
        
        ProManagerApi.setCountrys(arrayCountry: arrayCountry).request(Result<EmptyModel>.self).subscribe(onNext: { [weak self] (response) in
            guard let `self` = self else {
                return
            }
            self.storyCameraVC.syncUserModel { _ in
                self.dismissHUD()
                if let shareSettingVC = R.storyboard.editProfileViewController.shareSettingViewController() {
                    self.navigationController?.pushViewController(shareSettingVC, animated: true)
                }
            }
        }, onError: { error in
            self.dismissHUD()
            self.showAlert(alertMessage: error.localizedDescription)
        }, onCompleted: {
        }).disposed(by: self.rx.disposeBag)
    }
    
}

extension CountryPickerViewController: StatePickerViewDelegate {
    
    func statePickerView(_ didSelectCountry: [Country], isSelectionDone: Bool) {
        self.selectedCountries = didSelectCountry
        if isSelectionDone {
            self.delegate?.countryPickerView(selectedCountries)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

extension CountryPickerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CountryPickerViewCell.id,
            for: indexPath
            ) as! CountryPickerViewCell
        if layoutState == .grid {
            cell.setupGridLayoutConstraints(1, cellWidth: cell.frame.width)
        } else {
            cell.setupListLayoutConstraints(1, cellWidth: cell.frame.width)
        }
        cell.bind(searchUsers[indexPath.row])
        let country = searchUsers[indexPath.row]
        cell.selectedItem = (selectedCountries.firstIndex(of: country) != nil) ? true : false
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchUsers.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CountryPickerViewCell {
            let co = searchUsers[indexPath.row]
            if let index = self.selectedCountries.firstIndex(where: { $0.code == co.code }) {
                //deselect
                if self.selectedCountries[index].code == StaticKeys.countryCodeUS {
                    self.selectedCountries.remove(at: index)
                    if let stateIndex = self.selectedCountries.firstIndex(where: { $0.isState == true }) {
                        self.selectedCountries.remove(at: stateIndex)
                    }
                } else {
                    self.selectedCountries.remove(at: index)
                }
                cell.selectedItem = false
            } else {
                guard !maxCheck() else { return }
                if co.code == StaticKeys.countryCodeUS {
                    showHidePopupView(isHide: false, text: R.string.localizable.setYourStateOrTerritoryFlag())
                }
                selectedCountries.append(users[indexPath.row])
                cell.selectedItem = true
            }
        }
    }
}


extension CountryPickerViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        transitionLayoutForOldLayout fromLayout: UICollectionViewLayout,
                        newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        
        let customTransitionLayout = TransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
        
        return customTransitionLayout
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isTransitionAvailable = false
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isTransitionAvailable = true
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
}

extension CountryPickerViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchUsers = users
        } else {
            searchUsers = searchUsers.filter { return $0.name.contains(searchText) }
        }
        
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView,didSelectItemAtIndexPath indexPath: IndexPath) {
        print("Hi \(indexPath.row)")
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        view.addGestureRecognizer(tap)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        view.removeGestureRecognizer(tap)
    }
    
    @objc func handleTap() {
        view.endEditing(true)
    }
    
}
