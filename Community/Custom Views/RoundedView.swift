//
//  RoundedView.swift
//  
//
//  Created by David Ilizarov on 9/20/15.
//
//

import UIKit

class RoundedView: UIView {
    
    var cornerRadiiSize: CGFloat?
    var cornersMask: UIRectCorner?
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if cornerRadiiSize == nil {
            cornerRadiiSize = 5.0
        }
        
        if cornersMask == nil {
            cornersMask = UIRectCorner.AllCorners
        }
        
        var maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: cornersMask!, cornerRadii: CGSizeMake(cornerRadiiSize!, cornerRadiiSize!))
        
        var maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.CGPath
        
        self.layer.mask = maskLayer
    }

}
