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
    
    /// The general inmlementation of a viewport item
    class Item: Hashable {
        
        /// Reference to the viewport
        weak var viewport: MCViewport?
        
        /// The original frame of the item
        ///
        /// Position calculations will be based on it
        var originalFrame = CGRect.zero
        
        /// The parallax ratio of the item in the XY coordinate space
        var parallax = CGPoint(x: 1, y: 1)

        /// Item z-index for stacking
        var zIndex: CGFloat = 0
        
        /// The current calculated frame
        var frame: CGRect {
            guard let viewport = viewport else { return originalFrame }
            var transformedFrame = originalFrame.applying(transformForContentOffset(viewport.contentOffset))
            
            for movementConstraint in movementConstraints {
                transformedFrame = movementConstraint.applyToFrame(transformedFrame, viewport: viewport)
            }
            
            return transformedFrame
        }
        
        /// Calculate the affine transform for a given content offset of the viewport
        /// - Parameter contentOffset: The content offset of the viewport to calculate for
        /// - Returns: The affine transform
        func transformForContentOffset(_ contentOffset: CGPoint) -> CGAffineTransform {
            return CGAffineTransform(translationX: -contentOffset.x * (parallax.x - 1), y: -contentOffset.y * (parallax.y - 1))
        }
        
        /// Position the item in the viewport
        /// - Parameter frame: The frame rect of the item
        /// - Parameter viewportOffset: Offset of the viewport for which the frame is set
        /// - Parameter parallax: The parallax ratio of the item
        func place(frame: CGRect, viewportOffset: CGPoint = CGPoint.zero, parallax: CGPoint = CGPoint(x: 1, y: 1)) {
            self.parallax = parallax
            let referenceOffset = CGPoint.zero.applying(transformForContentOffset(viewportOffset))
            originalFrame = frame.applying(CGAffineTransform(translationX: viewportOffset.x - referenceOffset.x, y: viewportOffset.y - referenceOffset.y))
        }
        
        /// The associated view, if any
        var view: UIView? {
            return nil
        }
        
        // MARK: - Distances
        
        /// Distances to viewport
        lazy var distances: Distances = {
            return Distances(item: self)
        }()
        
        // MARK: - Movement constraints

        /// The current movement constraints
        fileprivate var movementConstraints = [MovementConstraint]()
        
        /// Add a movement constraint
        func addMovementConstraint(_ movementConstraint: MovementConstraint) {
            movementConstraints.append(movementConstraint)
            movementConstraints.sort { (a, b) -> Bool in
                a.priority < b.priority
            }
            viewport?.setNeedsLayout()
        }
        
        // MARK: - Visibility
        
        /// Whether the item is currently visible on the screen
        var isVisible: Bool {
            if let viewport = viewport {
                return viewport.isItemVisible(self)
            }
            return false
        }
        
        /// Hook just before the item appears on the screen
        func willBecomeVisible() {
            
        }
        
        /// Hook right after the item leaves the screen
        func didBecomeInvisible() {
            
        }
        
        // MARK: - Updates
        
        /// Update the item position
        func update() {
            guard let view = view else { return }
            view.center = CGPoint(x: frame.midX, y: frame.midY)
        }
        
        // MARK: - Hashable compliance
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(ObjectIdentifier(Item.self).hashValue)
        }
    }
    
    /// An item based on a UIView
    class ViewItem: Item {
        
        /// The associated view
        fileprivate var _view: UIView?
        
        override var view: UIView? {
            return _view
        }
        
        /// Create a new view
        ///
        /// To be implemented by descendants; the default implmenetation returns a simlpe UIView.
        ///
        /// - Returns: a new view
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
    
    /// An item based on a UIViewController
    class ViewControllerItem: Item {
        
        /// The associated view controller, if any
        var viewController: UIViewController?
        
        override var view: UIView? {
            return viewController?.view
        }
        
        /// Create a new view controller
        ///
        /// To beimplemented by descendants; the default implementation returns nil
        ///
        /// - Returns: A new view controller or nil
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

/// Check if items are the same
func ==(lhs: MCViewport.Item, rhs: MCViewport.Item) -> Bool {
    return lhs === rhs
}
