//
//  FeedTableViewCellDelegate.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 30/03/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import Foundation
protocol FeedTableViewCellDelegate : class {
    func feedTableViewCellDidTapComment(_ sender: FeedCell)
    func feedTableViewCellDidTapPost(_ sender: FeedCell)
//    func feedTableViewCellDidTapLike(_ sender: FeedCell)
}
