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
            if let viewport = viewport {
                return CGRectApplyAffineTransform(originalFrame, viewport.contentTransformation.transform(parallax))
            }
            return originalFrame
        }
        
        func place(frame frame: CGRect, viewportOffset: CGPoint = CGPointZero, parallax: CGPoint = CGPointMake(1, 1)) {
            self.parallax = parallax
            let offsetTransform = CGAffineTransformMakeTranslation(viewportOffset.x, viewportOffset.y)
            let invertedTransform = CGAffineTransformInvert(offsetTransform)
            originalFrame = CGRectApplyAffineTransform(frame, invertedTransform)
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
        
        func didBecomeVisible() {
            
        }
        
        func didBecomeInvisible() {
            
        }
        
        // MARK: - Updates
        
        func update() {
            
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
        
        override func didBecomeVisible() {
            guard let viewport = viewport else { return }
            
            // Create of dequeue a view
            _view = MCRecycler.sharedInstance.dequeue(String(self.dynamicType)) as? UIView ?? newView()
            
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
            guard let view = view else { return }
            
            MCRecycler.sharedInstance.recycle(String(self.dynamicType), object: view)
            view.removeFromSuperview()
        }
        
        override func update() {
            guard let viewport = viewport, let view = view else { return }
            
            view.transform = viewport.contentTransformation.transform(parallax)
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
        
        override func didBecomeVisible() {
            guard let viewport = viewport else { return }
            
            // Create of dequeue a view controller
            viewController = MCRecycler.sharedInstance.dequeue(String(self.dynamicType)) as? UIViewController ?? newViewController()
            
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
            guard let view = view else { return }
            
            MCRecycler.sharedInstance.recycle(String(self.dynamicType), object: view)
            view.removeFromSuperview()
        }
        
        override func update() {
            guard let viewport = viewport, let view = view else { return }
            
            view.transform = viewport.contentTransformation.transform(parallax)
        }
    }
}

func ==(lhs: MCViewport.Item, rhs: MCViewport.Item) -> Bool {
    return lhs === rhs
}