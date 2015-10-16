//
//  SearchTextField.swift
//  
//
//  Created by David Ilizarov on 8/23/15.
//
//

import UIKit

class SearchTextField: UITextField {

    var tintedClearImage: UIImage?
    
    let inset: CGFloat = 10
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTintColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTintColor()
    }
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width - inset, bounds.size.height), inset, 0)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(CGRectMake(bounds.origin.x, bounds.origin.y, bounds.size.width - inset, bounds.size.height), inset, 0)
    }
    
    func setupTintColor() {
        layer.masksToBounds = false
        layer.cornerRadius = 3
        layer.shadowOffset = CGSizeMake(0, 1)
        layer.shadowRadius = 1.0
        layer.shadowOpacity = 0.25
        tintColor = UIColor(hexString: "056A85")
        backgroundColor = UIColor.whiteColor()
        textColor = UIColor.darkGrayColor()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tintClearImage()
    }
    
    private func tintClearImage() {
        for view in subviews {
            if view is UIButton {
                let button = view as! UIButton
                if let image = button.imageForState(.Highlighted) {
                    if tintedClearImage == nil {
                        tintedClearImage = tintImage(image, color: tintColor)
                    }
                    
                    button.setImage(tintedClearImage, forState: .Highlighted)
                }
            }
        }
    }
    
    func tintImage(image: UIImage, color: UIColor) -> UIImage {
        let size = image.size
        
        UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
        let context = UIGraphicsGetCurrentContext()
        
        image.drawAtPoint(CGPointZero, blendMode: .Normal, alpha: 1.0)
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextSetBlendMode(context, .SourceIn)
        CGContextSetAlpha(context, 1.0)
        
        let rect = CGRectMake(CGPointZero.x, CGPointZero.y, image.size.width, image.size.height)
        CGContextFillRect(UIGraphicsGetCurrentContext(), rect)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return tintedImage
    }
}
