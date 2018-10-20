//
//  Feed.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 24/03/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit

class Feed: NSObject {
 
    private var _feedPostUserImg : String!
    private var _feedImage : String!
    private var _feedPostUser : String!
    private var _feedDescription : String!
    private var _lastCommentUserImg : String!
    private var _uid : String!
    private var _timeStamp : Double!
    private var _likes : Int!
    private var _isLiked : Bool!
    
    public var feedPostUserImg : String {
        if _feedPostUserImg == nil {
            _feedPostUserImg = ""
        }
        return _feedPostUserImg
    }
    public var feedImage : String {
        if _feedImage == nil {
            _feedImage = ""
        }
        return _feedImage
    }
    public var feedPostUser : String {
        if _feedPostUser == nil {
            _feedPostUser = ""
        }
        return _feedPostUser
    }
    public var feedDescription : String {
        if _feedDescription == nil {
            _feedDescription = ""
        }
        return _feedDescription
    }
    public var lastCommentUserImg : String {
        if _lastCommentUserImg == nil {
            _lastCommentUserImg = ""
        }
        return _lastCommentUserImg
    }
    public var timeStamp : Double {
        if _timeStamp == nil {
            _timeStamp = 0.0
        }
        return _timeStamp
    }
    public var likes : Int {
        if _likes == nil {
            _likes = 0
        }
        return _likes
    }
    public var uid : String {
        if _uid == nil {
            _uid = ""
        }
        return _uid
    }
    public var isLiked : Bool {
        if _isLiked == nil {
            _isLiked = false
        }
        return _isLiked
    }
    
    
    init(feedPostUserImg : String, feedImage : String,feedPostUser : String,feedDescription : String,lastCommentUserImg : String,likes : Int, isLiked : Bool, timeStamp : Double, id: String){
        self._feedPostUserImg = feedPostUserImg
        self._feedImage = feedImage
        self._feedPostUser = feedPostUser
        self._feedDescription = feedDescription
        self._lastCommentUserImg = lastCommentUserImg
        self._timeStamp = timeStamp
        self._uid = id
        self._likes = likes
        self._isLiked = isLiked
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
