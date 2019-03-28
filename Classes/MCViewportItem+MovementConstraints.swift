//
//  MCViewportItem+Constraints.swift
//  MCViewport
//
//  Created by Baglan on 2/27/16.
//  Copyright © 2016 Mobile Creators. All rights reserved.
//

import Foundation
import UIKit

extension MCViewport {
    
    /// Movement constraint
    class MovementConstraint {
        
        /// Priority
        var priority: Int = 0
        
        /// Parallax ratio
        var parallax: CGPoint = CGPoint(x: 0, y: 0)

        /// Left border
        var left: CGFloat?
        
        /// Right border
        var right: CGFloat?
        
        /// Top border
        var top: CGFloat?
        
        /// Bottom border
        var bottom: CGFloat?

        /// Calculate an affine transform for a guven content offset of the viewport
        /// - Parameter contentOffset: The content offset
        /// - Returns: An affine transform
        func transformForContentOffset(_ contentOffset: CGPoint) -> CGAffineTransform {
            return CGAffineTransform(translationX: -contentOffset.x * (parallax.x - 1), y: -contentOffset.y * (parallax.y - 1))
        }
        
        /// Place the constraint
        /// - Parameter left: The left border
        /// - Parameter top: The top border
        /// - Parameter bottom: The bottom border
        /// - Parameter right: The right border
        /// - Parameter viewportOffset: The viewport offset
        /// - Parameter parallax: The parallax ratio
        func place(left: CGFloat?, top: CGFloat?, bottom: CGFloat?, right: CGFloat?, viewportOffset: CGPoint = CGPoint(x: 0, y: 0), parallax: CGPoint = CGPoint(x: 0, y: 0)) {
            
            self.parallax = parallax
            let referenceOffset = CGPoint.zero.applying(transformForContentOffset(viewportOffset))
            
            if let left = left {
                self.left = left + viewportOffset.x - referenceOffset.x
            } else {
                self.left = nil
            }
            
            if let right = right {
                self.right = right + viewportOffset.x - referenceOffset.x
            } else {
                self.right = nil
            }
            
            if let top = top {
                self.top = top + viewportOffset.y - referenceOffset.y
            } else {
                self.top = nil
            }
            
            if let bottom = bottom {
                self.bottom = bottom + viewportOffset.y - referenceOffset.y
            } else {
                self.bottom = nil
            }
        }
        
        /// A convenience method to place a constraint with a left border
        /// - Parameter left: The left border
        /// - Parameter viewportOffset: The viewport offset
        /// - Parameter parallax: The parallax ratio
        func place(left: CGFloat, viewportOffset: CGPoint = CGPoint(x: 0, y: 0), parallax: CGPoint = CGPoint(x: 0, y: 0)) {
            place(left: left, top: nil, bottom: nil, right: nil, viewportOffset: viewportOffset, parallax: parallax)
        }
        
        /// A convenience method to place a constraint with a right border
        /// - Parameter right: The right border
        /// - Parameter viewportOffset: The viewport offset
        /// - Parameter parallax: The parallax ratio
        func place(right: CGFloat, viewportOffset: CGPoint = CGPoint(x: 0, y: 0), parallax: CGPoint = CGPoint(x: 0, y: 0)) {
            place(left: nil, top: nil, bottom: nil, right: right, viewportOffset: viewportOffset, parallax: parallax)
        }
        
        /// A convenience method to place a constraint with a top border
        /// - Parameter top: The top border
        /// - Parameter viewportOffset: The viewport offset
        /// - Parameter parallax: The parallax ratio
        func place(top: CGFloat, viewportOffset: CGPoint = CGPoint(x: 0, y: 0), parallax: CGPoint = CGPoint(x: 0, y: 0)) {
            place(left: nil, top: top, bottom: nil, right: nil, viewportOffset: viewportOffset, parallax: parallax)
        }
        
        /// A convenience method to place a constraint with a bottom border
        /// - Parameter bottom: The bottom border
        /// - Parameter viewportOffset: The viewport offset
        /// - Parameter parallax: The parallax ratio
        func place(bottom: CGFloat, viewportOffset: CGPoint = CGPoint(x: 0, y: 0), parallax: CGPoint = CGPoint(x: 0, y: 0)) {
            place(left: nil, top: nil, bottom: bottom, right: nil, viewportOffset: viewportOffset, parallax: parallax)
        }
        
        /// Apply the constraint to a given frame
        /// - Parameter frame: The frame to apply the constraint to
        /// - Parameter viewport: The parent viewport
        /// - Returns: The frame rect after the constraint has been applied
        func applyToFrame(_ frame: CGRect, viewport: MCViewport) -> CGRect {
            let transform = transformForContentOffset(viewport.contentOffset)
            var transformedFrame = frame
            
            if let left = left {
                let leftPoint = CGPoint(x: left, y: 0).applying(transform)
                if transformedFrame.origin.x < leftPoint.x {
                    transformedFrame.origin.x = leftPoint.x
                }
            }
            
            if let right = right {
                let rightPoint = CGPoint(x: right, y: 0).applying(transform)
                if transformedFrame.maxX > rightPoint.x {
                    transformedFrame.origin.x = rightPoint.x - transformedFrame.width
                }
            }
            
            if let top = top {
                let topPoint = CGPoint(x: 0, y: top).applying(transform)
                if transformedFrame.origin.y < topPoint.y {
                    transformedFrame.origin.y = topPoint.y
                }
            }
            
            if let bottom = bottom {
                let bottomPoint = CGPoint(x: 0, y: bottom).applying(transform)
                
                if transformedFrame.maxY > bottomPoint.y {
                    transformedFrame.origin.y = bottomPoint.y - transformedFrame.height
                }
            }
            
            return transformedFrame
        }
    }
}
