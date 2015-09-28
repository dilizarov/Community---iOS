//
//  SearchTextField.swift
//  
//
//  Created by David Ilizarov on 8/23/15.
//
//

import UIKit

class SearchTextField: UITextField {

    let inset: CGFloat = 10
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, inset, 0)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, inset, 0)
    }
}
