//
//  FeedCell.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 24/03/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit
import FaveButton

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
    @IBOutlet weak var feedLikeButton: FaveButton!
    @IBOutlet weak var separatorView: UIView!
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
        
    }
    
    
}
