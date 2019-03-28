//
//  MCViewport.swift
//  MCViewport
//
//  Created by Baglan on 1/28/16.
//
//

import Foundation
import UIKit

/// The viewport
class MCViewport: UIView {
    
    /// Tracks whether scrolling has stopped
    var hasStopped: Bool = true {
        didSet {
            if let onMovement = onMovement {
                onMovement(self)
            }
        }
    }
    
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
            
            if let onMovement = onMovement {
                onMovement(self)
            }
        }
    }
    
    /// Callback to track _contentOffset_ and _hasStopped_ changes
    var onMovement: ((_ viewport: MCViewport) -> ())?
    
    /// Helper function that updates _contentOffset_ and sets _hasStopped_ to _true_
    func jumpTo(contentOffset: CGPoint) {
        self.contentOffset = contentOffset
        hasStopped = true
    }
    
    // MARK: - Recycler
    
    /// Recycler keeps track of reusable items
    var recycler = MCRecycler()
    
    // MARK: - Pocket
    
    /// An invisible subview in which reused views are temporarily stored
    lazy var hiddenPocket: UIView = {
        let pocket = UIView()
        pocket.isHidden = true
        self.addSubview(pocket)
        return pocket
    }()
    
    // MARK: - Items
    
    /// The current items
    fileprivate var items = Set<Item>()
    
    /// The current visible items
    fileprivate var visibleItems = Set<Item>()
    
    /// Check whether the item is visible
    /// - Parameter item: The items to check
    func isItemVisible(_ item: Item) -> Bool {
        return visibleItems.contains(item)
    }
    
    /// Add an item
    /// - Parameter item: An item to add
    func addItem(_ item: Item) {
        items.insert(item)
        item.viewport = self
    }
    
    /// Remove an item
    /// - Parameter item: An item to remove
    func removeItem(_ item: Item) {
        if let index = items.firstIndex(of: item) {
            items.remove(at: index)
        }
    }
    
    /// Remove all items
    func removeAllItems() {
        items.removeAll()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let visibleArray = items.filter { (item) -> Bool in
            return self.bounds.intersects(item.frame)
        }
        let shouldBeVisible = Set<Item>(visibleArray)
        
        let newlyInvisible = visibleItems.subtracting(shouldBeVisible)
        let newlyVisible = shouldBeVisible.subtracting(visibleItems)
        
        visibleItems = shouldBeVisible
        
        for item in newlyInvisible {
            item.didBecomeInvisible()
        }
        
        for item in newlyVisible {
            item.willBecomeVisible()
        }
        
        let sorted = visibleItems.sorted { (a, b) -> Bool in
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
