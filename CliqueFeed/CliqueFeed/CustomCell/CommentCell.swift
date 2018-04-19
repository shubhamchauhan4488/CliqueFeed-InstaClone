//
//  CommentCell.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 10/04/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit

class CommentCell: UITableViewCell {

    @IBOutlet weak var commentingUserImage: UIImageView!    
    @IBOutlet weak var commentingUsername: UILabel!
    @IBOutlet weak var comment: UILabel!
    @IBOutlet weak var commentTimeDifference: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    commentingUserImage.layer.borderWidth = 2
    commentingUserImage.layer.borderColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8).cgColor
    }
}
