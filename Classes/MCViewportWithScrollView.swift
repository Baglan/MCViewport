//
//  MCViewportWithScrollView.swift
//  MCViewport
//
//  Created by Baglan on 2/19/16.
//  Copyright © 2016 Mobile Creators. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

class MCViewportWithScrollView: MCViewport, UIScrollViewDelegate {
    var scrollView: MCViewport.ScrollView!
    
    func setupScrollView() {
        scrollView = MCViewport.ScrollView(frame: frame)
        scrollView.hidden = true
        addSubview(scrollView)
        addGestureRecognizer(scrollView.panGestureRecognizer)
        addGestureRecognizer(scrollView.directionGestureRecognizer)
        scrollView.delegate = self
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        bounds.origin = scrollView.contentOffset
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupScrollView()
    }
}

extension MCViewport {
    class ScrollView: UIScrollView {
        override var contentOffset: CGPoint {
            get { return super.contentOffset }
            set { super.contentOffset = adjustContentOffsetForDirection(newValue) }
        }
        
        // MARK: - Direction lock
        
        var direction: DirectionGestureRecognizer.Direction?
        private var initialContentOffset = CGPointZero
        
        func adjustContentOffsetForDirection(offset: CGPoint) -> CGPoint {
            guard let direction = direction where directionalLockEnabled && (tracking || dragging || decelerating) else { return offset }
            
            switch direction {
            case .Horizontal:
                return CGPoint(x: offset.x, y: initialContentOffset.y)
            case .Vertical:
                return CGPoint(x: initialContentOffset.x, y: offset.y)
            }
        }
        
        lazy var directionGestureRecognizer: DirectionGestureRecognizer = {
            let recognizer = DirectionGestureRecognizer(target: self, action: "onDirection:")
            recognizer.cancelsTouchesInView = false
            return recognizer
        }()
        
        func onDirection(recognizer: DirectionGestureRecognizer) {
            switch recognizer.state {
            case .Began:
                direction = nil
                initialContentOffset = contentOffset
            case .Ended:
                direction = recognizer.direction
            default:
                direction = nil
            }
        }
    }
    
    class DirectionGestureRecognizer: UIGestureRecognizer {
        enum Direction {
            case Horizontal
            case Vertical
        }
        
        var direction: Direction?
        
        override func reset() {
            super.reset()
            
            direction = nil
        }
        
        override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
            super.touchesBegan(touches, withEvent: event)
            
            state = .Began
        }
        
        override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
            super.touchesMoved(touches, withEvent: event)
            
            if let touch = touches.first, let view = view {
                let previousLocation = touch.previousLocationInView(view)
                let currentLocation = touch.locationInView(view)
                let deltaX = abs(currentLocation.x - previousLocation.x)
                let deltaY = abs(currentLocation.y - previousLocation.y)
                direction = deltaX > deltaY ? .Horizontal : .Vertical
                state = .Ended
            }
        }
        
        override func canPreventGestureRecognizer(preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
            return false
        }
    }
}