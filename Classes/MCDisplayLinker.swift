//
//  MCDisplayLinker.swift
//  MCViewport
//
//  Created by Baglan on 2/11/16.
//  Copyright © 2016 Mobile Creators. All rights reserved.
//

import Foundation
import UIKit

class MCDisplayLinker: NSObject {
    private var displayLink: CADisplayLink?
    var callback: ((Void)->(Void))?
    
    func start() {
        stop()
        displayLink = CADisplayLink(target: self, selector: "update")
        displayLink?.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func update() {
        if let callback = callback {
            callback()
        }
    }
    
    func stop() {
        displayLink?.invalidate()
        displayLink = nil
    }
}