//
//  FeedCell.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 24/03/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {

    @IBOutlet weak var feedPostUserImg: UIImageView!
    @IBOutlet weak var feedImage: UIView!
    @IBOutlet weak var feedPostUser: UILabel!
    
    @IBOutlet weak var lastComment: UILabel!
    @IBOutlet weak var lastCommentUserIMg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }



}
