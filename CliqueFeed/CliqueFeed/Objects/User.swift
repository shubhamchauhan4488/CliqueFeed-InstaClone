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
    var email : String!
    var imagePath : String!
    init(name : String, email : String, uid : String, imagePath : String){
        self.name  = name
        self.email = email
        self.uid = uid
        self.imagePath = imagePath
    }
    override init(){}
    
}

class UserIntermediate : NSObject{
    
    var uid : String
    var comment : String
    var timeStamp : Double
    
    init(uid : String, comment : String, timeStamp : Double){
        self.uid  = uid
        self.comment = comment
        self.timeStamp = timeStamp
    }
}



