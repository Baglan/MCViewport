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
    class Distances {
        private let item: Item
        
        var left: CGFloat {
            guard let viewport = item.viewport else { return 0 }
            return item.frame.origin.x - viewport.contentOffset.x
        }
        
        var right: CGFloat {
            guard let viewport = item.viewport else { return 0 }
            return viewport.bounds.width - (left + item.frame.width)
        }
        
        var top: CGFloat {
            guard let viewport = item.viewport else { return 0 }
            return item.frame.origin.y - viewport.contentOffset.y
        }
        
        var bottom: CGFloat {
            guard let viewport = item.viewport else { return 0 }
            return viewport.bounds.height - (top + item.frame.height)
        }
        
        var center: CGPoint {
            guard let viewport = item.viewport else { return CGPointZero }
            let viewportSize = viewport.bounds.size
            let itemFrame = item.frame
            return CGPoint(x: left + itemFrame.width / 2 - viewportSize.width / 2, y: top + itemFrame.height / 2 - viewportSize.height / 2)
        }
        
        init(item: Item) {
            self.item = item
        }
    }
}