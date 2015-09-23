//
//  TopRoundedView.swift
//  
//
//  Created by David Ilizarov on 9/20/15.
//
//

import UIKit

class TopRoundedView: UIView {
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        var maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: UIRectCorner.TopLeft | UIRectCorner.TopRight, cornerRadii: CGSizeMake(5.0, 5.0))
        
        var maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.CGPath
        
        self.layer.mask = maskLayer
    }


}
