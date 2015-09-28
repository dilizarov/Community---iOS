//
//  NoPostsCell.swift
//  
//
//  Created by David Ilizarov on 9/27/15.
//
//

import UIKit

class NoPostsCell: UITableViewCell {

    @IBOutlet var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layoutIfNeeded()
    }
    
    func configureView(description: String) {
        self.descriptionLabel.text = description
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
