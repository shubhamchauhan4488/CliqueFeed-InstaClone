//
//  User.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 22/03/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit

class User: NSObject{
    
    private var _name = String()
    var name : String{
        get {
            return _name
        }
        set{
            _name = newValue
        }
    }
    
    private var _uid = String()
    var uid : String{
        get {
            return _uid
        }
        set{
            _uid = newValue
        }
    }
    
    private var _email = String()
    var email : String{
        get {
            return _email
        }
        set{
            _email = newValue
        }
    }
    
    private var _imagePath = String()
    var imagePath : String{
        get {
            return _imagePath
        }
        set{
            _imagePath = newValue
        }
    }
    
    override init(){}
    
    init(name : String, email : String, uid : String, imagePath : String){
        self._name  = name
        self._email = email
        self._uid = uid
        self._imagePath = imagePath
    }
}

class CurrentUser {
    
    private var _name = String()
    var name : String{
        get {
            return _name
        }
        set{
            _name = newValue
        }
    }
    
    private var _uid = String()
    var uid : String{
        get {
            return _uid
        }
        set{
            _uid = newValue
        }
    }
    
    private var _email = String()
    var email : String{
        get {
            return _email
        }
        set{
            _email = newValue
        }
    }
    
    private var _imagePath = String()
    var imagePath : String{
        get {
            return _imagePath
        }
        set{
            _imagePath = newValue
        }
    }
    
    static let sharedInstance = User()
    private init(){}
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



