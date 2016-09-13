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
        var originalFrame = CGRect.zero
        var parallax = CGPoint(x: 1, y: 1)
        
        lazy var hashValue: Int = { return ObjectIdentifier(Item.self).hashValue }()
        
        var zIndex: CGFloat = 0
        
        var viewport: MCViewport?
        
        var frame: CGRect {
            guard let viewport = viewport else { return originalFrame }
            var transformedFrame = originalFrame.applying(transformForContentOffset(viewport.contentOffset))
            
            for movementConstraint in movementConstraints {
                transformedFrame = movementConstraint.applyToFrame(transformedFrame, viewport: viewport)
            }
            
            return transformedFrame
        }
        
        func transformForContentOffset(_ contentOffset: CGPoint) -> CGAffineTransform {
            return CGAffineTransform(translationX: -contentOffset.x * (parallax.x - 1), y: -contentOffset.y * (parallax.y - 1))
        }
        
        func place(frame: CGRect, viewportOffset: CGPoint = CGPoint.zero, parallax: CGPoint = CGPoint(x: 1, y: 1)) {
            self.parallax = parallax
            let referenceOffset = CGPoint.zero.applying(transformForContentOffset(viewportOffset))
            originalFrame = frame.applying(CGAffineTransform(translationX: viewportOffset.x - referenceOffset.x, y: viewportOffset.y - referenceOffset.y))
        }
        
        var view: UIView? {
            return nil
        }
        
        // MARK: - Distances
        
        lazy var distances: Distances = {
            return Distances(item: self)
        }()
        
        // MARK: - Movement constraints

        fileprivate var movementConstraints = [MovementConstraint]()
        func addMovementConstraint(_ movementConstraint: MovementConstraint) {
            movementConstraints.append(movementConstraint)
            movementConstraints.sort { (a, b) -> Bool in
                a.priority < b.priority
            }
            viewport?.setNeedsLayout()
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
            guard let view = view else { return }
            view.center = CGPoint(x: frame.midX, y: frame.midY)
        }
    }
    
    class ViewItem: Item {
        fileprivate var _view: UIView?
        override var view: UIView? {
            return _view
        }
        
        
        func newView() -> UIView {
            return UIView()
        }
        
        override func willBecomeVisible() {
            guard let viewport = viewport else { return }
            
            // Create of dequeue a view
            _view = viewport.recycler.dequeue(String(describing: type(of: self))) as? UIView ?? newView()
            
            guard let view = view else { return }
            
            // Reset
            view.isHidden = false
            view.alpha = 1
            view.transform = CGAffineTransform.identity
            
            // Set bounds and zPosition
            view.frame = originalFrame
            view.layer.zPosition = zIndex
            
            // Add view to viewport
            viewport.addSubview(view)
        }
        
        override func didBecomeInvisible() {
            guard let view = view, let viewport = viewport else { return }
            
            viewport.hiddenPocket.addSubview(view)
            viewport.recycler.recycle(String(describing: type(of: self)), object: view)
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
            viewController = viewport.recycler.dequeue(String(describing: type(of: self))) as? UIViewController ?? newViewController()
            
            guard let viewController = viewController, let view = viewController.view else { return }
            
            // Reset
            view.isHidden = false
            view.alpha = 1
            view.transform = CGAffineTransform.identity
            
            // Set bounds and zPosition
            view.frame = originalFrame
            view.layer.zPosition = zIndex
            
            // Add view to viewport
            viewport.addSubview(view)
        }
        
        override func didBecomeInvisible() {
            guard let view = view, let viewController = viewController, let viewport = viewport else { return }
            
            viewport.hiddenPocket.addSubview(view)
            viewport.recycler.recycle(String(describing: type(of: self)), object: viewController)
        }
    }
}

func ==(lhs: MCViewport.Item, rhs: MCViewport.Item) -> Bool {
    return lhs === rhs
}
