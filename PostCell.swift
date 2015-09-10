//
//  PostCell.swift
//  
//
//  Created by David Ilizarov on 9/8/15.
//
//

import UIKit
import SDWebImage
import UIActivityIndicator_for_SDWebImage

class PostCell: UITableViewCell {

    var post: Post!
    
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var timestamp: UILabel!
    @IBOutlet var repliesCount: UILabel!
    @IBOutlet var likesCount: UILabel!
    
    // This acts both as either a title or a body.
    // If a title is given, use title, otherwise body.
    @IBOutlet var postBody: UILabel!
    @IBOutlet var postTitle: UILabel!
    
    @IBOutlet var cardView: UIView!
    
    @IBOutlet var titleUpperConstraint: NSLayoutConstraint!
    @IBOutlet var bodyUpperConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.layoutIfNeeded()
    }

    func configureViews(post: Post) {
        self.post = post
        
        if (post.title == nil) {
            hideTitle()
        } else {
            showTitle()
        }
        
        var ints = [2, 11, 932, 4324, 53125, 355599, 9231343, 87654327, 827345129]
        
        var randomIndexOne = Int(arc4random_uniform(UInt32(ints.count-1)))
        var randomIndexTwo = Int(arc4random_uniform(UInt32(ints.count-1)))
        
        self.username.text = post.username

        if let title = post.title {
            self.postTitle.text = title
        }
        
        self.postBody.text = post.body
        self.timestamp.text = post.timestamp
        self.likesCount.text = ints[randomIndexOne].toThousandsString()
        self.repliesCount.text = ints[randomIndexTwo].toThousandsString()
        setupAvatarImage()
    }
    
    func setupAvatarImage() {
        if let url = post.avatarUrl {
            self.avatarImage.setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "AvatarPlaceHolder"), options: SDWebImageOptions.RetryFailed, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
                
                }, usingActivityIndicatorStyle: .Gray)
        }

    }
    
    func cardSetup() {
        self.cardView.alpha = 1.0
        self.cardView.layer.masksToBounds = false
        self.cardView.layer.cornerRadius = 5.0
    }
    
    func avatarSetup() {
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.height / 2
        self.avatarImage.layer.masksToBounds = true
        self.avatarImage.contentMode = .ScaleAspectFit
        self.avatarImage.clipsToBounds = true
    }
    
    func hideTitle() {
        self.bodyUpperConstraint.priority = 999
        self.titleUpperConstraint.priority = 500
        self.postTitle.alpha = 0.0
        self.layoutIfNeeded()
    }
    
    func showTitle() {
        self.titleUpperConstraint.priority = 999
        self.bodyUpperConstraint.priority = 500
        self.postTitle.alpha = 1.0
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.cardSetup()
        self.avatarSetup()
        self.postTitle.lineBreakMode = .ByWordWrapping
        self.postBody.lineBreakMode = .ByWordWrapping
        self.postTitle.sizeToFit()
        self.postBody.sizeToFit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.avatarImage.sd_cancelCurrentImageLoad()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
