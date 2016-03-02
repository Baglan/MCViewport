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
    class MovementConstraint {
        var priority: Int = 0
        var parallax: CGPoint = CGPoint(x: 0, y: 0)

        var left: CGFloat?
        var right: CGFloat?
        var top: CGFloat?
        var bottom: CGFloat?

        func transformForContentOffset(contentOffset: CGPoint) -> CGAffineTransform {
            return CGAffineTransformMakeTranslation(-contentOffset.x * (parallax.x - 1), -contentOffset.y * (parallax.y - 1))
        }
        
        func place(left left: CGFloat?, top: CGFloat?, bottom: CGFloat?, right: CGFloat?, viewportOffset: CGPoint = CGPoint(x: 0, y: 0), parallax: CGPoint = CGPoint(x: 0, y: 0)) {
            
            self.parallax = parallax
            let referenceOffset = CGPointApplyAffineTransform(CGPointZero, transformForContentOffset(viewportOffset))
            
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
        
        func place(left left: CGFloat, viewportOffset: CGPoint = CGPoint(x: 0, y: 0), parallax: CGPoint = CGPoint(x: 0, y: 0)) {
            place(left: left, top: nil, bottom: nil, right: nil, viewportOffset: viewportOffset, parallax: parallax)
        }
        
        func place(right right: CGFloat, viewportOffset: CGPoint = CGPoint(x: 0, y: 0), parallax: CGPoint = CGPoint(x: 0, y: 0)) {
            place(left: nil, top: nil, bottom: nil, right: right, viewportOffset: viewportOffset, parallax: parallax)
        }
        
        func place(top top: CGFloat, viewportOffset: CGPoint = CGPoint(x: 0, y: 0), parallax: CGPoint = CGPoint(x: 0, y: 0)) {
            place(left: nil, top: top, bottom: nil, right: nil, viewportOffset: viewportOffset, parallax: parallax)
        }
        
        func place(bottom bottom: CGFloat, viewportOffset: CGPoint = CGPoint(x: 0, y: 0), parallax: CGPoint = CGPoint(x: 0, y: 0)) {
            place(left: nil, top: nil, bottom: bottom, right: nil, viewportOffset: viewportOffset, parallax: parallax)
        }
        
        func applyToFrame(frame: CGRect, viewport: MCViewport) -> CGRect {
            let transform = transformForContentOffset(viewport.contentOffset)
            var transformedFrame = frame
            
            if let left = left {
                let leftPoint = CGPointApplyAffineTransform(CGPoint(x: left, y: 0), transform)
                if transformedFrame.origin.x < leftPoint.x {
                    transformedFrame.origin.x = leftPoint.x
                }
            }
            
            if let right = right {
                let rightPoint = CGPointApplyAffineTransform(CGPoint(x: right, y: 0), transform)
                if CGRectGetMaxX(transformedFrame) > rightPoint.x {
                    transformedFrame.origin.x = rightPoint.x - transformedFrame.width
                }
            }
            
            if let top = top {
                let topPoint = CGPointApplyAffineTransform(CGPoint(x: 0, y: top), transform)
                if transformedFrame.origin.y < topPoint.y {
                    transformedFrame.origin.y = topPoint.y
                }
            }
            
            if let bottom = bottom {
                let bottomPoint = CGPointApplyAffineTransform(CGPoint(x: 0, y: bottom), transform)
                
                if CGRectGetMaxY(transformedFrame) > bottomPoint.y {
                    transformedFrame.origin.y = bottomPoint.y - transformedFrame.width
                }
            }
            
            return transformedFrame
        }
    }
}
