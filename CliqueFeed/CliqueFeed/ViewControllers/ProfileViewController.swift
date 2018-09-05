//
//  ProfileViewController.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 01/04/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import GoogleSignIn

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FeedTableViewCellDelegate {
    
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var name: UILabel!
    var refDatabase : DatabaseReference!
    var feeds = [Feed]()
    var postids = [String]()
    var comments = [String]()
    var counter = 0
    var newname : String!
    var userImageUrl: String!
    var commentUserImageUrl: String!
    var metaFeeds = [feedIntermediate]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8)
        
        refDatabase = Database.database().reference()
        feeds = []
        postids = []
        metaFeeds = []
        fetchFeed()
        profileImg.layer.borderWidth = 2
        profileImg.layer.borderColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8).cgColor
        tableView.reloadData()
        
    }
    
    func fetchFeed(){
        
        self.refDatabase.child("posts").observe(.value, with: { (snap) in
            //            print("entered posts in database")
            let postsnap = snap.value as! Dictionary<String, AnyObject>
            for (k,userPosts) in postsnap{
                //                print("*****////*****")
                if let details = userPosts as? Dictionary<String, AnyObject>{
                    if let userID = details["uid"] as? String{
                        if userID == Auth.auth().currentUser?.uid{
                            
                            let metafeed = feedIntermediate(feedImage: details["urlImage"] as! String, feedDescription: details["comment"] as! String, timeStamp: details["timestamp"] as! Double, id: k)
                            self.metaFeeds.append(metafeed)
                            
                        }
                    }
                }
            }
            
        })
        
        
        self.refDatabase.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let usersnap = snapshot.value as! [String : AnyObject]
            var id : String!
            
            for(k, value) in usersnap{
                if k == Auth.auth().currentUser?.uid{
                    self.newname = value["name"] as! String
                    self.userImageUrl = value["urlImage"] as! String
                    
                    self.profileImg.downloadImage(from: self.userImageUrl)
                    self.name.text = self.newname!
                    
                    self.commentUserImageUrl = value["urlImage"] as! String
                    self.navigationItem.title = value["email"] as! String
                    
                }
            }
            
            for metafeed in self.metaFeeds{
//                print("iam in metafeed")
                let fedd = Feed(feedPostUserImg: self.userImageUrl, feedImage: metafeed.feedImage, feedPostUser: self.newname, feedDescription: metafeed.feedDescription, lastCommentUserImg: self.commentUserImageUrl, timeStamp: metafeed.timeStamp, id: metafeed.postid)
                self.feeds.append(fedd)
            }
            self.sortfeeds()
            self.tableView.reloadData()
        })
        
        
    }
    
    func sortfeeds(){
        self.feeds = self.feeds.sorted(by: { $0.timeStamp > $1.timeStamp })
        print(self.feeds)
        self.postids = []
        for i in 0..<self.feeds.count{
            self.postids.append(self.feeds[i].uid)
        }
        print(self.postids)
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
        cell.lastCommentUserIMg.downloadImage(from: feeds[indexPath.row].lastCommentUserImg)
        cell.feedImage.downloadImage(from: feeds[indexPath.row].feedImage)
        let date = Date()
        print("%%%%%%%%%%%%%%%----------%%%%%%%%%%%%")
        
        let x = date.offset(from: Date(timeIntervalSince1970: feeds[indexPath.row].timeStamp))
        cell.timePosted.text = x
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
            //            secondViewController.feed = feeds[tappedIndexPath.row]
            secondViewController.postid = self.postids[tappedIndexPath.row]
            // Present Second View
            navigationController?.pushViewController(secondViewController, animated: true)
        }
        
    }
    
    func feedTableViewCellDidTapPost(_ sender: FeedCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        
        let index = IndexPath(row: tappedIndexPath.row, section: 0)
        let cell: FeedCell = self.tableView.cellForRow(at: index) as! FeedCell
        let timeInterval = NSDate().timeIntervalSince1970
        let comments = ["comment" : cell.commentText.text!,
                        "uid" : (Auth.auth().currentUser?.uid)!,
                        "timestamp" : timeInterval] as [String : Any]
        
        refDatabase.child("postsWithComments").child(self.postids[tappedIndexPath.row]).childByAutoId().updateChildValues(comments)
        
    }
    
    
    @IBAction func onLogoutClick(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance().signOut()
            self.dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
       
    }
    
    
    
    
}
