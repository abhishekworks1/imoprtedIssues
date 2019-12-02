//
//  SelectHashtagVC.swift
//  ProManager
//
//  Created by Jasmin Patel on 04/12/18.
//  Copyright © 2018 Jatin Kathrotiya. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

protocol SelectHashtagDelegate: class {
    func didSelectHashtags(_ visibleHashtags: [String], hiddenHashtags: [String])
}

class DataItem: Equatable {
    
    var id: String
    var hashString: String
    
    init(id: String, hashString: String) {
        self.id = id
        self.hashString = hashString
    }
    
    static func ==(lhs: DataItem, rhs: DataItem) -> Bool {
        return lhs.id == rhs.id
    }
    
}

class SelectHashtagCell: UICollectionViewCell {
    
    @IBOutlet weak var hashtagLabel: UILabel!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        let screenWidth = UIScreen.width
        widthConstraint.constant = screenWidth - (2 * 28)
    }
    
}

class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            
            layoutAttribute.frame.origin.x = leftMargin
            
            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        
        return attributes
    }
}

class SelectStoryHashtagVC: UIViewController {
    
    @IBOutlet weak var visibleHashtagsCollectionView: UICollectionView!
    @IBOutlet weak var hiddenHashtagsCollectionView: UICollectionView!
    
    @IBOutlet weak var parentCollectionView: UIView!
    
    weak var selectHashtagDelegate: SelectHashtagDelegate?
    
    var selectedVisibleHashtags: [String] = []
    
    var selectedHiddenHashtags: [String] = []
    
    var data: [[DataItem]] = [[], []]
    
    var draggedCard: UIImageView?
    var selectedItem: DataItem?
    
    @IBOutlet var activityIndicator: NVActivityIndicatorView! {
        didSet {
            activityIndicator.type = .ballClipRotate
            activityIndicator.color = ApplicationSettings.appPrimaryColor
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let flowLayout = hiddenHashtagsCollectionView.collectionViewLayout as? LeftAlignedCollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
        if let flowLayout = visibleHashtagsCollectionView.collectionViewLayout as? LeftAlignedCollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
        var visibleItems = [DataItem]()
        for hash in self.selectedVisibleHashtags {
            let item = DataItem.init(id: String.random(), hashString: hash)
            visibleItems.append(item)
        }
        self.data[visibleHashtagsCollectionView.tag] = visibleItems
        
        var hiddenItems = [DataItem]()
        for hash in self.selectedHiddenHashtags {
            let item = DataItem.init(id: String.random(), hashString: hash)
            hiddenItems.append(item)
        }
        self.data[hiddenHashtagsCollectionView.tag] = hiddenItems
        
        let longPressVisibleCollectionView = UILongPressGestureRecognizer(target: self, action: #selector(handleVisibleCollectionViewLongPress(_:)))
        self.visibleHashtagsCollectionView.addGestureRecognizer(longPressVisibleCollectionView)
        
        let longPressHiddenCollectionView = UILongPressGestureRecognizer(target: self, action: #selector(handleHiddenCollectionViewLongPress(_:)))
        self.hiddenHashtagsCollectionView.addGestureRecognizer(longPressHiddenCollectionView)
        
        initDraggedView()
        
        let pangesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pangesture.delegate = self
        self.parentCollectionView.addGestureRecognizer(pangesture)
    }
}

extension SelectStoryHashtagVC {
    
    @IBAction func closeButtonAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectHashsetButtonAction(_ sender: Any) {
        //        guard let vc = R.storyboard.addPost.selectHashTagViewController() else {
        //            return
        //        }
        //        vc.delegate = self
        //        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func doneButtonAction(_ sender: Any) {
        selectedVisibleHashtags.removeAll()
        for item in self.data[self.visibleHashtagsCollectionView.tag] {
            selectedVisibleHashtags.append(item.hashString)
        }
        selectedHiddenHashtags.removeAll()
        for item in self.data[self.hiddenHashtagsCollectionView.tag] {
            selectedHiddenHashtags.append(item.hashString)
        }
        selectHashtagDelegate?.didSelectHashtags(selectedVisibleHashtags,
                                                 hiddenHashtags: selectedHiddenHashtags)
        self.dismiss(animated: true, completion: nil)
    }
    
}
// MARK: Handle drag and drop
extension SelectStoryHashtagVC {
    
    func initDraggedView() {
        draggedCard = UIImageView()
        draggedCard?.isHidden = true
        if let draggedView = self.draggedCard {
            parentCollectionView.addSubview(draggedView)
        }
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let draggedCard = draggedCard,
            let selectedModel = selectedItem else {
                return
        }
        let touchPoint = gesture.location(in: parentCollectionView)
        if gesture.state == .changed && !draggedCard.isHidden {
            draggedCard.center = touchPoint
            if (!visibleHashtagsCollectionView.frame.contains(touchPoint) || !hiddenHashtagsCollectionView.frame.contains(touchPoint)) {
                draggedCard.alpha = 1.0
            } else {
                draggedCard.alpha = 0.2
            }
        } else if gesture.state == .recognized {
            draggedCard.isHidden = true
            let limitExceeded = (self.data[visibleHashtagsCollectionView.tag].count == 3)
            if visibleHashtagsCollectionView.frame.contains(touchPoint) {
                if !self.data[visibleHashtagsCollectionView.tag].contains(selectedModel) {
                    if !limitExceeded {
                        self.data[visibleHashtagsCollectionView.tag].append(selectedModel)
                        self.visibleHashtagsCollectionView.reloadData()
                        dragToVisibleCollectionView()
                    } else {
                        if let index = self.data[hiddenHashtagsCollectionView.tag].firstIndex(of: selectedModel) {
                            let indexpath = IndexPath.init(row: index, section: 0)
                            hiddenHashtagsCollectionView.cellForItem(at: indexpath)?.alpha = 1.0
                        }
                        let limitExceededAlert = UIAlertController.Style
                            .alert
                            .controller(title: "",
                                        message: "You can add maximum three hashtags.",
                                        actions: ["OK".alertAction()])
                        self.present(limitExceededAlert, animated: true, completion: nil)
                    }
                } else if let index = self.data[visibleHashtagsCollectionView.tag].firstIndex(of: selectedModel) {
                    let indexpath = IndexPath.init(row: index, section: 0)
                    visibleHashtagsCollectionView.cellForItem(at: indexpath)?.alpha = 1.0
                }
                
            } else if hiddenHashtagsCollectionView.frame.contains(touchPoint) {
                if !self.data[hiddenHashtagsCollectionView.tag].contains(selectedModel) {
                    self.data[hiddenHashtagsCollectionView.tag].append(selectedModel)
                    self.hiddenHashtagsCollectionView.reloadData()
                    dragToHiddenCollectionView()
                } else if let index = self.data[hiddenHashtagsCollectionView.tag].firstIndex(of: selectedModel) {
                    let indexpath = IndexPath.init(row: index, section: 0)
                    hiddenHashtagsCollectionView.cellForItem(at: indexpath)?.alpha = 1.0
                }
            } else {
                if let index = self.data[hiddenHashtagsCollectionView.tag].firstIndex(of: selectedModel) {
                    let indexpath = IndexPath.init(row: index, section: 0)
                    hiddenHashtagsCollectionView.cellForItem(at: indexpath)?.alpha = 1.0
                }
                if let index = self.data[visibleHashtagsCollectionView.tag].firstIndex(of: selectedModel) {
                    let indexpath = IndexPath.init(row: index, section: 0)
                    visibleHashtagsCollectionView.cellForItem(at: indexpath)?.alpha = 1.0
                }
            }
            self.selectedItem = nil
        }
    }
    
    @objc func handleVisibleCollectionViewLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
            let indexPath = visibleHashtagsCollectionView.indexPathForItem(at: gesture.location(in: visibleHashtagsCollectionView)) else {
                return
        }
        selectedItem = data[visibleHashtagsCollectionView.tag][indexPath.item]
        let point = gesture.location(in: parentCollectionView)
        draggedCard?.isHidden = false
        draggedCard?.image = visibleHashtagsCollectionView.cellForItem(at: indexPath)?.toImage()
        draggedCard?.sizeToFit()
        draggedCard?.center = point
        visibleHashtagsCollectionView.cellForItem(at: indexPath)?.alpha = 0.0
    }
    
    @objc func handleHiddenCollectionViewLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
            let indexPath = hiddenHashtagsCollectionView.indexPathForItem(at: gesture.location(in: hiddenHashtagsCollectionView)) else {
                return
        }
        selectedItem = data[hiddenHashtagsCollectionView.tag][indexPath.item]
        let point = gesture.location(in: parentCollectionView)
        draggedCard?.isHidden = false
        draggedCard?.image = hiddenHashtagsCollectionView.cellForItem(at: indexPath)?.toImage()
        draggedCard?.sizeToFit()
        draggedCard?.center = point
        hiddenHashtagsCollectionView.cellForItem(at: indexPath)?.alpha = 0.0
    }
    
    func dragToVisibleCollectionView() {
        guard let selectedModel = self.selectedItem,
            let index = data[hiddenHashtagsCollectionView.tag].firstIndex(of: selectedModel) else {
                return
        }
        let indexPath = IndexPath(item: index, section: 0)
        data[hiddenHashtagsCollectionView.tag].remove(at: index)
        hiddenHashtagsCollectionView.deleteItems(at: [indexPath])
        hiddenHashtagsCollectionView.reloadData()
    }
    
    func dragToHiddenCollectionView() {
        guard let selectedModel = self.selectedItem,
            let index = data[visibleHashtagsCollectionView.tag].firstIndex(of: selectedModel) else {
                return
        }
        let indexPath = IndexPath(item: index, section: 0)
        data[visibleHashtagsCollectionView.tag].remove(at: index)
        visibleHashtagsCollectionView.deleteItems(at: [indexPath])
        visibleHashtagsCollectionView.reloadData()
    }
    
}

extension SelectStoryHashtagVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}

extension SelectStoryHashtagVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return data[collectionView.tag].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var reuserIdentifier = R.reuseIdentifier.selectVisibleHashtagCell.identifier
        if collectionView == hiddenHashtagsCollectionView {
            reuserIdentifier = R.reuseIdentifier.selectHiddenHashtagCell.identifier
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuserIdentifier, for: indexPath) as! SelectHashtagCell
        cell.hashtagLabel.text = data[collectionView.tag][indexPath.item].hashString
        return cell
    }
    
}

extension SelectStoryHashtagVC: SelectHashSetDelegate {
    
    func setSelectedSet(hashSet: HashTagSetList, isHashSetSelected: Bool) {
        selectedHiddenHashtags.removeAll()
        for hash in (hashSet.hashTags ?? []) {
            self.selectedHiddenHashtags.append(hash)
        }
        var hiddenItems = [DataItem]()
        for hash in self.selectedHiddenHashtags {
            let item = DataItem.init(id: String.random(), hashString: hash)
            hiddenItems.append(item)
        }
        self.data[self.hiddenHashtagsCollectionView.tag] = hiddenItems
        self.hiddenHashtagsCollectionView.reloadData()
    }
    
    func noSetSelected(isSelected: Bool) { }
    
}
