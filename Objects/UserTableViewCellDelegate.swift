//
//  UserTableViewCellDelegate.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 03/04/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import Foundation

protocol UserTableViewCellProtocol : class {
    func userTableViewCellDidTapFollowUnfollow(_ tag: Int)
}
