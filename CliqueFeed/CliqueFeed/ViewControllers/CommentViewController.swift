//
//  CommentViewController.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 30/03/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

class CommentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var postid : String!
    var refDatabase : DatabaseReference!
    var ref : DatabaseReference!
    var uid : String!
    var comments : [Comment] = []
    var userMeta : [UserIntermediate] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refDatabase = Database.database().reference()
        ref = Database.database().reference()
        self.navigationController?.navigationBar.isHidden = false
        comments = []
        self.fetchCommentDetails()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as? CommentCell{
            
            let date = Date()
            //Calculating the date offset from the current date
            let x = date.offset(from: Date(timeIntervalSince1970: comments[indexPath.row].timeStamp))
            let str = "Posted : \(x) ago"
            
            //Method to set the attributes of the cell elements programatically
            //        let yourAttributes = [NSAttributedStringKey.foregroundColor: UIColor.black]
            //        let yourOtherAttributes = [NSAttributedStringKey.foregroundColor: UIColor.lightGray]
            //        let partOne = NSMutableAttributedString(string: comments[indexPath.row].postingUserComment, attributes: yourAttributes)
            //        let partTwo = NSMutableAttributedString(string: str, attributes: yourOtherAttributes)
            //        let combination = NSMutableAttributedString()
            //        combination.append(partOne)
            //        combination.append(partTwo)
            //        cell.detailTextLabel?.attributedText = combination
            //        cell.imageView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
            
            cell.commentingUserImage.downloadImage(from: comments[indexPath.row].commentingUserImage)
            cell.commentingUsername.text = comments[indexPath.row].commentingUsername
            cell.comment.text = comments[indexPath.row].comment
            cell.commentTimeDifference.text = str
            return cell
        }else{
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func fetchCommentDetails(){
        
        self.refDatabase.child("postsWithComments").observeSingleEvent(of: .value, with: { (snap) in
            print("entered comments in database")
            if let postsWithCommentssnap = snap.value as? Dictionary<String, AnyObject>{
                print(postsWithCommentssnap)
                if let posts = postsWithCommentssnap as? Dictionary<String,AnyObject>{
                    //              print("----------")
                    //              print(posts)
                    let postsarray = posts as! Dictionary<String,AnyObject>
                    print(postsarray)
                    for (k,v) in postsarray{
                        if k == self.postid!{
                            print("Value of k \(k)")
                            print("Value of postid \(self.postid!)")
                            let postinguserdetails = v as! Dictionary<String,AnyObject>
                            for (_,ve) in postinguserdetails{
                                if let uid = ve["uid"] as? String, let comment = ve["comment"] as? String, let timestamp = ve["timestamp"] as? Double {
                                    let userObj = UserIntermediate(uid: uid, comment: comment, timeStamp : timestamp)
                                    self.userMeta.append(userObj)
                                    print(self.userMeta)
                                }
                            }
                        }
                    }
                }
            }
            //Fetching the user details who posted thier comments
            self.fetchuserdeatils()
        })
    }
    
    func fetchuserdeatils(){
        self.refDatabase.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let usersnap = snapshot.value as? [String : AnyObject]{
                print("%%%%%%%%%%%%%%%inside usser snap%%%%%%%%%%%%%%%%")
                for user in self.userMeta {
                    let userkeys = usersnap.keys.filter({ (id) -> Bool in
                        id == user.uid
                    })
                    let newComment = Comment(commentingUserImage: usersnap[userkeys[0]]!["urlImage"] as! String, commentingUsername: usersnap[userkeys[0]]!["name"] as! String, comment: user.comment, timeStamp: user.timeStamp)
                    self.comments.append(newComment)
                }
                self.comments = self.comments.sorted(by: { $0.timeStamp < $1.timeStamp })
                self.tableView.reloadData()
            }
        })
        self.refDatabase.removeAllObservers()
    }
}

extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}

