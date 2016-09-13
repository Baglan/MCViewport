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
    
    var onTouch:((_ button: MCButton) -> ())? = { (button: MCButton) -> Void in
        button.alpha = button.touchedAlpha
    }
    
    var onRelease:((_ button: MCButton) -> ())? = { (button: MCButton) -> Void in
        button.alpha = 1
    }
    
    @objc var action:((_ button: MCButton) -> ())? = nil
    
    internal var _touched: Bool = false
    var touched: Bool {
        get {
            return _touched
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _touched = true
        if let callback = onTouch {
            callback(self)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        _touched = false
        if let callback = onRelease {
            callback(self)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        _touched = false
        if let callback = onRelease {
            callback(self)
        }
        if let callback = action {
            callback(self)
        }
    }
    
    deinit {
        onTouch = nil
        onRelease = nil
        action = nil
    }
}
