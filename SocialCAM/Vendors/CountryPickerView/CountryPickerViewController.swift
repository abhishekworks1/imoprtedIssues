//
//  CountryPickerViewController.swift
//  CountryPickerView
//
//  Created by Kizito Nwose on 18/09/2017.
//  Copyright © 2017 Kizito Nwose. All rights reserved.
//

import UIKit
import AVKit

public protocol CountryPickerViewDelegate: class {
    /// Called when the user selects a country from the list.
    func countryPickerView(_ didSelectCountry : [Country])
}

class CountryPickerViewController: UIViewController {
    
    @IBOutlet weak var selectedCollectionView: UICollectionView!
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
    public var selectedCountries: [Country] = [] {
        didSet {
            if selectedCollectionView != nil {
                selectedCollectionView.isHidden = selectedCountries.count <= 0
                selectedCollectionView.reloadData()
            }
        }
    }
    fileprivate var searchUsers = [Country]()
    public let users: [Country] = {
        var countries = [Country]()
        let bundle = Bundle.main
        guard let jsonPath = bundle.path(forResource: "CountryCodes", ofType: "json"), let jsonData = try? Data(contentsOf: URL(fileURLWithPath: jsonPath)) else {
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
    
    private var layoutOption: LayoutOption = .grid {
        didSet {
            setupLayout(with: view.bounds.size)
        }
    }
    
    private func setupLayout(with containerSize: CGSize) {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        switch layoutOption {
        case .list:
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            flowLayout.sectionInset = UIEdgeInsets(top: 8.0, left: 0, bottom: 8.0, right: 0)
            
            if traitCollection.horizontalSizeClass == .regular {
                let minItemWidth: CGFloat = 300
                let numberOfCell = containerSize.width / minItemWidth
                let width = floor((numberOfCell / floor(numberOfCell)) * minItemWidth)
                flowLayout.itemSize = CGSize(width: width, height: 90)
            } else {
                flowLayout.itemSize = CGSize(width: containerSize.width, height: 70)
            }
            
        case .grid:
            let minItemWidth: CGFloat = 106
            let numberOfCell = containerSize.width / minItemWidth
            let width = floor((numberOfCell / floor(numberOfCell)) * minItemWidth)
            
            flowLayout.minimumInteritemSpacing = 0
            flowLayout.minimumLineSpacing = 0
            flowLayout.itemSize = CGSize(width: width, height: 90.0)
            flowLayout.sectionInset = .zero
        }
        
        guard let selectedCollectionViewFlowLayout = selectedCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        let minItemWidth: CGFloat = 106
        let numberOfCell = containerSize.width / minItemWidth
        let width = floor((numberOfCell / floor(numberOfCell)) * minItemWidth)
       
        selectedCollectionViewFlowLayout.minimumInteritemSpacing = 0
        selectedCollectionViewFlowLayout.minimumLineSpacing = 0
        selectedCollectionViewFlowLayout.itemSize = CGSize(width: width, height: 90.0)
        selectedCollectionViewFlowLayout.sectionInset = .zero
        collectionView.reloadData()
        selectedCollectionView.reloadData()
    }
    
    private lazy var storyCameraVC = StoryCameraViewController()
    var isClearFlagSelected = false
    public var onlyCountries: [Country] = [Country]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        searchBar.delegate = self
        setupCollectionView()
        searchUsers = users
        layoutButton.isSelected = layoutOption == .list
        if selectedCollectionView != nil {
            selectedCollectionView.isHidden = selectedCountries.count <= 0
            selectedCollectionView.reloadData()
        }
        for (_, item) in selectedCountries.enumerated() {
            if let _ = self.searchUsers.firstIndex(where: { $0.code == item.code }) {
                self.onlyCountries.append(item)
            }
        }
        setupLayout(with: view.bounds.size)
        selectedCollectionView.reloadData()
    }
    
    // MARK: - Private methods
    fileprivate func setupCollectionView() {
        collectionView.register(R.nib.flagLayoutListCollectionViewCell(), forCellWithReuseIdentifier: R.reuseIdentifier.flagLayoutListCollectionViewCell.identifier)
        collectionView.register(R.nib.flagLayoutGridCollectionViewCell(), forCellWithReuseIdentifier: R.reuseIdentifier.flagLayoutGridCollectionViewCell.identifier)
        selectedCollectionView.register(R.nib.flagLayoutGridCollectionViewCell(), forCellWithReuseIdentifier: R.reuseIdentifier.flagLayoutGridCollectionViewCell.identifier)
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
        layoutOption = layoutOption == .list ? .grid : .list
        layoutButton.isSelected = layoutOption == .list
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
        let countryCount = onlyCountries.filter({$0.isState != true})
        if 2 <= countryCount.count {
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
    
    func rearrangeFlags(countrys: [Country]) -> [Country] {
        var countryAry = countrys
        if let index = countryAry.firstIndex(where: { $0.code == StaticKeys.countryCodeUS }) {
            let element = countryAry[index]
            if countryAry.count == 3 {
                if let stateIndex = countryAry.firstIndex(where: { $0.isState == true }) {
                    let stateElement = countryAry[stateIndex]
                    countryAry.remove(at: stateIndex)
                    countryAry.insert(stateElement, at: 2)
                }
                countryAry.remove(at: index)
                countryAry.insert(element, at: 1)
            } else if countryAry.count == 2 {
                countryAry.remove(at: index)
                countryAry.insert(element, at: 1)
            }
        }
        return countryAry
    }
    
    func setCountrys(_ countrys: [Country]) {
        var arrayCountry: [[String: Any]] = []
        for country in countrys {
            let material: [String: Any] = [
                StaticKeys.state: country.isState ? country.name : "",
                StaticKeys.stateCode: country.isState ? country.code : "",
                StaticKeys.country: country.isState ? StaticKeys.countryNameUS : country.name,
                StaticKeys.countryCode: country.isState ? StaticKeys.countryCodeUS: country.code
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
    
    func getSelectStates(_ selectedStates: [Country], isSelectionDone: Bool) {
        self.selectedCountries = selectedStates
        if isSelectionDone {
            self.delegate?.countryPickerView(selectedCountries)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
}

extension CountryPickerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.flagLayoutGridCollectionViewCell.identifier, for: indexPath) as? FlagLayoutGridCollectionViewCell else {
            return UICollectionViewCell()
        }
        var country = searchUsers[indexPath.row]
        if collectionView == self.selectedCollectionView {
            country = selectedCountries[indexPath.row]
        } else {
            switch layoutOption {
            case .grid:
                break
            case .list:
                guard let listCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.flagLayoutListCollectionViewCell.identifier, for: indexPath) as? FlagLayoutListCollectionViewCell else {
                    return UICollectionViewCell()
                }
                listCell.setup(with: country)
                listCell.selectedItem = (selectedCountries.firstIndex(of: country) != nil) ? true : false
                return listCell
            }
        }
        cell.setup(with: country)
        cell.selectedItem = (selectedCountries.firstIndex(of: country) != nil) ? true : false
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.selectedCollectionView {
            return selectedCountries.count
        }
        return searchUsers.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView {
            let co = searchUsers[indexPath.row]
            if let index = self.selectedCountries.firstIndex(where: { $0.code == co.code && $0.name == co.name }),
               let onlyCountryIndex = self.onlyCountries.firstIndex(where: { $0.code == co.code && $0.name == co.name }) {
                //deselect
                if self.selectedCountries[index].code == StaticKeys.countryCodeUS {
                    self.selectedCountries.remove(at: index)
                    self.onlyCountries.remove(at: onlyCountryIndex)
                    if let stateIndex = self.selectedCountries.firstIndex(where: { $0.isState == true }) {
                        self.selectedCountries.remove(at: stateIndex)
                    }
                } else {
                    self.selectedCountries.remove(at: index)
                    self.onlyCountries.remove(at: onlyCountryIndex)
                }
                if let cell = collectionView.cellForItem(at: indexPath) as? FlagLayoutGridCollectionViewCell {
                    cell.selectedItem = false
                } else if let cell = collectionView.cellForItem(at: indexPath) as? FlagLayoutListCollectionViewCell {
                    cell.selectedItem = false
                }
            } else {
                guard !maxCheck() else {
                    if co.code == StaticKeys.countryCodeUS {
                        showHidePopupView(isHide: false, text: R.string.localizable.setYourStateOrTerritoryFlag())
                    }
                    self.selectedCountries.append(searchUsers[indexPath.row])
                    self.onlyCountries.append(searchUsers[indexPath.row])
                    if let cell = collectionView.cellForItem(at: indexPath) as? FlagLayoutGridCollectionViewCell {
                        cell.selectedItem = true
                    } else if let cell = collectionView.cellForItem(at: indexPath) as? FlagLayoutListCollectionViewCell {
                        cell.selectedItem = true
                    }
                    guard let indexPathOfItemToDelete = collectionView.indexPathsForSelectedItems?.last else {
                        return
                    }
                    if let cell = collectionView.cellForItem(at: indexPathOfItemToDelete) as? FlagLayoutGridCollectionViewCell {
                        cell.selectedItem = false
                        self.collectionView.reloadData()
                    } else if let cell = collectionView.cellForItem(at: indexPathOfItemToDelete) as? FlagLayoutListCollectionViewCell {
                        cell.selectedItem = false
                        self.collectionView.reloadData()
                    }
                    if self.selectedCountries.first?.code == StaticKeys.countryCodeUS {
                        if let stateIndex = self.selectedCountries.firstIndex(where: { $0.isState == true }) {
                            self.selectedCountries.remove(at: stateIndex)
                        }
                    }
                    self.selectedCountries.removeFirst()
                    self.onlyCountries.removeFirst()
                    self.selectedCountries = rearrangeFlags(countrys: selectedCountries)
                    self.onlyCountries = rearrangeFlags(countrys: onlyCountries)
                    return
                }
                if co.code == StaticKeys.countryCodeUS {
                    showHidePopupView(isHide: false, text: R.string.localizable.setYourStateOrTerritoryFlag())
                }
                selectedCountries.append(searchUsers[indexPath.row])
                onlyCountries.append(searchUsers[indexPath.row])
                self.selectedCountries = rearrangeFlags(countrys: selectedCountries)
                self.onlyCountries = rearrangeFlags(countrys: onlyCountries)
                if let cell = collectionView.cellForItem(at: indexPath) as? FlagLayoutGridCollectionViewCell {
                    cell.selectedItem = true
                } else if let cell = collectionView.cellForItem(at: indexPath) as? FlagLayoutListCollectionViewCell {
                    cell.selectedItem = true
                }
            }
        } else if collectionView == self.selectedCollectionView {
            let co = selectedCountries[indexPath.row]
            if let index = self.selectedCountries.firstIndex(where: { $0.code == co.code }),
               let onlyCountryIndex = self.onlyCountries.firstIndex(where: { $0.code == co.code }) {
                //deselect
                if self.selectedCountries[index].code == StaticKeys.countryCodeUS {
                    self.selectedCountries.remove(at: index)
                    self.onlyCountries.remove(at: onlyCountryIndex)
                    if let stateIndex = self.selectedCountries.firstIndex(where: { $0.isState == true }) {
                        self.selectedCountries.remove(at: stateIndex)
                    }
                } else {
                    self.selectedCountries.remove(at: index)
                    self.onlyCountries.remove(at: onlyCountryIndex)
                }
                if let cell = collectionView.cellForItem(at: indexPath) as? FlagLayoutGridCollectionViewCell {
                    cell.selectedItem = false
                } else if let cell = collectionView.cellForItem(at: indexPath) as? FlagLayoutListCollectionViewCell {
                    cell.selectedItem = false
                }
                self.collectionView.reloadData()
            }
        }
    }
}


extension CountryPickerViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
    
}

extension CountryPickerViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchUsers = users
        } else {
            searchUsers = users.filter { return $0.name.lowercased().contains(searchText.lowercased()) }
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
