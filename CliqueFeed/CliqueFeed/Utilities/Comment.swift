//
//  Comment.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 01/04/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import Foundation

class Comment {
    //Variables
    private var _commentingUserImage : String!
    private var _commentingUsername : String!
    private var _comment : String!
    private var _timeStamp : Double!
    
    //Properties
    public var commentingUserImage : String {
        if _commentingUserImage == nil {
            _commentingUserImage = ""
        }
        return _commentingUserImage
    }
    
    public var commentingUsername : String {
        if _commentingUsername == nil {
            _commentingUsername = ""
        }
        return _commentingUsername
    }
    public var comment : String {
        if _comment == nil {
            _comment = ""
        }
        return _comment
    }
    public var timeStamp : Double {
        if _timeStamp == nil {
            _timeStamp = 0.0
        }
        return _timeStamp
    }
    
    init(commentingUserImage: String, commentingUsername: String, comment : String, timeStamp: Double){
        self._commentingUserImage = commentingUserImage
        self._commentingUsername = commentingUsername
        self._comment = comment
        self._timeStamp = timeStamp
    }
}
