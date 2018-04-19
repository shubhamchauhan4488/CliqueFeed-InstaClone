//
//  FeedViewController.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 23/03/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FeedTableViewCellDelegate {

    var feeds = [Feed]()
    var postids = [String]()
    var following = [String]()
    var comments = [String]()
    var commentUserImageUrl : String!
    var counter = 0
    @IBOutlet weak var tableView: UITableView!
    var refDatabase : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refDatabase = Database.database().reference()
        feeds = []
        postids = []
        following = []
        fetchFeed()
//        tableView.showLoader()
//        tableView.reloadData()
         self.navigationController?.navigationBar.isHidden = true
    }
    
    func fetchFeed(){
        
    refDatabase.child("users").observe(.value, with: { (snapshot) in
        let usersnap = snapshot.value as! [String : AnyObject]
            for(_, value) in usersnap{
                if let userid = value["uid"] as? String{
                    if userid == Auth.auth().currentUser?.uid{
                              self.following.append((Auth.auth().currentUser?.uid)!)
                        if let followingUsers = value["following"] as? [String:String]{
                            for(_, user) in followingUsers{
                                self.following.append(user)
                                print("users appended in following")
                            }
                        }

                        self.refDatabase.child("posts").observe(.value, with: { (snap) in
 
                            print("entered posts in database")
                            if let postsnap = snap.value as? Dictionary<String, AnyObject>{
                            print(postsnap)
                            for (ke,userPosts) in postsnap{
//                                    print("*****////*****")
                                        if let details = userPosts as? Dictionary<String, AnyObject>{
                                            if let userID = details["uid"] as? String{
                                                print(self.following)
                                                if self.following.contains(userID) {
//                                                    print(userID)
                                                    
                                                    var name : String!
                                                    var userImageUrl: String!
                                                    var id : String!
                                                        for(k, value) in usersnap{
                                                            if k == userID{
                                                                    name = value["name"] as! String
                                                                    userImageUrl = value["urlImage"] as! String
                                                                    id = ke
                                                                    self.commentUserImageUrl = value["urlImage"] as! String
                                                            }
                                                    }
                                                    let fedd = Feed(feedPostUserImg: userImageUrl, feedImage: details["urlImage"] as! String, feedPostUser: name, feedDescription: details["comment"] as! String, lastCommentUserImg: self.commentUserImageUrl, timeStamp: details["timestamp"] as! Double,id: id)
                                                    self.feeds.append(fedd)
                                                }
                                            }
                                        }
                                self.tableView.reloadData()
//                                self.tableView.hideLoader()
                            }
                        }
                            print("^^^^^^^^^^^^")
                            self.feeds = self.feeds.sorted(by: { $0.timeStamp > $1.timeStamp })
                            for i in 0..<self.feeds.count{
                                self.postids.append(self.feeds[i].uid)
                            }
                            print(self.postids)
                        })
                    }
                }
            }
        })
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell
        
        
        cell.feedDescription.text = feeds[indexPath.row].feedDescription
        cell.feedPostUser.text = feeds[indexPath.row].feedPostUser
        cell.feedPostUserImg.downloadImage(from: feeds[indexPath.row].feedPostUserImg)
        //Image added using extension
        cell.feedImage.downloadImage(from: feeds[indexPath.row].feedImage)
        cell.lastCommentUserIMg.downloadImage(from: feeds[indexPath.row].lastCommentUserImg)
        
        
        //Getting the difference between current date and timestamp with the help of Date extension
        //WHY if we place this above getting cell.feedDescription.text it is giving error?
        let date = Date()
        print("%%%%%%%%%%%%%%%----------%%%%%%%%%%%%")

        let x = date.offset(from: Date(timeIntervalSince1970: feeds[indexPath.row].timeStamp))
        cell.timePosted.text = x
        cell.delegate = self
        return cell
    }
    
    //Fixing cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    //Conforming to FeedTableViewCelldelegate : On Comment Tap
    func feedTableViewCellDidTapComment(_ sender: FeedCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        print("Comm", sender, tappedIndexPath)
        
        if let secondViewController = storyboard?.instantiateViewController(withIdentifier: "commentViewController") as? CommentViewController {
            // Pass Data
//            secondViewController.feed = feeds[tappedIndexPath.row]
            secondViewController.postid = self.postids[tappedIndexPath.row]
            // Present Second View
           navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
    
    //Conforming to FeedTableViewCelldelegate : On Post Tap
    func feedTableViewCellDidTapPost(_ sender: FeedCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        let index = IndexPath(row: tappedIndexPath.row, section: 0)
        let cell: FeedCell = self.tableView.cellForRow(at: index) as! FeedCell
        let timeInterval = NSDate().timeIntervalSince1970
        let comments = ["comment" : cell.commentText.text!,
                        "uid" : (Auth.auth().currentUser?.uid)!,
                        "timestamp" : timeInterval] as [String : Any]
        refDatabase.child("postsWithComments").child(self.postids[tappedIndexPath.row]).childByAutoId().updateChildValues(comments)
        counter = counter + 1
        
    }
    
    
    
}


