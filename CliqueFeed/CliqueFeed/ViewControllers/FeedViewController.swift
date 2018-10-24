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
    var counter = 0
    var likesCount = 0
    var refDatabase : DatabaseReference!
    var userDefaults = UserDefaults.standard
    var date = Date()
    let postViewControllerSelectedIndex = 2
    let usersViewControllerSelectedIndex = 3
    var verticalContentOffset  = CGFloat()
    var isZooming = false

    typealias downloadData = () -> ()
    
    @IBOutlet weak var overlayViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var overlayViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var ImageOverlayView: UIVisualEffectView!
    @IBOutlet weak var clickedImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var mainFeedView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(sender:)))
        self.clickedImage.addGestureRecognizer(pinch)
        tableView.delegate = self
        tableView.dataSource = self
        let key = "esf32rradasdwd"
        let following = ["following/\(key)" : Auth.auth().currentUser?.uid]
        refDatabase = Database.database().reference()
        refDatabase.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(following)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view = mainFeedView
        self.tabBarController?.tabBar.isHidden = false
        print("vWA : " ,feeds)
        
        self.postids = []
        self.following = []
        refDatabase = Database.database().reference()
        //indicator Even before anything appears on the screen(WIll be visible in slow net connections)
        indicator.startAnimating()
        fetchFeed {
            print("after : " ,self.feeds)
          
            self.tableView.remembersLastFocusedIndexPath = true
            self.tableView.reloadData()
            self.tableView.setContentOffset(CGPoint(x : 0, y : self.verticalContentOffset), animated: false)
            if self.feeds.count == 0{
                let alertBox = UIAlertController(title: "No Posts to Display", message: "Follow Someone or Create Your own post", preferredStyle:.alert)
                let createAction = UIAlertAction(title: "Create", style: .default, handler: { (action) in
                    if let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "PostViewController") as? PostViewController {
                        self.navigationController?.popViewController(animated: true)
                        self.tabBarController?.selectedIndex = self.postViewControllerSelectedIndex
                    }
                })
                let followAction = UIAlertAction(title: "Follow", style: .default, handler: { (action) in
                    if let usersViewController = self.storyboard?.instantiateViewController(withIdentifier: "UsersViewController") as? UsersViewController {
                        self.navigationController?.popViewController(animated: true)
                        self.tabBarController?.selectedIndex = self.usersViewControllerSelectedIndex
                    }
                })
                alertBox.addAction(createAction)
                alertBox.addAction(followAction)
                self.present(alertBox, animated:true)
            }
            self.indicator.stopAnimating()
        }
        
        guard
            let url = Bundle.main.url(forResource: "loader", withExtension: "gif"),
            let data = try? Data(contentsOf: url) else { return }
        
        self.tableView.spr_setGIFHeader(data: data, isBig: false, height: 120) { [weak self] in
            self?.fetchFeed {
                print("after : " ,self?.feeds)
        
                self?.tableView.reloadData()
                //Giving delay so that if data is fetchde quickly, the animation can still complete in 2 sec
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                    self?.tableView?.spr_endRefreshing()
                }
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
                        
                        if let followers = value["followers"] as? [String:String]{
                            self.userDefaults.set(followers.count, forKey: "noOfFollowers")
                        }
                        
                        self.following.append((Auth.auth().currentUser?.uid)!)
                        if let followingUsers = value["following"] as? [String:String]{
                            self.feedUsers = []
                            self.userDefaults.set(followingUsers.count, forKey: "noOfFollowings")
                            for(_, userid) in followingUsers{
                                self.following.append(userid)
                                
                                for(k, v) in usersnap{
                                    if userid == k {
                                        //print("Appending \(v["name"])")
                                        let user = User(name : v["name"] as! String, email : v["email"] as! String, uid:  userid, imagePath : v["urlImage"] as! String)
                                        //print(user)
                                        self.feedUsers.append(user)
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
                                CurrentUser.sharedInstance.imagePath = i.imagePath
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
                               
                                let fedd = Feed(feedPostUserImg:  i.imagePath, feedImage: details["urlImage"] as! String, feedPostUser: i.name, feedDescription: details["comment"] as! String, lastCommentUserImg: CurrentUser.sharedInstance.imagePath,likes : details["likes"] as! Int,isLiked : isLiked, timeStamp: details["timestamp"] as! Double,id: ke, userID : i.uid)
                                self.feeds.append(fedd)
                            }
                        }
                    }
                }
                print("^^^^^^^^^^^^")
                self.feeds = self.feeds.sorted(by: { $0.timeStamp > $1.timeStamp })
                for i in 0..<self.feeds.count{
                    self.postids.append(self.feeds[i].id)
                }
                print(self.postids)
            }
            print("Before : " ,self.feeds)
            completed()
        })
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(feeds.count)
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as? FeedCell{

            print("configure cell : " ,feeds)
            cell.delegate = self

            //Getting the difference between current date and timestamp with the help of Date extension
            //WHY if we place this above getting cell.feedDescription.text it is giving error?
            let timePostedString = date.offset(from: Date(timeIntervalSince1970: feeds[indexPath.row].timeStamp))
            cell.configure(feedDescription: feeds[indexPath.row].feedDescription, feedPostUserName: feeds[indexPath.row].feedPostUser, feedPostUserImgURL: feeds[indexPath.row].feedPostUserImg, lastCommentUserImgURL: feeds[indexPath.row].lastCommentUserImg, feedImageURL: feeds[indexPath.row].feedImage, likes: feeds[indexPath.row].likes, isLiked: feeds[indexPath.row].isLiked, timePosted : timePostedString, isOtherUser: true)

            return cell
        }
        else{
            return UITableViewCell()
        }
    }
    
    //Fixing cell height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 580
    }
    
    //Conforming to FeedTableViewCelldelegate : On Comment Tap
    func feedTableViewCellDidTapComment(_ sender: FeedCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        print("Comm", sender, tappedIndexPath)
        pushCommentViewController(tappedIndexpath : tappedIndexPath)
    }
    
    func pushCommentViewController(tappedIndexpath : IndexPath){
        if let commentViewController = storyboard?.instantiateViewController(withIdentifier: "commentViewController") as? CommentViewController {
            commentViewController.postid = self.postids[tappedIndexpath.row]
            // Present Second View
            navigationController?.pushViewController(commentViewController, animated: true)
        }
    }
    
    //Conforming to FeedTableViewCelldelegate : On Post Tap
    func feedTableViewCellDidTapPost(_ sender: FeedCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        let index = IndexPath(row: tappedIndexPath.row, section: 0)
        let cell: FeedCell = self.tableView.cellForRow(at: index) as! FeedCell
  
        if (cell.commentText.text?.count != 0){
            let timeInterval = NSDate().timeIntervalSince1970
            let comments = ["comment" : cell.commentText.text!,
                            "uid" : (Auth.auth().currentUser?.uid)!,
                            "timestamp" : timeInterval] as [String : Any]
            refDatabase.child("postsWithComments").child(self.postids[tappedIndexPath.row]).childByAutoId().updateChildValues(comments)
            counter = counter + 1
            
            pushCommentViewController(tappedIndexpath: tappedIndexPath)
        }else{
            let alertBox = UIAlertController(title: "Comment cannot be empty", message: "You need to comment in order to post", preferredStyle:.alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertBox.addAction(okAction)
            present(alertBox, animated: true, completion: nil)
        }
        
    }
    
    func feedTableViewCellDidTapTrash(_ sender: FeedCell) {
        return 
    }
    
    func feedTableViewCellDidTapLike(_ sender: FeedCell) {
        self.verticalContentOffset = self.tableView.contentOffset.y
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        let index = IndexPath(row: tappedIndexPath.row, section: 0)
        let cell: FeedCell = self.tableView.cellForRow(at: index) as! FeedCell
        
        //Getting the likes from the UI
        if let like = cell.likes.text {
            likesCount = Int(like)!
        }else{
            print("Zero likes")
        }
       
       print("postIDS", self.postids)
        self.refDatabase.child("posts").child(self.postids[tappedIndexPath.row]).child("likedBy").observeSingleEvent(of :.value, with: { (snap) in
            var idFound = false
            //If the user has already liked the image : decrease like on that post by one
            print("Snap", snap.value)
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
                    self.postLike(indexRow : tappedIndexPath.row, cell : cell)
                }
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
        cell.feedLikeButton?.setSelected(selected: true, animated: true)
        
    }
    
    func postDislike(indexRow : Int, key : String){
        
        self.likesCount = self.likesCount - 1;
        let likes = ["likes" : self.likesCount]
        self.refDatabase.child("posts").child(self.postids[indexRow]).updateChildValues(likes)
        self.refDatabase.child("posts").child(self.postids[indexRow]).child("likedBy/\(key)").removeValue()
        
    }
    
    func feedTableViewCellDidTapFeedImage(_ sender: FeedCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        if feeds[tappedIndexPath.row].feedImage.count != 0 {
            self.clickedImage.downloadImage(from: feeds[tappedIndexPath.row].feedImage)
        }else{
            self.clickedImage.image = UIImage(named : "cam")
        }
    
//        UIView.animate(withDuration: 1.6, animations: {
//            self.view = self.ImageOverlayView.contentView
//            self.overlayViewTrailingConstraint.constant = 0
//            self.overlayViewLeadingConstraint.constant = 0
//        })
//        self.view.resignFirstResponder()
        self.view = self.ImageOverlayView.contentView
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func backPressInImageOverlay(_ sender: Any) {
                self.view = self.mainFeedView
            self.tabBarController?.tabBar.isHidden = false
    }
    
    //Pinch to zoom on specific parts of the image
    @objc func pinch(sender:UIPinchGestureRecognizer) {
        if sender.state == .began {
            let currentScale = self.clickedImage.frame.size.width / self.clickedImage.bounds.size.width
            let newScale = currentScale*sender.scale
            if newScale > 1 {
                self.isZooming = true
            }
        } else if sender.state == .changed {
            guard let view = sender.view else {return}
            let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                      y: sender.location(in: view).y - view.bounds.midY)
            let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                .scaledBy(x: sender.scale, y: sender.scale)
                .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
            let currentScale = self.clickedImage.frame.size.width / self.clickedImage.bounds.size.width
            var newScale = currentScale*sender.scale
            if newScale < 1 {
                newScale = 1
                let transform = CGAffineTransform(scaleX: newScale, y: newScale)
                self.clickedImage.transform = transform
                sender.scale = 1
            }else {
                view.transform = transform
                sender.scale = 1
            }
        } else if sender.state == .ended {
            UIView.animate(withDuration: 0.3, animations: {
                self.clickedImage.transform = CGAffineTransform.identity
            }, completion: { _ in
                self.isZooming = false
            })
        }
    }
    
    func feedTableViewCellDidTapUserImage(_ sender: FeedCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        if let profileViewController = storyboard?.instantiateViewController(withIdentifier: "profileViewController") as? ProfileViewController {
            profileViewController.profileUserId = self.feeds[tappedIndexPath.row].userID
            profileViewController.isProfileUserIdSet = true
            navigationController?.pushViewController(profileViewController, animated: true)
        }
    }
    
    
}


