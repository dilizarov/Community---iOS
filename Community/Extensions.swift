//
//  Extensions.swift
//  Community
//
//  Created by David Ilizarov on 8/24/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import Foundation
import UIKit

extension String {
    
    static func validateEmail(candidate: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluateWithObject(candidate)
    }
    
    func strip() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    subscript (i: Int) -> Character {
        
        var index = (i < 0 ? self.endIndex : self.startIndex)
        
        return self[advance(index, i)]
    }
    
    subscript(integerRange: Range<Int>) -> String {
        let start = advance(startIndex, integerRange.startIndex)
        let end = advance(startIndex, integerRange.endIndex)
        let range = start..<end
        return self[range]
    }

    
    func removeEndingPunctuationAndMakeLowerCase() -> String {

        var last = self[-1]
        
        if (last ==  "." || last == "?" || last == "!") {
           return dropLast(self.lowercaseString)
        } else {
           return self.lowercaseString
        }
    }
    
}

extension UIImage {
    
    func useThumbnailOrientation() -> UIImage {
        
        // No-op if the orientation is already correct
        if (self.imageOrientation == UIImageOrientation.Up) { return self; }
        
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransformIdentity
        
        switch (self.imageOrientation)
        {
        case .Down, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
            break;
        case .Left, .LeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0)
            transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
            break;
            
        case .Right, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, CGFloat(-M_PI_2));
            break;
            
        case .Up, .UpMirrored:
            break;
        }
        
        switch (self.imageOrientation) {
        case .UpMirrored, .DownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case .LeftMirrored, .RightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case .Up, .Down, .Left, .Right:
            break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        
        var ctx = CGBitmapContextCreate(nil, Int(self.size.width), Int(self.size.height), CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage))
        
        CGContextConcatCTM(ctx, transform);
        switch (self.imageOrientation) {
        case .Left, .LeftMirrored, .Right, .RightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.height, self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, self.size.width, self.size.height), self.CGImage);
            break;
        }
        
        // And now we just create a new UIImage from the drawing context
        var cgimg = CGBitmapContextCreateImage(ctx)
        return UIImage(CGImage: cgimg)!
    }
    
    func imageByScalingToSize(newSize: CGSize, contentMode: UIViewContentMode) -> UIImage? {
        
        if (contentMode == .ScaleToFill) {
            return self.imageByScalingToFillSize(newSize)
        } else if (contentMode == .ScaleAspectFill || contentMode == .ScaleAspectFit) {
            
            var horizontalRatio = self.size.width  / newSize.width
            var verticalRatio   = self.size.height / newSize.height
            var ratio: CGFloat
            
            if (contentMode == .ScaleAspectFill) {
                ratio = min(horizontalRatio, verticalRatio)
            } else {
                ratio = max(horizontalRatio, verticalRatio)
            }
            
            var sizeForAspectScale = CGSizeMake(self.size.width / ratio, self.size.height / ratio)
            
            var image = self.imageByScalingToFillSize(sizeForAspectScale)
            
            // if we're doing aspect fill, then the image still needs to be cropped
            if (contentMode == .ScaleAspectFill) {
                var subRect = CGRectMake(floor((sizeForAspectScale.width - newSize.width)   / 2),
                                         floor((sizeForAspectScale.height - newSize.height) / 2),
                                         newSize.width,
                                         newSize.height)
                
                image = image.imageByCroppingToBounds(subRect)
            }
            
            return image
        }
        
        return nil
    }
    
    func imageByCroppingToBounds(bounds: CGRect) -> UIImage {
        var imageRef = CGImageCreateWithImageInRect(self.CGImage, bounds)
        return UIImage(CGImage: imageRef)!
    }
    
    func imageByScalingToFillSize(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        var image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func imageByScalingAspectFillSize(newSize: CGSize) -> UIImage {
        return imageByScalingToSize(newSize, contentMode: .ScaleAspectFill)!
    }
    
    func imageByScalingAspectFitSize(newSize: CGSize) -> UIImage {
        return imageByScalingToSize(newSize, contentMode: .ScaleAspectFit)!
    }
}