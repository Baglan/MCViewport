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
        scrollView.isHidden = true
        addSubview(scrollView)
        addGestureRecognizer(scrollView.panGestureRecognizer)
        addGestureRecognizer(scrollView.directionGestureRecognizer)
        scrollView.delegate = self
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        contentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        contentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
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
        fileprivate var initialContentOffset = CGPoint.zero
        
        func adjustContentOffsetForDirection(_ offset: CGPoint) -> CGPoint {
            guard let direction = direction , alternateDirectionalLockEnabled && (isTracking || isDragging || isDecelerating) else { return offset }

            switch direction {
            case .horizontal:
                return CGPoint(x: offset.x, y: initialContentOffset.y)
            case .vertical:
                return CGPoint(x: initialContentOffset.x, y: offset.y)
            }
        }
        
        lazy var directionGestureRecognizer: DirectionGestureRecognizer = {
            let recognizer = DirectionGestureRecognizer(target: self, action: #selector(ScrollView.onDirection(_:)))
            recognizer.cancelsTouchesInView = false
            recognizer.delaysTouchesBegan = true
            return recognizer
        }()
        
        func onDirection(_ recognizer: DirectionGestureRecognizer) {
            switch recognizer.state {
            case .began:
                direction = nil
                initialContentOffset = contentOffset
            case .ended:
                direction = recognizer.direction
            default:
                direction = nil
            }
        }
    }
    
    class DirectionGestureRecognizer: UIGestureRecognizer {
        enum Direction {
            case horizontal
            case vertical
        }
        
        var direction: Direction?
        
        override func reset() {
            super.reset()
            
            direction = nil
        }
        
        var initialTouchLocation: CGPoint?
        let detectionTimeInterval: TimeInterval = 0.01
        let detectionDistance: CGFloat = 5
        
        override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
            super.touchesBegan(touches, with: event)
            
            guard let touch = touches.first, let view = view else {
                state = .failed
                return
            }
            
            initialTouchLocation = touch.location(in: view)
            state = .began
        }
        
        override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
            super.touchesMoved(touches, with: event)
            
            guard let initialTouchLocation = initialTouchLocation, let touch = touches.first, let view = view else {
                state = .failed
                return
            }
            
            let currentLocation = touch.location(in: view)
            let deltaX = abs(currentLocation.x - initialTouchLocation.x)
            let deltaY = abs(currentLocation.y - initialTouchLocation.y)
            let distanceSquare = deltaX * deltaX + deltaY * deltaY
            
            if distanceSquare > detectionDistance * detectionDistance {
                direction = deltaX > deltaY ? .horizontal : .vertical
                state = .ended
            }
        }
        
        override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
            super.touchesEnded(touches, with: event)
            
            state = .failed
        }
        
        override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
            super.touchesCancelled(touches, with: event)
            
            state = .failed
        }
        
        override func canPrevent(_ preventedGestureRecognizer: UIGestureRecognizer) -> Bool {
            return false
        }
    }
}
