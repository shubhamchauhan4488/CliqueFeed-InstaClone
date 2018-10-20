//
//  FeedCell.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 24/03/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit
import FaveButton
import LikeAnimation

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var feedImage: UIImageView!
    @IBOutlet weak var feedPostUserImg: UIImageView!
    @IBOutlet weak var feedPostUser: UILabel!
    @IBOutlet weak var feedDescription: UILabel!
    @IBOutlet weak var lastCommentUserIMg: UIImageView!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var timePosted: UILabel!
    @IBOutlet weak var likes: UILabel!
    @IBOutlet weak var likedByYouLabel: UILabel!
    @IBOutlet weak var feedLikeButton: FaveButton?
    @IBOutlet weak var feedView: UIView!
    
    var delegate : FeedTableViewCellDelegate?

    @IBAction func onCommentClick(_ sender: Any) {
        delegate?.feedTableViewCellDidTapComment(self)
        
    }
    
    @IBAction func onPostClick(_ sender: Any) {
        delegate?.feedTableViewCellDidTapPost(self)
        commentText.text = ""
    }
    
    @IBAction func onLikeClick(_ sender: Any) {
        delegate?.feedTableViewCellDidTapLike(self)

//        feedLikeButton?.setSelected(selected: true, animated: false)
//        let likeAnimation = LikeAnimation(frame: CGRect(origin: feedPostUserImg.center, size: CGSize(width: 100, height: 100)))
//        feedPostUserImg.addSubview(likeAnimation)
//        feedPostUserImg.bringSubview(toFront: likeAnimation)
//        likeAnimation.duration = 1.5
//        likeAnimation.circlesCounter = 1            // One cirlce
//        likeAnimation.particlesCounter.main = 6     // 6 big particles
//        likeAnimation.particlesCounter.small = 7
//        likeAnimation.heartColors.initial = .white
//        likeAnimation.heartColors.animated = .orange
//        likeAnimation.particlesColor = .orange
//        likeAnimation.run()
    }
    
    @IBAction func onTrashClick(_ sender: Any) {
        delegate?.feedTableViewCellDidTapTrash(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        feedView.layer.shadowOffset = CGSize(width:0,height: 3.0)
        feedView.layer.shadowRadius = 3.0
        feedView.layer.shadowOpacity = 0.6
        feedView.layer.shadowColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8).cgColor
        feedView.layer.cornerRadius = 20
        feedPostUserImg.layer.borderWidth = 2
        feedPostUserImg.layer.borderColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8).cgColor
        likedByYouLabel.font = UIFont(name: "Avenir", size: 14)

    } 
}
