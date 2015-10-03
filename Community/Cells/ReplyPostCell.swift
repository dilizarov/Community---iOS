import UIKit
import SDWebImage
import UIActivityIndicator_for_SDWebImage
import Alamofire

class ReplyPostCell: UITableViewCell {
    
    var post: Post!
    
    @IBOutlet var avatarImage: UIImageView!
    @IBOutlet var username: UILabel!
    @IBOutlet var timestamp: UILabel!
    @IBOutlet var likesCount: UILabel!

    @IBOutlet var likeImage: UIImageView!
    @IBOutlet var likeClickSpace: UIView!
    
    @IBOutlet var postBody: UILabel!
    @IBOutlet var postTitle: UILabel!
    
    @IBOutlet var titleUpperConstraint: NSLayoutConstraint!
    @IBOutlet var bodyUpperConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layoutIfNeeded()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        var maskPath = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: UIRectCorner.TopLeft | UIRectCorner.TopRight, cornerRadii: CGSizeMake(5.0, 5.0))
        
        var maskLayer = CAShapeLayer()
        maskLayer.frame = self.bounds
        maskLayer.path = maskPath.CGPath
        
        self.layer.mask = maskLayer
    }
    
    func configureViews(post: Post) {
        self.post = post
        
        if (post.title == nil) {
            hideTitle()
        } else {
            showTitle()
        }
        
        self.username.text = post.username
        
        if let title = post.title {
            self.postTitle.text = title
        }
        
        self.postBody.text = post.body
        self.timestamp.text = post.timestamp
        self.likesCount.text = post.likeCount.toThousandsString()
        
        if post.liked {
            likeImage.image = UIImage(named: "Liked")
        } else {
            likeImage.image = UIImage(named: "Like")
        }
        
        setupAvatarImage()
        setupLikeGesture()
    }
    
    func setupLikeGesture() {
        let singleTap = UITapGestureRecognizer(target: self, action: Selector("processLike"))
        singleTap.numberOfTapsRequired = 1
        likeClickSpace.addGestureRecognizer(singleTap)
    }
    
    func processLike() {
        toggleLike()
        
        Alamofire.request(Router.LikePost(post_id: post.id, dislike: !post.liked))
            .responseJSON { request, response, jsonData, errors in
                
                if (response?.statusCode > 299 || errors != nil) {
                    if (response?.statusCode > 299) {
                        //something went wrong
                    } else {
                        //localizedDescription
                    }
                    
                    self.toggleLike()
                    // maybe use toast.
                }
        }
    }
    
    func toggleLike() {
        if post.liked {
            post.liked = false
            post.likeCount -= 1
            likeImage.image = UIImage(named: "Like")
        } else {
            post.liked = true
            post.likeCount += 1
            likeImage.image = UIImage(named: "Liked")
        }
        
        self.likesCount.text = post.likeCount.toThousandsString()
    }
    
    func setupAvatarImage() {
        if let url = post.avatarUrl {
            self.avatarImage.setImageWithURL(NSURL(string: url), placeholderImage: UIImage(named: "AvatarPlaceHolder"), options: SDWebImageOptions.RetryFailed, completed: { (image: UIImage!, error: NSError!, cacheType: SDImageCacheType, imageURL: NSURL!) -> Void in
                
                }, usingActivityIndicatorStyle: .Gray)
        }
        
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
