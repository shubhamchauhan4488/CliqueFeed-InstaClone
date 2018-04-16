//
//  FeedCell.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 24/03/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {
    
    @IBOutlet weak var feedImage: UIImageView!
    @IBOutlet weak var feedPostUserImg: UIImageView!
    @IBOutlet weak var feedPostUser: UILabel!
    @IBOutlet weak var feedDescription: UILabel!
    @IBOutlet weak var lastCommentUserIMg: UIImageView!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var timePosted: UILabel!
    
    @IBOutlet weak var separatorView: UIView!
    var delegate : FeedTableViewCellDelegate?
    
    @IBOutlet weak var feedView: UIView!
    @IBAction func onCommentClick(_ sender: Any) {
        delegate?.feedTableViewCellDidTapComment(self)
    }
    
    @IBAction func onPostClick(_ sender: Any) {
        delegate?.feedTableViewCellDidTapPost(self)
        commentText.text = ""
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedView.layer.shadowOffset = CGSize(width:0,height: 3.0)
        feedView.layer.shadowRadius = 3.0
        feedView.layer.shadowOpacity = 0.6
        feedView.layer.shadowColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8).cgColor
        feedView.layer.cornerRadius = 20
        //view.backgroundColor = UIColor.white
//        feedView.layer.borderColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8).cgColor
//        feedView.layer.borderWidth = 2
        feedPostUserImg.layer.borderWidth = 2
        feedPostUserImg.layer.borderColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8).cgColor
        
    }
}
