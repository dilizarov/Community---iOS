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
        
        let index = (i < 0 ? self.endIndex : self.startIndex)
        
        return self[index.advancedBy(i)]
    }
    
    subscript(integerRange: Range<Int>) -> String {
        let start = startIndex.advancedBy(integerRange.startIndex)
        let end = startIndex.advancedBy(integerRange.endIndex)
        let range = start..<end
        return self[range]
    }

    
    func removeEndingPunctuationAndMakeLowerCase() -> String {

        let last = self[-1]
        if (last ==  "." || last == "?" || last == "!") {
           return String(self.characters.dropLast())
        } else {
           return self.lowercaseString
        }
    }
    
    func toNSDate() -> NSDate {
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        return formatter.dateFromString(self)!
    }
    
}

extension NSDate {
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Year, fromDate: date, toDate: self, options: []).year
    }
    
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Month, fromDate: date, toDate: self, options: []).month
    }
    
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Day, fromDate: date, toDate: self, options: []).day
    }
    
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Second, fromDate: date, toDate: self, options: []).second
    }
    
    func offsetFrom(date:NSDate) -> String {
        
        if yearsFrom(date) > 0 {
            let num = yearsFrom(date)
            return num > 1 ? "\(num) years" : "1 year"
        } else if weeksFrom(date) > 0 {
            let num = weeksFrom(date)
            return num > 1 ? "\(num) weeks" : "1 week"
        } else if daysFrom(date) > 0 {
            let num = daysFrom(date)
            return num > 1 ? "\(num) days" : "1 day"
        } else if hoursFrom(date) > 0 {
            let num = hoursFrom(date)
            return num > 1 ? "\(num) hours" : "1 hour"
        } else if minutesFrom(date) > 0 {
            return "\(minutesFrom(date)) min"
        } else if secondsFrom(date) > 0 {
            return "\(secondsFrom(date)) sec"
        } else {
            return "1 sec"
        }
        
    }
    
    func minusDays(days: Int) -> NSDate {
        let dateComponents = NSDateComponents()
        dateComponents.day = -days
        return NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: self, options: [])!
        
    }
    
    func stringFromDate() -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = NSTimeZone(forSecondsFromGMT: 0)
        formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        
        return formatter.stringFromDate(self)
    }
}

extension Int {
    func toThousandsString() -> String {
        if self < 1000 {
            return "\(self)"
        } else if self < 10000 {
            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = .DecimalStyle
            return numberFormatter.stringFromNumber(self)!
        } else {
            
            let div = Double(self)/1000.0
            
            let strDiv = "\(div)"
            
            var dotIndex = -1
            
            for var i = 0; i < NSString(string: strDiv).length; i++ {
                if strDiv[i] == "." {
                    dotIndex = i
                    break
                }
            }
            
            if dotIndex == 2 {
                if strDiv[3] != "0" {
                    return "\(strDiv[0...3])k"
                } else {
                    return "\(strDiv[0...1])k"
                }
            } else {
                return "\(strDiv[0...dotIndex - 1])k"
            }
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
        
        let ctx = CGBitmapContextCreate(nil, Int(self.size.width), Int(self.size.height), CGImageGetBitsPerComponent(self.CGImage), 0, CGImageGetColorSpace(self.CGImage), CGImageGetBitmapInfo(self.CGImage).rawValue)
        
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
        let cgimg = CGBitmapContextCreateImage(ctx)
        return UIImage(CGImage: cgimg!)
    }
    
    func imageByScalingToSize(newSize: CGSize, contentMode: UIViewContentMode) -> UIImage? {
        
        if (contentMode == .ScaleToFill) {
            return self.imageByScalingToFillSize(newSize)
        } else if (contentMode == .ScaleAspectFill || contentMode == .ScaleAspectFit) {
            
            let horizontalRatio = self.size.width  / newSize.width
            let verticalRatio   = self.size.height / newSize.height
            var ratio: CGFloat
            
            if (contentMode == .ScaleAspectFill) {
                ratio = min(horizontalRatio, verticalRatio)
            } else {
                ratio = max(horizontalRatio, verticalRatio)
            }
            
            let sizeForAspectScale = CGSizeMake(self.size.width / ratio, self.size.height / ratio)
            
            var image = self.imageByScalingToFillSize(sizeForAspectScale)
            
            // if we're doing aspect fill, then the image still needs to be cropped
            if (contentMode == .ScaleAspectFill) {
                let subRect = CGRectMake(floor((sizeForAspectScale.width - newSize.width)   / 2),
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
        let imageRef = CGImageCreateWithImageInRect(self.CGImage, bounds)
        return UIImage(CGImage: imageRef!)
    }
    
    func imageByScalingToFillSize(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        self.drawInRect(CGRectMake(0, 0, newSize.width, newSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
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