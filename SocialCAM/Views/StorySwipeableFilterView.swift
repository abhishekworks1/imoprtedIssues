//
//  StorySwipeableFilterView.swift
//  Camera
//
//  Created by Viraj Patel on 30/10/18.
//

import UIKit
import CoreImage

struct StoryFilter: Equatable {
    var name: String
    var ciFilter: CIFilter
    var path: String?
    
    init(name: String, ciFilter: CIFilter) {
        self.name = name
        self.ciFilter = ciFilter
    }
}

protocol StorySwipeableFilterViewDelegate: class {
    func swipeableFilterView(_ swipeableFilterView: StorySwipeableFilterView, didScrollTo filter: StoryFilter?)
}

class StorySwipeableFilterView: StoryImageView {
    /**
     The available filterGroups that this SCFilterSwitcherView shows
     If you want to show an empty filter (no processing), just add a [NSNull null]
     entry instead of an instance of SCFilterGroup
     */
    public var filters: [StoryFilter]? {
        didSet {
            updateScrollViewContentSize()
            updateCurrentSelected(true)
        }
    }
    /**
     The currently selected filter group.
     This changes when scrolling in the underlying UIScrollView.
     This value is Key-Value observable.
     */
    public var selectedFilter: StoryFilter? {
        didSet {
            setNeedsLayout()
        }
    }
    /**
     The delegate that will receive messages
     */
    weak public var delegate: StorySwipeableFilterViewDelegate?
    /**
     The underlying scrollView used for scrolling between filterGroups.
     You can freely add your views inside.
     */
     var selectFilterScrollView: UIScrollView!
    /**
     Whether the current image should be redraw with the new contentOffset
     when the UIScrollView is scrolled. If disabled, scrolling will never
     show up the other filters, until it receives a new CIImage.
     On some device it seems better to disable it when the StorySwipeableFilterView
     is set inside a StoryPlayer.
     Default is YES
     */
    var refreshAutomaticallyWhenScrolling = false
            
    override init(frame: CGRect) {
        super.init(frame: frame)
        _swipeableCommonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _swipeableCommonInit()
    }
    
    func _swipeableCommonInit() {
        refreshAutomaticallyWhenScrolling = true
        selectFilterScrollView = UIScrollView(frame: bounds)
        selectFilterScrollView.delegate = self
        selectFilterScrollView.isPagingEnabled = true
        selectFilterScrollView.showsHorizontalScrollIndicator = false
        selectFilterScrollView.showsVerticalScrollIndicator = false
        selectFilterScrollView.bounces = true
        selectFilterScrollView.alwaysBounceHorizontal = true
        selectFilterScrollView.alwaysBounceVertical = true
        selectFilterScrollView.backgroundColor = .clear
        addSubview(selectFilterScrollView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        selectFilterScrollView.frame = bounds
        updateScrollViewContentSize()
    }
    
    func updateScrollViewContentSize() {
        guard let filters = self.filters else { return }
        selectFilterScrollView.contentSize = CGSize(width: CGFloat(filters.count) * frame.size.width * 3,
                                                    height: frame.size.height)
        if let selectedFilter = self.selectedFilter {
            scroll(to: selectedFilter, animated: false)
        }
    }
    /**
     Scrolls to a specific filter
     */
    func scroll(to filter: StoryFilter, animated: Bool) {
        guard let filters = self.filters,
            let index = filters.firstIndex(of: filter) else { return }
        if index >= 0 {
            let contentOffset = CGPoint(x: selectFilterScrollView.contentSize.width / 3 + (selectFilterScrollView.frame.size.width * CGFloat(index)), y: 0)
            selectFilterScrollView.setContentOffset(contentOffset, animated: animated)
            updateCurrentSelected(false)
        }
    }
    
    func updateCurrentSelected(_ shouldNotify: Bool) {
        guard let filters = self.filters else { return }
        let filterGroupsCount = filters.count
        let selectedIndex = Int((selectFilterScrollView.contentOffset.x + selectFilterScrollView.frame.size.width / 2) / selectFilterScrollView.frame.size.width) % filterGroupsCount
        var newFilterGroup: StoryFilter?
        
        if selectedIndex >= 0 && selectedIndex < filterGroupsCount {
            newFilterGroup = filters[selectedIndex]
        }
        
        if selectedFilter != newFilterGroup {
            self.selectedFilter = newFilterGroup
            if shouldNotify {
                if let delegate = self.delegate {
                    delegate.swipeableFilterView(self, didScrollTo: newFilterGroup)
                }
            }
        }
    }
    
    override func renderedCIImage(in rect: CGRect) -> CIImage? {
        let image = super.renderedCIImage(in: rect)
        
        let contentSize = selectFilterScrollView.frame.size
        guard contentSize.width != 0,
            let filters = self.filters else {
            return image
        }
        
        let ratio: CGFloat = selectFilterScrollView.contentOffset.x / contentSize.width
        
        var index = Int(ratio)
        let upIndex = Int(ceilf(Float(ratio)))
        let remainingRatio = ratio - CGFloat(index)

        let extent = image?.extent
        var xImage: CGFloat = (extent?.size.width ?? 0.0) * -remainingRatio
        var outputImage = CIImage(color: CIColor(red: 0, green: 0, blue: 0))
        
        while index <= upIndex {
            let currentIndex: Int = index % filters.count
            let filter = filters[currentIndex]
            if filter.name != "" && filter.ciFilter.name != "CIFilter" {
                filter.ciFilter.setValue(image, forKey: kCIInputImageKey)
            }
            var filteredImage = filter.ciFilter.value(forKey: kCIOutputImageKey) as? CIImage
            
            if filteredImage == nil {
                filteredImage = image
            }
            
            filteredImage = filteredImage?.cropped(to: CGRect(x: (extent?.origin.x ?? 0.0) + xImage, y: extent?.origin.y ?? 0.0, width: extent?.size.width ?? 0.0, height: extent?.size.height ?? 0.0))
            if let anImage = filteredImage?.composited(over: outputImage) {
                outputImage = anImage
            }
            xImage += extent?.size.width ?? 0.0
            index += 1
        }
        outputImage = outputImage.cropped(to: extent ?? CGRect.zero)
        
        return outputImage
    }
    
}

extension StorySwipeableFilterView: UIScrollViewDelegate {
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        updateCurrentSelected(true)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        updateCurrentSelected(true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCurrentSelected(true)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateCurrentSelected(true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let filters = self.filters else { return }
        let width: CGFloat = scrollView.frame.size.width
        let contentOffsetX: CGFloat = scrollView.contentOffset.x
        let contentSizeWidth: CGFloat = scrollView.contentSize.width
        let normalWidth: CGFloat = CGFloat(filters.count) * width
        
        if width > 0 && contentSizeWidth > 0 {
            if contentOffsetX <= 0 {
                scrollView.contentOffset = CGPoint(x: contentOffsetX + normalWidth, y: scrollView.contentOffset.y)
            } else if contentOffsetX + width >= contentSizeWidth {
                scrollView.contentOffset = CGPoint(x: contentOffsetX - normalWidth, y: scrollView.contentOffset.y)
            }
        }
        
        if refreshAutomaticallyWhenScrolling {
            setNeedsDisplay()
        }
    }

}
