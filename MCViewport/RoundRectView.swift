//
//  RoundRectView.swift
//  Coffee
//
//  Created by Baglan on 11/8/15.
//
//

import Foundation
import UIKit

@IBDesignable class RoundRectView: UIView {
    @IBInspectable var strokeWidth: CGFloat = 1 { didSet { setNeedsDisplay() } }
    @IBInspectable var strokeColor: UIColor? { didSet { setNeedsDisplay() } }
    
    @IBInspectable var filled: Bool = false { didSet { setNeedsDisplay() } }
    @IBInspectable var fillColor: UIColor? { didSet { setNeedsDisplay() } }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let boundsRect = CGRectMake(strokeWidth / 2, strokeWidth / 2, bounds.width - strokeWidth, bounds.height - strokeWidth)
        let path = UIBezierPath(roundedRect: boundsRect, cornerRadius: boundsRect.height)
        
        if filled, let fillColor = fillColor {
            fillColor.setFill()
            path.fill()
        }
        
        if let color = strokeColor {
            color.setStroke()
            path.stroke()
        }
        
    }
}