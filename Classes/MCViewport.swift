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
    func jumpTo(contentOffset: CGPoint) {
        self.contentOffset = contentOffset
        hasStopped = true
    }
    
    // MARK: - Recycler
    
    var recycler = MCRecycler()
    
    // MARK: - Pocket
    
    lazy var hiddenPocket: UIView = {
        let pocket = UIView()
        pocket.isHidden = true
        self.addSubview(pocket)
        return pocket
    }()
    
    // MARK: - Items
    
    fileprivate var items = Set<Item>()
    fileprivate var visibleItems = Set<Item>()
    
    func isItemVisible(_ item: Item) -> Bool {
        return visibleItems.contains(item)
    }
    
    func addItem(_ item: Item) {
        items.insert(item)
        item.viewport = self
    }
    
    func removeItem(_ item: Item) {
        if let index = items.index(of: item) {
            item.viewport = nil
            items.remove(at: index)
        }
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
                sendSubview(toBack: view)
            }
        }
        
        for item in visibleItems {
            item.update()
        }
    }
}
