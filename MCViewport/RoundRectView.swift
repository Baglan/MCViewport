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
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let boundsRect = CGRect(x: strokeWidth / 2, y: strokeWidth / 2, width: bounds.width - strokeWidth, height: bounds.height - strokeWidth)
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
