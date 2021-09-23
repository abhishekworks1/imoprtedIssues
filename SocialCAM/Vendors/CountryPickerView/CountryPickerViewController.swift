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
    public weak var delegate: CountryPickerViewDelegate?
    
    fileprivate var tap: UITapGestureRecognizer!
    public var selectedCountries: [Country] = [Country](){
        didSet{
            doneButton.isEnabled = self.selectedCountries.count > 0
        }
    }
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
                
                let country = Country(name: name, code: code, phoneCode: phoneCode)
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
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        searchBar.delegate = self
        searchUsers = users
        layoutButton.isSelected = layoutState == .list
        setupCollectionView()
        doneButton.isEnabled = selectedCountries.count > 0
    }
    
    // MARK: - Private methods
    fileprivate func setupCollectionView() {
        collectionView.collectionViewLayout = gridLayout
        collectionView.register(CountryPickerViewCell.cellNib, forCellWithReuseIdentifier: CountryPickerViewCell.id)
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
        delegate?.countryPickerView(selectedCountries)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func tapRecognized() {
        view.endEditing(true)
    }
    
    fileprivate func maxCheck() -> Bool {
        if 3 <= self.selectedCountries.count {
            DispatchQueue.runOnMainThread {
                Utils.appDelegate?.window?.makeToast(R.string.localizable.youCanSelectMaximum3Country())
            }
            return true
        }
        return false
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
                self.selectedCountries.remove(at: index)
                cell.selectedItem = false
            } else {
                guard !maxCheck() else { return }
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
