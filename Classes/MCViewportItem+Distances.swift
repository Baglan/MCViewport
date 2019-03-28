//
//  MCViewportItem+Distances.swift
//  MCViewport
//
//  Created by Baglan on 2/27/16.
//  Copyright © 2016 Mobile Creators. All rights reserved.
//

import Foundation
import UIKit

extension MCViewport {
    
    /// Distances from an item to various edges
    class Distances {
        
        /// The item
        fileprivate unowned let item: Item
        
        /// Distance to the left edge of the viewport
        var left: CGFloat {
            guard let viewport = item.viewport else { return 0 }
            return item.frame.origin.x - viewport.contentOffset.x
        }
        
        /// Distance to the right edge of the viewport
        var right: CGFloat {
            guard let viewport = item.viewport else { return 0 }
            return viewport.bounds.width - (left + item.frame.width)
        }
        
        /// Distance to the top edge of the viewport
        var top: CGFloat {
            guard let viewport = item.viewport else { return 0 }
            return item.frame.origin.y - viewport.contentOffset.y
        }
        
        /// Distance to the bottom edge of the viewport
        var bottom: CGFloat {
            guard let viewport = item.viewport else { return 0 }
            return viewport.bounds.height - (top + item.frame.height)
        }
        
        /// Distance to the center of the viewport
        var center: CGPoint {
            guard let viewport = item.viewport else { return CGPoint.zero }
            let viewportSize = viewport.bounds.size
            let itemFrame = item.frame
            return CGPoint(x: left + itemFrame.width / 2 - viewportSize.width / 2, y: top + itemFrame.height / 2 - viewportSize.height / 2)
        }
        
        /// Initialize with an item
        /// - Parameter item: The item
        init(item: Item) {
            self.item = item
        }
    }
}
