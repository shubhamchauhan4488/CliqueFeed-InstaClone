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
import FaveButton
import ListPlaceholder
import SwiftPullToRefresh

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FeedTableViewCellDelegate {

    var feeds = [Feed]()
    var postids = [String]()
    var following = [String]()
    var feedUsers = [User]()
    var comments = [String]()
    var commentUserImageUrl : String!
    var currentUserImagePath = String()
    var counter = 0
    var likesCount = 0
    var refDatabase : DatabaseReference!
    
    typealias downloadData = () -> ()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //faveButton.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        let key = "esf32rradasdwd"
        let following = ["following/\(key)" : Auth.auth().currentUser?.uid]
        refDatabase = Database.database().reference()
        refDatabase.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(following)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        print("vWA : " ,feeds)
     
        self.postids = []
        self.following = []
        refDatabase = Database.database().reference()
        
        fetchFeed {
            print("after : " ,self.feeds)
            self.tableView.remembersLastFocusedIndexPath = false
                self.tableView.reloadData()
        }
        
        guard
            let url = Bundle.main.url(forResource: "loader", withExtension: "gif"),
            let data = try? Data(contentsOf: url) else { return }
        
         self.tableView.spr_setGIFHeader(data: data, isBig: false, height: 120) { [weak self] in
            self?.fetchFeed {
                print("after : " ,self?.feeds)
                self?.tableView.remembersLastFocusedIndexPath = false
                self?.tableView.reloadData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired number of seconds
               self?.tableView?.spr_endRefreshing()
            }
            
        }
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
    func fetchFeed(completed : @escaping downloadData){
        
        refDatabase.child("users").observe(.value, with: { (snapshot) in
            
            let usersnap = snapshot.value as! [String : AnyObject]
            for(_, value) in usersnap{
                if let userid = value["uid"] as? String{
                    if userid == Auth.auth().currentUser?.uid{
                        self.following.append((Auth.auth().currentUser?.uid)!)
                        if let followingUsers = value["following"] as? [String:String]{
                            self.feedUsers = []
                            for(_, userid) in followingUsers{
                                self.following.append(userid)
                                
                                for(k, v) in usersnap{
                                    if userid == k {
                                        //print("Appending \(v["name"])")
                                        let user = User(name : v["name"] as! String, uid:  userid, imagePath : v["urlImage"] as! String)
                                        //print(user)
                                        self.feedUsers.append(user)
                                        //                                        print("************")
                                        print("feedUsers : ",self.feedUsers)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
        
        self.refDatabase.child("posts").observe(.value, with: { (snap) in
            
            
            //Since we are observing posts, this block will be called whenever we try to access its childs. So we clear feeds array as it will be loaded again from the databse
            self.feeds = []
            self.postids = []
            if let postsnap = snap.value as? Dictionary<String, AnyObject>{
                
                for (ke,userPosts) in postsnap{
                    if let details = userPosts as? Dictionary<String, AnyObject>{
                        print("FEEDUSERS: " ,self.feedUsers)
                        
                        for i in self.feedUsers{
                            var isLiked = false
                            if i.uid == Auth.auth().currentUser?.uid{
                                self.currentUserImagePath = i.imagePath
                            }
                            if i.uid == details["uid"] as? String
                            {
                                
                                if let likedByDict = details["likedBy"] as? Dictionary<String, AnyObject>{
                                    for (_ , likedByUserId) in likedByDict{
                                        if likedByUserId as? String == Auth.auth().currentUser?.uid{
                                            isLiked = true
                                            
                                        }
                                    }
                                }
                                print("isLiked : ", isLiked)
                                let fedd = Feed(feedPostUserImg:  i.imagePath, feedImage: details["urlImage"] as! String, feedPostUser: i.name, feedDescription: details["comment"] as! String, lastCommentUserImg: self.currentUserImagePath,likes : details["likes"] as! Int,isLiked : isLiked, timeStamp: details["timestamp"] as! Double,id: ke)
                                self.feeds.append(fedd)
                            }
                        }
                    }
                }
                print("^^^^^^^^^^^^")
                self.feeds = self.feeds.sorted(by: { $0.timeStamp > $1.timeStamp })
                for i in 0..<self.feeds.count{
                    self.postids.append(self.feeds[i].uid)
                }
                print(self.postids)
            }
            print("Before : " ,self.feeds)
            completed()
        }
            
        )
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(feeds.count)
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell
        //cell.feedLikeButton.imageView?.image = UIImage(named : "Comment Icon")
        //cell.addSubview(faveButton)
        
        //faveButton.translatesAutoresizingMaskIntoConstraints = true
        //faveButton.leadingAnchor.constraint(equalTo: cell.feedView.leadingAnchor,constant : 20).isActive = true
        //        faveButton.trailingAnchor.constraint(equalTo: cell.feedView.trailingAnchor).isActive = true
        //faveButton.bottomAnchor.constraint(equalTo: cell.separatorView.bottomAnchor,constant: -10).isActive = true
        //faveButton.topAnchor.constraint(equalTo: cell.feedImage.bottomAnchor , constant: 10).isActive = true
        //                faveButton.heightAnchor.constraint(equalTo: cell.feedView.heightAnchor,multiplier: 0.45).isActive = true
        
        
        print("configure cell : " ,feeds)
        
        cell.feedDescription.text = feeds[indexPath.row].feedDescription
        cell.feedPostUser.text = feeds[indexPath.row].feedPostUser
        cell.feedPostUserImg.downloadImage(from: feeds[indexPath.row].feedPostUserImg)
        //Image added using extension
        cell.feedImage.downloadImage(from: feeds[indexPath.row].feedImage)
        //print(feeds[indexPath.row].feedImage);
        cell.lastCommentUserIMg.downloadImage(from: feeds[indexPath.row].lastCommentUserImg)
        cell.likes.text = String(feeds[indexPath.row].likes)
        if(feeds[indexPath.row].isLiked){
            //            cell.feedLikeButton.isSelected = true
            cell.likedByYouLabel.text = ",Liked By You and \(feeds[indexPath.row].likes - 1) others"
            cell.likedByYouLabel.isHidden = false
        }else{
            cell.likedByYouLabel.text = ",Liked By \(feeds[indexPath.row].likes) people"
            cell.likedByYouLabel.isHidden = true
        }
        //Getting the difference between current date and timestamp with the help of Date extension
        //WHY if we place this above getting cell.feedDescription.text it is giving error?
        let date = Date()
        let x = date.offset(from: Date(timeIntervalSince1970: feeds[indexPath.row].timeStamp))
        cell.timePosted.text = x
        cell.delegate = self
        return cell
    }
    
    
    
    //Fixing cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 450
    }
    
    //Conforming to FeedTableViewCelldelegate : On Comment Tap
    func feedTableViewCellDidTapComment(_ sender: FeedCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        print("Comm", sender, tappedIndexPath)
        
        if let commentViewController = storyboard?.instantiateViewController(withIdentifier: "commentViewController") as? CommentViewController {
            commentViewController.postid = self.postids[tappedIndexPath.row]
            // Present Second View
            navigationController?.pushViewController(commentViewController, animated: true)
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
    
    func feedTableViewCellDidTapTrash(_ sender: FeedCell) {
        return 
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
                    //                    cell.feedLikeButton.imageView?.image = UIImage(named: "Like Icon")
                    self.postDislike(indexRow : tappedIndexPath.row, key : key)
                }else{
                    
                    self.postLike(indexRow : tappedIndexPath.row, cell : cell)
                }
            }
            self.feeds = []
            self.fetchFeed {
                self.tableView.remembersLastFocusedIndexPath = true
                self.tableView.reloadData()
            }
        })
    }
    
    func postLike(indexRow : Int, cell : FeedCell){
        self.likesCount = self.likesCount + 1;
        let likes = ["likes" : self.likesCount]
        self.refDatabase.child("posts").child(self.postids[indexRow]).updateChildValues(likes)
        let key = self.refDatabase.child("posts").childByAutoId().key
        let likedBy = ["likedBy/\(key)" : Auth.auth().currentUser?.uid]
        self.refDatabase.child("posts").child(self.postids[indexRow]).updateChildValues(likedBy)
        //        cell.feedLikeButton.imageView?.image = UIImage(named: "likeRedImage")
    }
    
    func postDislike(indexRow : Int, key : String){
        self.likesCount = self.likesCount - 1;
        let likes = ["likes" : self.likesCount]
        self.refDatabase.child("posts").child(self.postids[indexRow]).updateChildValues(likes)
        self.refDatabase.child("posts").child(self.postids[indexRow]).child("likedBy/\(key)").removeValue()
    }
}


