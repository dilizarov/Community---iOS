//
//  Extensions.swift
//  Community
//
//  Created by David Ilizarov on 8/24/15.
//  Copyright (c) 2015 David Ilizarov. All rights reserved.
//

import Foundation

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