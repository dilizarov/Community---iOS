//
//  NoRepliesCell.swift
//  
//
//  Created by David Ilizarov on 9/26/15.
//
//

import UIKit

class NoRepliesCell: UITableViewCell {

    @IBOutlet var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutIfNeeded()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        var maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: UIRectCorner.BottomLeft | UIRectCorner.BottomRight, cornerRadii: CGSizeMake(5.0, 5.0))
        
        var maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.CGPath
        
        self.layer.mask = maskLayer
    }
    
    func configureView(description: String) {
        self.descriptionLabel.text = description
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
