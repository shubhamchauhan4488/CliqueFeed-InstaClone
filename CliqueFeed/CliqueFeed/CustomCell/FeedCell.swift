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
    @IBOutlet weak var trashBtn: UIButton!
    @IBOutlet weak var postBtn: UIButton!
    
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
    
    @IBAction func onTrashClick(_ sender: Any) {
        delegate?.feedTableViewCellDidTapTrash(self)
    }
    
    @IBAction func onAddCommentClick(_ sender: Any) {
      
        UIView.animate(withDuration: 0.9,animations: {
           
            self.lastCommentUserIMg.layer.transform = CATransform3DMakeScale(1.3, 1.3, 1)
            self.commentText.layer.borderWidth = 1
            self.commentText.layer.borderColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8).cgColor
            self.commentText.layer.transform = CATransform3DMakeScale(0.95, 1.2, 1.1)
            })
                {(finished) in
                if (finished){
                      self.postBtn.isHidden = false
                }
        }
    }
    
    @IBAction func onAddCommentEditingEnd(_ sender: Any) {
        self.postBtn.isHidden = true
        UIView.animate(withDuration: 0.9) {
            self.lastCommentUserIMg.layer.transform = CATransform3DMakeScale(1, 1, 1)
            self.commentText.layer.borderWidth = 0
             self.commentText.layer.transform = CATransform3DMakeScale(1, 1, 1)
        }
    }
    
    @objc func imageTapped(){
        delegate?.feedTableViewCellDidTapFeedImage(self)
    }
    @objc func feedPostUserImgTapped(){
        delegate?.feedTableViewCellDidTapUserImage(self)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        postBtn.isHidden = true
        feedView.layer.shadowOffset = CGSize(width:0,height: 3.0)
        feedView.layer.shadowRadius = 3.0
        feedView.layer.shadowOpacity = 0.6
        feedView.layer.shadowColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8).cgColor
        feedView.layer.cornerRadius = 20
        
        feedPostUserImg.layer.borderWidth = 2
        feedPostUserImg.layer.borderColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8).cgColor
        likedByYouLabel.font = UIFont(name: "Avenir", size: 14)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        feedImage.isUserInteractionEnabled = true
        feedImage.addGestureRecognizer(tapGestureRecognizer)
        
        let userImageTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(feedPostUserImgTapped))
        feedPostUserImg.isUserInteractionEnabled = true
        feedPostUserImg.addGestureRecognizer(userImageTapGestureRecognizer)
    }
    
    func configure(feedDescription : String, feedPostUserName : String, feedPostUserImgURL : String,lastCommentUserImgURL : String, feedImageURL: String, likes : Int, isLiked : Bool, timePosted : String, isOtherUser : Bool){
        
        if(isLiked){
            self.likedByYouLabel.text = " Liked By You and \(likes - 1) others"
            self.likedByYouLabel.isHidden = false
            self.feedLikeButton?.setSelected(selected: true, animated: false)
        }else{
            self.likedByYouLabel.text = "Liked By \(likes) people"
            self.likedByYouLabel.isHidden = true
            self.feedLikeButton?.setSelected(selected: false, animated: false)
        }
        if (isOtherUser){
            self.trashBtn.isHidden = true
        }
        
        self.feedDescription.text = feedDescription
        self.feedPostUser.text = feedPostUserName
        self.feedPostUserImg.downloadImage(from: feedPostUserImgURL)
        self.lastCommentUserIMg.downloadImage(from: lastCommentUserImgURL)
        self.feedImage.downloadImage(from: feedImageURL)
        self.likes.text = String(likes)
        self.timePosted.text = timePosted
    }
}
