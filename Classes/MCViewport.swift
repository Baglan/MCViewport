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
    
    struct Transformation {
        var translation: CGPoint
        var rotation: CGFloat
        var scale: CGFloat
        
        var transform: CGAffineTransform {
            var tr = CGAffineTransformMakeTranslation(translation.x, translation.y)
            tr = CGAffineTransformRotate(tr, rotation)
            tr = CGAffineTransformScale(tr, scale, scale)
            return tr
        }
        
        func transform(parallax: CGPoint) -> CGAffineTransform {
            var tr = CGAffineTransformMakeTranslation(translation.x * parallax.x, translation.y * parallax.y)
            tr = CGAffineTransformRotate(tr, rotation)
            tr = CGAffineTransformScale(tr, scale, scale)
            return tr
        }
    }
    
    var contentTransformation = Transformation(translation: CGPointZero, rotation: 0, scale: 1)
    
    private var _previousContentTransformation: Transformation! = nil
    
    private var _hasStopped: Bool = false
    var hasStopped: Bool {
        return _hasStopped
    }
    func update() {
        if _previousContentTransformation == nil || _previousContentTransformation != contentTransformation {
            _previousContentTransformation = contentTransformation
            _hasStopped = false
        } else {
            _hasStopped = true
        }
        setNeedsLayout()
    }
    
    // MARK: - Display
    let displayLinker = MCDisplayLinker()
    
    func activate() {
        displayLinker.callback = { _ in
            self.setNeedsLayout()
        }
        displayLinker.start()
    }
    
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

func ==(lhs: MCViewport.Transformation, rhs: MCViewport.Transformation) -> Bool {
    return lhs.translation == rhs.translation && lhs.rotation == rhs.rotation && lhs.scale == rhs.scale
}

func !=(lhs: MCViewport.Transformation, rhs: MCViewport.Transformation) -> Bool {
    return !(lhs == rhs)
}