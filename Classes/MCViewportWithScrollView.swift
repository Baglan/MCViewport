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
        contentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        contentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        contentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            contentOffset = scrollView.contentOffset
        }
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
        
        var adjustedContentOffset: CGPoint {
            return adjustContentOffsetForDirection(contentOffset)
        }
        
        // MARK: - Direction lock
        var alternateDirectionalLockEnabled = false
        var direction: DirectionGestureRecognizer.Direction?
        private var initialContentOffset = CGPointZero
        
        func adjustContentOffsetForDirection(offset: CGPoint) -> CGPoint {
            guard let direction = direction where alternateDirectionalLockEnabled && (tracking || dragging || decelerating) else { return offset }

            switch direction {
            case .Horizontal:
                return CGPoint(x: offset.x, y: initialContentOffset.y)
            case .Vertical:
                return CGPoint(x: initialContentOffset.x, y: offset.y)
            }
        }
        
        lazy var directionGestureRecognizer: DirectionGestureRecognizer = {
            let recognizer = DirectionGestureRecognizer(target: self, action: #selector(ScrollView.onDirection(_:)))
            recognizer.cancelsTouchesInView = false
            recognizer.delaysTouchesBegan = true
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
        
        var initialTouchLocation: CGPoint?
        let detectionTimeInterval: NSTimeInterval = 0.01
        let detectionDistance: CGFloat = 5
        
        override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
            super.touchesBegan(touches, withEvent: event)
            
            guard let touch = touches.first, let view = view else {
                state = .Failed
                return
            }
            
            initialTouchLocation = touch.locationInView(view)
            state = .Began
        }
        
        override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
            super.touchesMoved(touches, withEvent: event)
            
            guard let initialTouchLocation = initialTouchLocation, let touch = touches.first, let view = view else {
                state = .Failed
                return
            }
            
            let currentLocation = touch.locationInView(view)
            let deltaX = abs(currentLocation.x - initialTouchLocation.x)
            let deltaY = abs(currentLocation.y - initialTouchLocation.y)
            let distanceSquare = deltaX * deltaX + deltaY * deltaY
            
            if distanceSquare > detectionDistance * detectionDistance {
                direction = deltaX > deltaY ? .Horizontal : .Vertical
                state = .Ended
            }
        }
        
        override func canPreventGestureRecognizer(preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
            return false
        }
    }
}