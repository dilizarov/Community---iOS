//
//  ReplyCell.swift
//  
//
//  Created by David Ilizarov on 9/18/15.
//
//

import UIKit
import SDWebImage
import UIActivityIndicator_for_SDWebImage
import Alamofire
import TTTAttributedLabel

class ReplyCell: UITableViewCell, TTTAttributedLabelDelegate {

    var reply: Reply!
    var last = false
    
    var delegate: PresentControllerDelegate!
    
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var timestamp: UILabel!
    @IBOutlet var likesCount: UILabel!
    
    @IBOutlet var likeImage: UIImageView!
    
    @IBOutlet var likeClickSpace: UIView!
    @IBOutlet var replyBody: TTTAttributedLabel!
    
    @IBOutlet var leadingUsernameSuperViewConstraint: NSLayoutConstraint!
    @IBOutlet var leadingUsernameAvatarConstraint: NSLayoutConstraint!
    @IBOutlet var leadingReplySuperViewConstraint: NSLayoutConstraint!
    @IBOutlet var leadingReplyAvatarConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layoutIfNeeded()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        var size: CGSize!
        
        if last { size = CGSizeMake(5.0, 5.0) }
        else { size = CGSizeMake(0.0, 0.0) }

        let maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: [.BottomLeft, .BottomRight], cornerRadii: size)
                
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.CGPath
                
        self.layer.mask = maskLayer
    }
    
    func configureViews(reply: Reply, last: Bool) {
        replyBody.enabledTextCheckingTypes = NSTextCheckingType.Link.rawValue// | NSTextCheckingType.PhoneNumber.rawValue
        
        replyBody.linkAttributes = [kCTForegroundColorAttributeName : UIColor.blueColor()]
        replyBody.activeLinkAttributes = [kCTForegroundColorAttributeName : UIColor.darkGrayColor()]
        replyBody.delegate = self
        
        self.reply = reply
        self.last = last
        
        if let url = reply.avatarUrl {
            showAvatar()
            processAvatarImage(url)
        } else {
            hideAvatar()
        }
        
        self.username.text = reply.username
        self.replyBody.text = reply.body
        self.timestamp.text = reply.timestamp
        self.likesCount.text = reply.likeCount.toThousandsString()
    
        if reply.liked {
            likeImage.image = UIImage(named: "Liked")
        } else {
            likeImage.image = UIImage(named: "Like")
        }
        
        setupLikeGesture()
    }
    
//    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithPhoneNumber phoneNumber: String!) {
//        
//        var alertSheet = UIAlertController(title: phoneNumber, message: nil, preferredStyle: .ActionSheet)
//        var cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
//        var callNumber = UIAlertAction(title: "Make a Phone Call", style: .Default, handler: { alert in
//            var phoneURLString = NSURL(string: "tel://\(phoneNumber)")
//            
//            UIApplication.sharedApplication().openURL(phoneURLString!)
//        })
//        
//        alertSheet.addAction(cancelButton)
//        alertSheet.addAction(callNumber)
//        
//        self.delegate.presentController(alertSheet)
//        
//    }
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
       
        let alertSheet = UIAlertController(title: url.absoluteString, message: nil, preferredStyle: .ActionSheet)
        let cancelButton = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        let openInSafariButton = UIAlertAction(title: "Open Link in Safari", style: .Default, handler: { alert in
            UIApplication.sharedApplication().openURL(url)
        })
        
        alertSheet.addAction(cancelButton)
        alertSheet.addAction(openInSafariButton)
        
        self.delegate.presentController(alertSheet)
    }
    
    func processAvatarImage(url: String) {
        self.avatarImage.setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "AvatarPlaceHolder"), options: SDWebImageOptions.RetryFailed, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
            
            }, usingActivityIndicatorStyle: .Gray)
    }
    
    func setupLikeGesture() {
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("processLike"))
        singleTap.numberOfTapsRequired = 1
        likeClickSpace.addGestureRecognizer(singleTap)
    }
    
    func processLike() {
        toggleLike()
        
        Alamofire.request(Router.LikeReply(reply_id: reply.id, dislike: !reply.liked))
            .responseJSON { request, response, result in
                
                if ((response == nil || response?.statusCode > 299) && result.error != nil) { self.toggleLike() }
        }
    }
    
    func toggleLike() {
        if reply.liked {
            reply.liked = false
            reply.likeCount -= 1
            likeImage.image = UIImage(named: "Like")
        } else {
            reply.liked = true
            reply.likeCount += 1
            likeImage.image = UIImage(named: "Liked")
        }
        
        self.likesCount.text = reply.likeCount.toThousandsString()
    }

    
    func avatarSetup() {
        self.avatarImage.layer.cornerRadius = self.avatarImage.frame.size.height / 2
        self.avatarImage.layer.masksToBounds = true
        self.avatarImage.contentMode = .ScaleAspectFit
        self.avatarImage.clipsToBounds = true
    }
    
    func showAvatar() {
        self.leadingReplyAvatarConstraint.priority = 999
        self.leadingReplySuperViewConstraint.priority = 500
        self.leadingUsernameAvatarConstraint.priority = 999
        self.leadingUsernameSuperViewConstraint.priority = 500
        self.avatarImage.alpha = 1.0
        self.layoutIfNeeded()
    }
    
    func hideAvatar() {
        self.leadingReplyAvatarConstraint.priority = 500
        self.leadingReplySuperViewConstraint.priority = 999
        self.leadingUsernameAvatarConstraint.priority = 500
        self.leadingUsernameSuperViewConstraint.priority = 999
        self.avatarImage.alpha = 0.0
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.avatarSetup()
        
        self.replyBody.lineBreakMode = .ByWordWrapping
        self.replyBody.sizeToFit()
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
