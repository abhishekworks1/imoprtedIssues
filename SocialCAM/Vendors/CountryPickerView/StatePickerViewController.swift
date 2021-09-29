//
//  StatePickerViewController.swift
//  SocialCAM
//
//  Created by Nilisha Gupta on 24/09/21.
//  Copyright © 2021 Viraj Patel. All rights reserved.
//

import UIKit
import AVKit

private let animationDuration: TimeInterval = 0.3
private let listLayoutStaticCellHeight: CGFloat = 70
private let selectedGridLayoutStaticCellHeight: CGFloat = 90
private let gridLayoutStaticCellHeight: CGFloat = 115

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
    @IBOutlet fileprivate weak var lblCountryFlag: UILabel!
    @IBOutlet weak var lblPopup: UILabel!
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
    fileprivate lazy var selectedGridLayout = DisplaySwitchLayout(
        staticCellHeight: selectedGridLayoutStaticCellHeight,
        nextLayoutStaticCellHeight: listLayoutStaticCellHeight,
        layoutState: .grid
    )
    fileprivate var layoutState: LayoutState = .grid
    var isStateSelected = false
    public var onlyStates: [Country] = [Country]()
    
    // MARK: - View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        searchBar.delegate = self
        searchUsers = userStates
        layoutButton.isSelected = layoutState == .list
        setupCollectionView()
        doneButton.isEnabled = selectedStates.count > 0
    }
    
    // MARK: - Private methods
    fileprivate func setupCollectionView() {
        collectionView.collectionViewLayout = gridLayout
        collectionView.register(CountryPickerViewCell.cellNib, forCellWithReuseIdentifier: CountryPickerViewCell.id)
        selectedCollectionView.collectionViewLayout = selectedGridLayout
        selectedCollectionView.register(CountryPickerViewCell.cellNib, forCellWithReuseIdentifier: CountryPickerViewCell.id)
    }
    
    fileprivate func maxCheck() -> Bool {
        if 1 <= self.onlyStates.count {
            return true
        }
        return false
    }
    
    // MARK: - Action Methods
    @IBAction func btnBackTapped(_ sender: UIButton) {
        delegate?.statePickerView(selectedStates, isSelectionDone: false)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnLayoutTapped(_ sender: AnyObject) {
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
    
    @IBAction func donebuttonTapped(_ sender: AnyObject) {
        if let viewControllers: [UIViewController] = self.navigationController?.viewControllers {
            for vc in viewControllers {
                if vc is EditProfilePicViewController {
                    delegate?.statePickerView(selectedStates, isSelectionDone: true)
                    self.navigationController?.popToViewController(vc, animated: false)
                }
            }
        }
    }
}

// MARK: - CollectionView DataSource
extension StatePickerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CountryPickerViewCell.id,
            for: indexPath
        ) as! CountryPickerViewCell

        if collectionView == self.selectedCollectionView {
            let country = selectedStates[indexPath.row]
            cell.bind(country)
            cell.selectedItem = (selectedStates.firstIndex(of: country) != nil) ? true : false
            cell.isSelectedItem = true
            cell.setupSelectedGridLayoutConstraints(1, cellWidth: cell.frame.width)
        } else if collectionView == self.collectionView {
            if layoutState == .grid {
                cell.setupGridLayoutConstraints(1, cellWidth: cell.frame.width)
            } else {
                cell.setupListLayoutConstraints(1, cellWidth: cell.frame.width)
            }
            let country = searchUsers[indexPath.row]
            cell.bind(country)
            cell.isSelectedItem = false
            cell.selectedItem = (selectedStates.firstIndex(of: country) != nil) ? true : false
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.selectedCollectionView {
            return selectedStates.count
        }
        return searchUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == self.collectionView, let cell = collectionView.cellForItem(at: indexPath) as? CountryPickerViewCell {
            let co = searchUsers[indexPath.row]
            if let index = self.selectedStates.firstIndex(where: { $0.code == co.code }),
               let onlyStatesIndex = self.onlyStates.firstIndex(where: { $0.code == co.code }) {
                //deselect
                self.selectedStates.remove(at: index)
                self.onlyStates.remove(at: onlyStatesIndex)
                cell.selectedItem = false
            } else {
                guard !maxCheck() else {
                    guard let indexPathOfItemToDelete = collectionView.indexPathsForSelectedItems?.last else {
                        return
                    }
                    if let cell = collectionView.cellForItem(at: indexPathOfItemToDelete) as? CountryPickerViewCell {
                        cell.selectedItem = false
                        self.collectionView.reloadData()
                    }
                    self.selectedStates.removeLast()
                    self.onlyStates.removeLast()
                    self.selectedStates.append(userStates[indexPath.row])
                    self.onlyStates.append(userStates[indexPath.row])
                    cell.selectedItem = true
                    return
                }
                selectedStates.append(userStates[indexPath.row])
                onlyStates.append(userStates[indexPath.row])
                cell.selectedItem = true
            }
        }
    }
}

// MARK: - CollectionView Delegate
extension StatePickerViewController: UICollectionViewDelegate {
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

// MARK: - SearchBar Delegate
extension StatePickerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchUsers = userStates
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
