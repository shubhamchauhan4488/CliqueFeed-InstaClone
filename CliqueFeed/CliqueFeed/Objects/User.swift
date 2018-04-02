//
//  User.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 22/03/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit

class User: NSObject{
    var name : String!
    var uid : String!
    var imagePath : String!
}

class UserIntermediate : NSObject{
    
    var uid : String
    var comment : String
    
    init(uid : String, comment : String){
        self.uid  = uid
        self.comment = comment
    }
}
