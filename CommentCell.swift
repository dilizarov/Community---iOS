//
//  CommentCell.swift
//  
//
//  Created by David Ilizarov on 9/18/15.
//
//

import UIKit

class CommentCell: UITableViewCell {

    var string: String!
    var last = false
    
    @IBOutlet var commentBody: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layoutIfNeeded()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        var size: CGSize!
        
        if last { size = CGSizeMake(5.0, 5.0) }
        else { size = CGSizeMake(0.0, 0.0) }

        var maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: UIRectCorner.BottomLeft | UIRectCorner.BottomRight, cornerRadii: size)
                
        var maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.CGPath
                
        self.layer.mask = maskLayer
    }
    
    func configureViews(string: String, last: Bool) {
        self.string = string
        self.last = last
        
        commentBody.text = string
    }
    
    override func layoutSubviews() {
        self.commentBody.lineBreakMode = .ByWordWrapping
        
        self.commentBody.sizeToFit()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
