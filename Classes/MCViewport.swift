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
    private var _hasStopped = true
    
    var hasStopped: Bool { return _hasStopped }
    
    var contentOffset: CGPoint {
        get {
            return bounds.origin
        }
        set {
            if bounds.origin == newValue {
                _hasStopped = true
            } else {
                _hasStopped = false
                bounds.origin = newValue
            }
            
            NSLog("--- stopped: \(_hasStopped)")
            
            setNeedsLayout()
        }
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
            item.didBecomeVisible()
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