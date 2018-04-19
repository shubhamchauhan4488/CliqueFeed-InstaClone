//
//  Feed.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 24/03/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit

class Feed: NSObject {
 
    var feedPostUserImg : String!
    var feedImage : String!
    var feedPostUser : String!
    var feedDescription : String!
    var lastCommentUserImg : String!
    var comments : [String]!
    var uid : String!
    var timeStamp : Double!
    
    init(feedPostUserImg : String, feedImage : String,feedPostUser : String,feedDescription : String,lastCommentUserImg : String,timeStamp : Double, id: String){
        self.feedPostUserImg = feedPostUserImg
        self.feedImage = feedImage
        self.feedPostUser = feedPostUser
        self.feedDescription = feedDescription
        self.lastCommentUserImg = lastCommentUserImg
        self.timeStamp = timeStamp
        self.uid = id
    }
}


class feedIntermediate : NSObject{
    var feedImage : String!
    var feedDescription : String!
    var timeStamp : Double!
    var postid : String!
    
    init(feedImage : String,feedDescription : String, timeStamp : Double, id: String){
        self.feedDescription = feedDescription
        self.feedImage = feedImage
        self.timeStamp = timeStamp
        self.postid = id
    }
}
