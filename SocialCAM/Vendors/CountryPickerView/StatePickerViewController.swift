//
//  StatePickerViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 24/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit
import AVKit

public protocol StatePickerViewDelegate: class {
    /// Called when the user selects a country from the list.
    func statePickerView(_ didSelectCountry : [Country], isSelectionDone: Bool)
}

class StatePickerViewController: UIViewController {
    
    // MARK: - Outlets Declaration
    @IBOutlet weak var selectedCollectionView: UICollectionView!
    @IBOutlet fileprivate weak var collectionView: UICollectionView!
    @IBOutlet fileprivate weak var searchBar: UISearchBar!
    @IBOutlet fileprivate weak var doneButton: UIButton!
    @IBOutlet fileprivate weak var layoutButton: UIButton!
    @IBOutlet weak var btnDoNotShowAgain: UIButton!
    @IBOutlet weak var popupView: UIView!
    
    // MARK: - Variable Declarations
    public weak var delegate: StatePickerViewDelegate?
    fileprivate var tap: UITapGestureRecognizer!
    public var selectedStates: [Country] = [] {
        didSet {
            if selectedCollectionView != nil {
                selectedCollectionView.isHidden = selectedStates.count <= 0
                selectedCollectionView.reloadData()
            }
        }
    }
    fileprivate var searchUsers = [Country]()
    public let userStates: [Country] = {
        var countries = [Country]()
        let bundle = Bundle.main
        guard let jsonPath = bundle.path(forResource: "StateCodes", ofType: "json"),
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
                      let code = countryObj["code"] as? String else {
                    continue
                }
                
                let country = Country(name: name, code: code, phoneCode: "", isState: true)
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
    
    var isStateSelected = false
    public var onlyStates: [Country] = [Country]()
    
    // MARK: - View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        searchBar.delegate = self
        searchUsers = userStates
        layoutButton.isSelected = layoutOption == .list
        setupCollectionView()
        doneButton.isEnabled = selectedStates.count > 0
        setupLayout(with: view.bounds.size)
        if selectedCollectionView != nil {
            selectedCollectionView.isHidden = selectedStates.count <= 0
            selectedCollectionView.reloadData()
        }
    }
    
    // MARK: - Private methods
    fileprivate func setupCollectionView() {
        collectionView.register(R.nib.flagLayoutListCollectionViewCell(), forCellWithReuseIdentifier: R.reuseIdentifier.flagLayoutListCollectionViewCell.identifier)
        collectionView.register(R.nib.flagLayoutGridCollectionViewCell(), forCellWithReuseIdentifier: R.reuseIdentifier.flagLayoutGridCollectionViewCell.identifier)
        selectedCollectionView.register(R.nib.flagLayoutGridCollectionViewCell(), forCellWithReuseIdentifier: R.reuseIdentifier.flagLayoutGridCollectionViewCell.identifier)
    }
    
    fileprivate func maxCheck() -> Bool {
        if 1 <= self.onlyStates.count {
            return true
        }
        return false
    }
    
    // MARK: - Action Methods
    @IBAction func btnBackTapped(_ sender: UIButton) {
        if isStateSelected && Defaults.shared.isShowAllPopUpChecked {
            showHidePopupView(isHide: false)
        } else {
            delegate?.statePickerView(selectedStates, isSelectionDone: false)
            navigationController?.popViewController(animated: true)
        }
    }
    
    private func showHidePopupView(isHide: Bool) {
        self.popupView.isHidden = isHide
    }
    
    @IBAction func btnDoNotShowAgainClicked(_ sender: UIButton) {
        btnDoNotShowAgain.isSelected = !btnDoNotShowAgain.isSelected
        Defaults.shared.isShowAllPopUpChecked = !btnDoNotShowAgain.isSelected
    }
    
    @IBAction func btnPopupYesTapped(_ sender: UIButton) {
        self.showHidePopupView(isHide: true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPopupNoTapped(_ sender: UIButton) {
        self.showHidePopupView(isHide: true)
    }
    
    @IBAction func btnLayoutTapped(_ sender: AnyObject) {
        layoutOption = layoutOption == .list ? .grid : .list
        layoutButton.isSelected = layoutOption == .list
    }
    
    @IBAction func donebuttonTapped(_ sender: AnyObject) {
        delegate?.statePickerView(selectedStates, isSelectionDone: false)
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - CollectionView DataSource
extension StatePickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.flagLayoutGridCollectionViewCell.identifier, for: indexPath) as? FlagLayoutGridCollectionViewCell else {
            return UICollectionViewCell()
        }
        var country = searchUsers[indexPath.row]
        if collectionView == self.selectedCollectionView {
            country = selectedStates[indexPath.row]
            cell.selectedItem = (selectedStates.firstIndex(of: country) != nil) ? true : false
        } else {
            switch layoutOption {
            case .grid:
                cell.selectedItem = (selectedStates.firstIndex(where: { $0.code == country.code && $0.name == country.name }) != nil) ? true : false
            case .list:
                guard let listCell = collectionView.dequeueReusableCell(withReuseIdentifier: R.reuseIdentifier.flagLayoutListCollectionViewCell.identifier, for: indexPath) as? FlagLayoutListCollectionViewCell else {
                    return UICollectionViewCell()
                }
                listCell.setup(with: country)
                cell.selectedItem = (selectedStates.firstIndex(where: { $0.code == country.code && $0.name == country.name }) != nil) ? true : false
                return listCell
            }
        }
        cell.setup(with: country)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.selectedCollectionView {
            return selectedStates.count
        }
        return searchUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        isStateSelected = true
        if collectionView == self.collectionView {
            let co = searchUsers[indexPath.row]
            if let index = self.selectedStates.firstIndex(where: { $0.code == co.code && $0.name == co.name }),
               let onlyStatesIndex = self.onlyStates.firstIndex(where: { $0.code == co.code && $0.name == co.name }) {
                //deselect
                self.selectedStates.remove(at: index)
                self.onlyStates.remove(at: onlyStatesIndex)
                if let cell = collectionView.cellForItem(at: indexPath) as? FlagLayoutGridCollectionViewCell {
                    cell.selectedItem = false
                } else if let cell = collectionView.cellForItem(at: indexPath) as? FlagLayoutListCollectionViewCell {
                    cell.selectedItem = false
                }
            } else {
                guard !maxCheck() else {
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
                    self.selectedStates.removeLast()
                    self.onlyStates.removeLast()
                    self.selectedStates.append(searchUsers[indexPath.row])
                    self.onlyStates.append(searchUsers[indexPath.row])
                    if let cell = collectionView.cellForItem(at: indexPath) as? FlagLayoutGridCollectionViewCell {
                        cell.selectedItem = true
                    } else if let cell = collectionView.cellForItem(at: indexPath) as? FlagLayoutListCollectionViewCell {
                        cell.selectedItem = true
                    }
                    return
                }
                selectedStates.append(searchUsers[indexPath.row])
                onlyStates.append(searchUsers[indexPath.row])
                if let cell = collectionView.cellForItem(at: indexPath) as? FlagLayoutGridCollectionViewCell {
                    cell.selectedItem = true
                } else if let cell = collectionView.cellForItem(at: indexPath) as? FlagLayoutListCollectionViewCell {
                    cell.selectedItem = true
                }
            }
        } else if collectionView == self.selectedCollectionView {
            let co = selectedStates[indexPath.row]
            if let index = self.selectedStates.firstIndex(where: { $0.code == co.code }),
               let onlyStatesIndex = self.onlyStates.firstIndex(where: { $0.code == co.code }) {
                //deselect
                self.selectedStates.remove(at: index)
                self.onlyStates.remove(at: onlyStatesIndex)
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

// MARK: - CollectionView Delegate
extension StatePickerViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

// MARK: - SearchBar Delegate
extension StatePickerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchUsers = userStates
        } else {
            searchUsers = userStates.filter { return $0.name.lowercased().contains(searchText.lowercased()) }
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
