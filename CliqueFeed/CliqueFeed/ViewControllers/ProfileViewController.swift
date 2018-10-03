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
    var likesCount = 0
    var newname : String!
    var userImageUrl: String!
    var commentUserImageUrl: String!
    var metaFeeds = [feedIntermediate]()
    var user = User()
    typealias fetchUserPosts = () -> ()
    typealias getPostsData = () -> ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        profileImg.layer.borderWidth = 2
        profileImg.layer.borderColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8).cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8)

        metaFeeds = []
        refDatabase = Database.database().reference()
        fetchFeed {
            self.fetchUserPosts{
                self.tableView.remembersLastFocusedIndexPath = true
                self.tableView.reloadData()
            }
        }
    }
    
    func fetchFeed(completed : @escaping fetchUserPosts){
        
        refDatabase.child("users").observe(.value, with: { (snapshot) in
            
            // self.feeds = []
            //            self.following = []
            let usersnap = snapshot.value as! [String : AnyObject]
            for(id, value) in usersnap{
                if let userid = id as? String{
                    if userid == Auth.auth().currentUser?.uid{
                        print("Cuurent user id:", userid)
                        self.user = User(name : value["name"] as! String, uid:  userid, imagePath : value["urlImage"] as! String)
                        self.profileImg.downloadImage(from: self.user.imagePath)
                        self.name.text = self.user.name!
                    }
                }
                
            }
            completed()
        })
        refDatabase.child("users").removeAllObservers()
    }
    
    
    func fetchUserPosts(completed : @escaping getPostsData){
        self.refDatabase.child("posts").observe(.value, with: { (snap) in
            
            self.feeds = []
            self.postids = []
            if let postsnap = snap.value as? Dictionary<String, AnyObject>{
                for (ke,userPosts) in postsnap{
                    if let details = userPosts as? Dictionary<String, AnyObject>{
                        let currentUserId = Auth.auth().currentUser?.uid
                        var isLiked = false
                        if currentUserId == details["uid"] as! String
                        {
                            if let likedByDict = details["likedBy"] as? Dictionary<String, AnyObject>{
                                for (_ , likedByUserId) in likedByDict{
                                    if likedByUserId as? String == Auth.auth().currentUser?.uid{
                                        isLiked = true
                                    }
                                }
                            }
                            print("isLiked : ", isLiked)
                          
                            let fedd = Feed(feedPostUserImg:  self.user.imagePath, feedImage: details["urlImage"] as! String, feedPostUser: self.user.name, feedDescription: details["comment"] as! String, lastCommentUserImg: self.user.imagePath,likes : details["likes"] as! Int, isLiked : isLiked, timeStamp: details["timestamp"] as! Double,id: ke)
                            self.feeds.append(fedd)
                   
                        }
                    }
                }
                
                print("^^^^^^^^^^^^")
                print("Feeds : ", self.feeds)
                self.feeds = self.feeds.sorted(by: { $0.timeStamp > $1.timeStamp })
                for i in 0..<self.feeds.count{
                    self.postids.append(self.feeds[i].uid)
                }
                print(self.postids)
            }
            completed()
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
        print("Feeds : ", self.feeds)
        cell.feedDescription.text = feeds[indexPath.row].feedDescription
        cell.feedPostUser.text = feeds[indexPath.row].feedPostUser
        cell.feedPostUserImg.downloadImage(from: feeds[indexPath.row].feedPostUserImg)
        cell.lastCommentUserIMg.downloadImage(from: feeds[indexPath.row].lastCommentUserImg)
        cell.feedImage.downloadImage(from: feeds[indexPath.row].feedImage)
        cell.likes.text = String(feeds[indexPath.row].likes)
        if(feeds[indexPath.row].isLiked){
            //            cell.feedLikeButton.isSelected = true
            cell.likedByYouLabel.text = "Liked By You and \(feeds[indexPath.row].likes - 1) others"
            cell.likedByYouLabel.isHidden = false
        }else{
            cell.likedByYouLabel.text = "Liked By \(feeds[indexPath.row].likes) people"
            cell.likedByYouLabel.isHidden = true
        }
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
        
        if let commentViewController = storyboard?.instantiateViewController(withIdentifier: "commentViewController") as? CommentViewController {
            // Pass Data
            // secondViewController.feed = feeds[tappedIndexPath.row]
            commentViewController.postid = self.postids[tappedIndexPath.row]
            // Present Second View
            navigationController?.pushViewController(commentViewController, animated: true)
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
            
            //Grabbing the nearrest tabBarController and then its nearest navController then poping
            tabBarController?.navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    func feedTableViewCellDidTapLike(_ sender: FeedCell) {
        
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        let index = IndexPath(row: tappedIndexPath.row, section: 0)
        let cell: FeedCell = self.tableView.cellForRow(at: index) as! FeedCell
        
        //Getting the likes from the UI
        if let like = cell.likes.text {
            likesCount = Int(like)!
        }else{
            print("Zero likes")
        }
        print("POST IDs :",self.postids)
        self.refDatabase.child("posts").child(self.postids[tappedIndexPath.row]).child("likedBy").observeSingleEvent(of :.value, with: { (snap) in
            var idFound = false
            //If the user has already liked the image : decrease like on that post by one
            if let likedBysnap = snap.value as? [String : String]{
                
                var key = String()
                for (k,id) in likedBysnap{
                    if id == Auth.auth().currentUser?.uid {
                        idFound  = true
                        key = k
                    }
                }
                if(idFound == true){
                    self.postDislike(indexRow : tappedIndexPath.row, key : key)
                }else{
                    self.postLike(indexRow : tappedIndexPath.row)
                }
            }
          
            self.fetchFeed {
                self.tableView.remembersLastFocusedIndexPath = true
                self.tableView.reloadData()
            }
        })
    }
    
    func postLike(indexRow : Int){
        self.likesCount = self.likesCount + 1;
        let likes = ["likes" : self.likesCount]
        self.refDatabase.child("posts").child(self.postids[indexRow]).updateChildValues(likes)
        let key = self.refDatabase.child("posts").childByAutoId().key
        let likedBy = ["likedBy/\(key)" : Auth.auth().currentUser?.uid]
        self.refDatabase.child("posts").child(self.postids[indexRow]).updateChildValues(likedBy)
    }
    
    func postDislike(indexRow : Int, key : String){
        self.likesCount = self.likesCount - 1;
        let likes = ["likes" : self.likesCount]
        self.refDatabase.child("posts").child(self.postids[indexRow]).updateChildValues(likes)
        self.refDatabase.child("posts").child(self.postids[indexRow]).child("likedBy/\(key)").removeValue()
    }

}
