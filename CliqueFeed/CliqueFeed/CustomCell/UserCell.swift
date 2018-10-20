//
//  UserCell.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 21/03/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//


import UIKit

class UserCell : UITableViewCell{
    
    @IBOutlet weak var userimage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var followUnfollowBtn: UIButton!
    @IBOutlet weak var view: UIView!
    weak var delegate : UserTableViewCellProtocol?
    var userID : String!
    var followFlag = false
    
    @IBAction func followUnfollowButton(_ sender: BounceButton) {
        delegate?.userTableViewCellDidTapFollowUnfollow(sender.tag)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        view.layer.shadowOffset = CGSize(width:0,height: 3.0)
        view.layer.shadowRadius = 3.0
        view.layer.shadowOpacity = 0.6
        view.layer.shadowColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8).cgColor
        view.layer.cornerRadius = 10
        userimage.layer.borderWidth = 2
        userimage.layer.borderColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8).cgColor
    }
    
    func configure(username : String, imageURL : String, userID : String, isFollowing : Bool){
        self.username.text = username
        self.userimage.downloadImage(from: imageURL)
        self.userID = userID
        if isFollowing{
            followUnfollowBtn.imageView?.image = UIImage(named : "Following_icon")
        }
        else{
            followUnfollowBtn.imageView?.image = UIImage(named : "Follow_icon")
        }
        
    }
    
}
