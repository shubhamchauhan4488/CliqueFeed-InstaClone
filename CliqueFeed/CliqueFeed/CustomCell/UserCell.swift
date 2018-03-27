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
    
    @IBOutlet weak var followLabel: UILabel!
    
    var userID : String!
}
