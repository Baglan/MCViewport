//
//  MCButton.swift
//  MCGreatPhotoApp
//
//  Created by Baglan on 12/28/14.
//  Copyright (c) 2014 MobileCreators. All rights reserved.
//

import Foundation
import UIKit

class MCButton: UIView {
    var touchedAlpha: CGFloat = 0.6
    
    var onTouch:((button: MCButton) -> ())? = { (button: MCButton) -> Void in
        button.alpha = button.touchedAlpha
    }
    
    var onRelease:((button: MCButton) -> ())? = { (button: MCButton) -> Void in
        button.alpha = 1
    }
    
    @objc var action:((button: MCButton) -> ())? = nil
    
    internal var _touched: Bool = false
    var touched: Bool {
        get {
            return _touched
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        _touched = true
        if let callback = onTouch {
            callback(button: self)
        }
    }
    
    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        _touched = false
        if let callback = onRelease {
            callback(button: self)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        _touched = false
        if let callback = onRelease {
            callback(button: self)
        }
        if let callback = action {
            callback(button: self)
        }
    }
    
    deinit {
        onTouch = nil
        onRelease = nil
        action = nil
    }
}