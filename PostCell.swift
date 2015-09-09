//
//  PostCell.swift
//  
//
//  Created by David Ilizarov on 9/8/15.
//
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    @IBOutlet var cardView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureViews(text: String) {
        self.label.text = text
    }
    
    func cardSetup() {
        self.cardView.alpha = 1.0
        self.cardView.layer.masksToBounds = false
        self.cardView.layer.cornerRadius = 5.0
    }
    
    override func layoutSubviews() {
        self.cardSetup()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
