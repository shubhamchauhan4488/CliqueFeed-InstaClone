//
//  FeedCell.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 24/03/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {
    
    let feed = Feed()
    @IBOutlet weak var feedImage: UIImageView!
    @IBOutlet weak var feedPostUserImg: UIImageView!
    @IBOutlet weak var feedPostUser: UILabel!
    @IBOutlet weak var feedDescription: UILabel!
    @IBOutlet weak var lastCommentUserIMg: UIImageView!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var timePosted: UILabel!
    
    var delegate : FeedTableViewCellDelegate?
    
    @IBAction func onCommentClick(_ sender: Any) {
        delegate?.feedTableViewCellDidTapComment(self)
    }
    
    @IBAction func onPostClick(_ sender: Any) {
        delegate?.feedTableViewCellDidTapPost(self)
        commentText.text = ""
    }
}
