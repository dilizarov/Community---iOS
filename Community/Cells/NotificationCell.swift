//
//  NotificationCell.swift
//  
//
//  Created by David Ilizarov on 10/12/15.
//
//

import UIKit
import SDWebImage
import UIActivityIndicator_for_SDWebImage

class NotificationCell: UITableViewCell {

    var notification: Notification!
    
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var notificationBody: UILabel!
    @IBOutlet var timestamp: UILabel!
    
    @IBOutlet var leadingNotificationAvatarConstraint: NSLayoutConstraint!
    @IBOutlet var leadingNotificationSuperViewConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layoutIfNeeded()
    }
    
    func configureViews(notification: Notification) {
        
        self.notification = notification
        
        self.notificationBody.attributedText = notification.displayString
        self.timestamp.text = notification.timestamp
        
        if let url = notification.avatarUrl {
            showAvatar()
            processAvatarImage(url)
        } else {
            hideAvatar()
        }
    }
    
    func processAvatarImage(url: String) {
        self.avatarImage.setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "AvatarPlaceHolder"), options: SDWebImageOptions.RetryFailed, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
            }, usingActivityIndicatorStyle: .Gray)
        
    }

    func showAvatar() {
        self.leadingNotificationAvatarConstraint.priority = 999
        self.leadingNotificationSuperViewConstraint.priority = 500
        self.avatarImage.alpha = 1.0
        self.layoutIfNeeded()
    }
    
    func hideAvatar() {
        self.leadingNotificationAvatarConstraint.priority = 500
        self.leadingNotificationSuperViewConstraint.priority = 999
        self.avatarImage.alpha = 0.0
        self.layoutIfNeeded()
    }
    
    func avatarSetup() {
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.height / 2
        self.avatarImage.layer.masksToBounds = true
        self.avatarImage.contentMode = .ScaleAspectFit
        self.avatarImage.clipsToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.avatarSetup()
        self.notificationBody.lineBreakMode = .ByWordWrapping
        self.notificationBody.sizeToFit()
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
