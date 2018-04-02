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
        tableView.reloadData()
         self.navigationController?.navigationBar.isHidden = true
    }
    
    func fetchFeed(){
        
        refDatabase.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
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
                  
                        
                        self.refDatabase.child("posts").observeSingleEvent(of: .value, with: { (snap) in
                            print("entered posts in database")
                            let postsnap = snap.value as! Dictionary<String, AnyObject>
                            
                            for (k,userPosts) in postsnap{
                                    print("*****////*****")
         
                                        if let details = userPosts as? Dictionary<String, AnyObject>{
                                            if let userID = details["uid"] as? String{
                                                print(self.following)
                                                if self.following.contains(userID) {
                                                    print(userID)
                                                    self.postids.append(k)
                                                    let fedd = Feed()
                                                    fedd.feedDescription = details["comment"] as! String

                                                    fedd.feedImage = details["urlImage"] as! String
                                                    var name : String!
                                                    var userImageUrl: String!
                                                        for(k, value) in usersnap{
                                                            if k == userID{
                                                                    name = value["name"] as! String
                                                                    userImageUrl = value["urlImage"] as! String
                                                                 self.commentUserImageUrl = value["urlImage"] as! String
                                                            }
                                                    }
                                                    fedd.feedPostUser = name
                                                    fedd.feedPostUserImg = userImageUrl
                                                    fedd.lastCommentUserImg = self.commentUserImageUrl
                                                    self.feeds.append(fedd)
                                                }
                                            }
                                        }
                                    self.tableView.reloadData()
                                
                            }
                            print(self.feeds)
                            print(self.postids)
                        })
                    }
                }

                self.refDatabase.removeAllObservers()
                //print(self.feeds)
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
        
//       cell.feedPostUser.text = feeds[indexPath.row].feedPostUser
        cell.feedDescription.text = feeds[indexPath.row].feedDescription
        cell.feedPostUser.text = feeds[indexPath.row].feedPostUser
        cell.feedPostUserImg.downloadImage(from: feeds[indexPath.row].feedPostUserImg)
        cell.feedImage.downloadImage(from: feeds[indexPath.row].feedImage)
        cell.lastCommentUserIMg.downloadImage(from: feeds[indexPath.row].lastCommentUserImg)
        cell.delegate = self


        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
    }
    
    //Conforming to FeedTableViewCelldelegate
    func feedTableViewCellDidTapComment(_ sender: FeedCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        print("Comm", sender, tappedIndexPath)
        
        if let secondViewController = storyboard?.instantiateViewController(withIdentifier: "commentViewController") as? CommentViewController {
            // Pass Data
            secondViewController.feed = feeds[tappedIndexPath.row]
            secondViewController.postid = self.postids[tappedIndexPath.row]
            // Present Second View
           navigationController?.pushViewController(secondViewController, animated: true)
        }
     
    }
    
    func feedTableViewCellDidTapPost(_ sender: FeedCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        let index = IndexPath(row: tappedIndexPath.row, section: 0)
        let cell: FeedCell = self.tableView.cellForRow(at: index) as! FeedCell
    
        let comments = ["comment" : cell.commentText.text!,
                        "uid" : (Auth.auth().currentUser?.uid)!]
        print(postids.count)
        print(postids)
  
//        var reversedpostids = [String]()
//        for arrayIndex in stride(from: self.postids.count - 1, through: 0, by: -1) {
//            reversedpostids.append(self.postids[arrayIndex])
//        }
//        print(reversedpostids)
//        let newindex = postids.count - tappedIndexPath.row
        
        refDatabase.child("postsWithComments").child(self.postids[tappedIndexPath.row]).child("\((Auth.auth().currentUser?.uid)!)").updateChildValues(comments)
        counter = counter + 1
        
    }
    
    
    
}


