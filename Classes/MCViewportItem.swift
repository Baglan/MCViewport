//
//  MCViewportItem.swift
//  MCViewport
//
//  Created by Baglan on 2/11/16.
//  Copyright © 2016 Mobile Creators. All rights reserved.
//

import Foundation
import UIKit



extension MCViewport {
    class Item: Hashable {
        var originalFrame = CGRectZero
        var parallax = CGPointMake(1, 1)
        
        lazy var hashValue: Int = { return ObjectIdentifier(Item).hashValue }()
        
        var zIndex: CGFloat = 0
        
        var viewport: MCViewport?
        
        var frame: CGRect {
            guard let viewport = viewport else { return originalFrame }
            return CGRectApplyAffineTransform(originalFrame, transformForContentOffset(viewport.contentOffset))
        }
        
        func transformForContentOffset(contentOffset: CGPoint) -> CGAffineTransform {
            return CGAffineTransformMakeTranslation(-contentOffset.x * (parallax.x - 1), -contentOffset.y * (parallax.y - 1))
        }
        
        func place(frame frame: CGRect, viewportOffset: CGPoint = CGPointZero, parallax: CGPoint = CGPointMake(1, 1)) {
            self.parallax = parallax
            let referenceOffset = CGPointApplyAffineTransform(CGPointZero, transformForContentOffset(viewportOffset))
            originalFrame = CGRectApplyAffineTransform(frame, CGAffineTransformMakeTranslation(viewportOffset.x - referenceOffset.x, viewportOffset.y - referenceOffset.y))
        }
        
        var view: UIView? {
            return nil
        }
        
        // MARK: - Visibility
        
        var isVisible: Bool {
            if let viewport = viewport {
                return viewport.isItemVisible(self)
            }
            return false
        }
        
        func willBecomeVisible() {
            
        }
        
        func didBecomeInvisible() {
            
        }
        
        // MARK: - Updates
        
        func update() {
            guard let viewport = viewport, let view = view else { return }
            view.center =  CGPointApplyAffineTransform(originalFrame.center, transformForContentOffset(viewport.contentOffset))
        }
    }
    
    class ViewItem: Item {
        private var _view: UIView?
        override var view: UIView? {
            return _view
        }
        
        
        func newView() -> UIView {
            return UIView()
        }
        
        override func willBecomeVisible() {
            guard let viewport = viewport else { return }
            
            // Create of dequeue a view
            _view = viewport.recycler.dequeue(String(self.dynamicType)) as? UIView ?? newView()
            
            guard let view = view else { return }
            
            // Reset
            view.hidden = false
            view.alpha = 1
            view.transform = CGAffineTransformIdentity
            
            // Set bounds and zPosition
            view.frame = originalFrame
            view.layer.zPosition = zIndex
            
            // Add view to viewport
            viewport.addSubview(view)
        }
        
        override func didBecomeInvisible() {
            guard let view = view, let viewport = viewport else { return }
            
            viewport.hiddenPocket.addSubview(view)
            viewport.recycler.recycle(String(self.dynamicType), object: view)
        }
    }
    

    
    class ViewControllerItem: Item {
        var viewController: UIViewController?
        
        override var view: UIView? {
            return viewController?.view
        }
        
        func newViewController() -> UIViewController? {
            return nil
        }
        
        override func willBecomeVisible() {
            guard let viewport = viewport else { return }
            
            // Create of dequeue a view controller
            viewController = viewport.recycler.dequeue(String(self.dynamicType)) as? UIViewController ?? newViewController()
            
            guard let viewController = viewController, let view = viewController.view else { return }
            
            // Reset
            view.hidden = false
            view.alpha = 1
            view.transform = CGAffineTransformIdentity
            
            // Set bounds and zPosition
            view.frame = originalFrame
            view.layer.zPosition = zIndex
            
            // Add view to viewport
            viewport.addSubview(view)
        }
        
        override func didBecomeInvisible() {
            guard let view = view, let viewport = viewport else { return }
            
            viewport.hiddenPocket.addSubview(view)
            viewport.recycler.recycle(String(self.dynamicType), object: view)
        }
    }
}

func ==(lhs: MCViewport.Item, rhs: MCViewport.Item) -> Bool {
    return lhs === rhs
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: CGRectGetMidX(self), y: CGRectGetMidY(self))
    }
}