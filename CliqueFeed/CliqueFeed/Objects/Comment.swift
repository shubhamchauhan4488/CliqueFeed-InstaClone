//
//  Comment.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 01/04/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import Foundation

class Comment {
    var postingUserImg : String
    var postinguserName : String
    var postingUserComment : String
    
    
    init(postingUserImg: String, postinguserName: String, postingUserComment : String){
        self.postingUserImg = postingUserImg
        self.postinguserName = postinguserName
        self.postingUserComment = postingUserComment
    }
}
