//
//  MCViewport.swift
//  MCViewport
//
//  Created by Baglan on 1/28/16.
//
//

import Foundation
import UIKit

class MCViewport: UIView {
    /// Tracks whether scrolling has stopped
    var hasStopped = true
    
    /// Tracks content offset and updates *hasStopped*
    var contentOffset: CGPoint {
        get {
            return bounds.origin
        }
        set {
            if bounds.origin == newValue {
                hasStopped = true
            } else {
                hasStopped = false
                bounds.origin = newValue
            }
            
            setNeedsLayout()
        }
    }
    
    /// Helper function that updates _contentOffset_ and sets _hasStopped_ to _true_
    func jumpTo(contentOffset contentOffset: CGPoint) {
        self.contentOffset = contentOffset
        hasStopped = true
    }
    
    // MARK: - Recycler
    
    var recycler = MCRecycler()
    
    // MARK: - Pocket
    
    lazy var hiddenPocket: UIView = {
        let pocket = UIView()
        pocket.hidden = true
        self.addSubview(pocket)
        return pocket
    }()
    
    // MARK: - Items
    
    private var items = Set<Item>()
    private var visibleItems = Set<Item>()
    
    func isItemVisible(item: Item) -> Bool {
        return visibleItems.contains(item)
    }
    
    func addItem(item: Item) {
        items.insert(item)
        item.viewport = self
    }
    
    func removeItem(item: Item) {
        if let index = items.indexOf(item) {
            item.viewport = nil
            items.removeAtIndex(index)
        }
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let visibleArray = items.filter { (item) -> Bool in
            return CGRectIntersectsRect(self.bounds, item.frame)
        }
        let shouldBeVisible = Set<Item>(visibleArray)
        
        let newlyInvisible = visibleItems.subtract(shouldBeVisible)
        let newlyVisible = shouldBeVisible.subtract(visibleItems)
        
        visibleItems = shouldBeVisible
        
        for item in newlyInvisible {
            item.didBecomeInvisible()
        }
        
        for item in newlyVisible {
            item.willBecomeVisible()
        }
        
        let sorted = visibleItems.sort { (a, b) -> Bool in
            a.zIndex > b.zIndex
        }
        
        for item in sorted {
            if let view = item.view {
                sendSubviewToBack(view)
            }
        }
        
        for item in visibleItems {
            item.update()
        }
    }
}