//
//  Comment.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 01/04/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import Foundation

class Comment {
    var commentingUserImage : String
    var commentingUsername : String
    var comment : String
    var timeStamp : Double
    
    
    init(commentingUserImage: String, commentingUsername: String, comment : String, timeStamp: Double){
        self.commentingUserImage = commentingUserImage
        self.commentingUsername = commentingUsername
        self.comment = comment
        self.timeStamp = timeStamp
    }
}
