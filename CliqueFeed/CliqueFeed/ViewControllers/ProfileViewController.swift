//
//  ProfileViewController.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 01/04/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.

import UIKit
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth
import GoogleSignIn
import MBCircularProgressBar

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FeedTableViewCellDelegate {
    
    @IBOutlet weak var profileStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var followersProgressView: MBCircularProgressBarView!
    @IBOutlet weak var followingProgressView: MBCircularProgressBarView!
    
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
    let date = Date()
    var profileUserId = String()
    var isOtherUser = true
    var isProfileUserIdSet = false
    var currentUserImagePath = String()
    
    typealias fetchUserPosts = () -> ()
    typealias getPostsData = () -> ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        profileImg.layer.borderWidth = 2
        profileImg.layer.borderColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8).cgColor
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //ProgressView Animations
        UIView.animate(withDuration: 1.5) {
            self.followersProgressView.value = CGFloat(UserDefaults.standard.integer(forKey: "noOfFollowers"))
        }
        UIView.animate(withDuration: 1.5) {
            self.followingProgressView.value = CGFloat(UserDefaults.standard.integer(forKey: "noOfFollowings") - 1 )
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profileImg.isUserInteractionEnabled = true
        profileImg.addGestureRecognizer(tapGestureRecognizer)
        
        if profileUserId == ""{
            profileUserId = (Auth.auth().currentUser?.uid)!
            self.backBtn.isHidden = true
            isOtherUser = false
            profileStackTopConstraint.constant = 15
            self.tabBarController?.tabBar.isHidden = false
        }
        
        //Other user's profile page
        if (isProfileUserIdSet){
            self.navigationController?.setNavigationBarHidden(true, animated: true)
            self.tabBarController?.tabBar.isHidden = true
            profileImg.isUserInteractionEnabled = false
        }
        
        //Setting initial values for Progressviews
        self.followingProgressView.value = 0
        self.followersProgressView.value = 0
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 255.0/255.0, green: 46.0/255.0, blue: 147.0/255.0, alpha: 0.8)
        metaFeeds = []
        refDatabase = Database.database().reference()
        fetchFeed {
            self.fetchUserPosts{
                self.tableView.remembersLastFocusedIndexPath = true
                self.tableView.reloadData()
                //Setting max value to present values so that the progress view is always 100%
                self.followersProgressView.maxValue =  CGFloat(UserDefaults.standard.integer(forKey: "noOfFollowers"))
                self.followingProgressView.maxValue =  CGFloat(UserDefaults.standard.integer(forKey: "noOfFollowings") - 1 )
            }
        }
    }
    
    //When Other user's profile was displayed, revert to showing the nav bar
    override func viewWillDisappear(_ animated: Bool) {
        if(isProfileUserIdSet){
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.refDatabase.child("users").removeAllObservers()
    }
    
    func fetchFeed(completed : @escaping fetchUserPosts){
        
        refDatabase.child("users").observe(.value, with: { (snapshot) in
            
            let usersnap = snapshot.value as! [String : AnyObject]
            for(id, value) in usersnap{
                if let userid = id as? String{
                    if userid == self.profileUserId{
                        
                        if let followers = value["followers"] as? [String:String]{
                            UserDefaults.standard.set(followers.count, forKey: "noOfFollowers")
                        }
                        if let followingUsers = value["following"] as? [String:String]{
                            UserDefaults.standard.set(followingUsers.count, forKey: "noOfFollowings")
                        }
                        self.user = User(name : value["name"] as! String, email : value["email"] as! String, uid:  userid, imagePath : value["urlImage"] as! String)
                        self.profileImg.downloadImage(from: self.user.imagePath)
                        self.name.text = self.user.name
                        
                    }
                }
            }
            completed()
        })
    }
    
    
    func fetchUserPosts(completed : @escaping getPostsData){
        self.refDatabase.child("posts").observe(.value, with: { (snap) in
            
            self.feeds = []
            self.postids = []
            if let postsnap = snap.value as? Dictionary<String, AnyObject>{
                for (ke,userPosts) in postsnap{
                    if let details = userPosts as? Dictionary<String, AnyObject>{
                        let currentUserId = self.profileUserId
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
                            //                            if self.currentUserImagePath == "" {
                            //                                self.currentUserImagePath = self.user.imagePath
                            //                            }
                            let fedd = Feed(feedPostUserImg:  self.user.imagePath, feedImage: details["urlImage"] as! String, feedPostUser: self.user.name, feedDescription: details["comment"] as! String, lastCommentUserImg: CurrentUser.sharedInstance.imagePath,likes : details["likes"] as! Int, isLiked : isLiked, timeStamp: details["timestamp"] as! Double,id: ke, userID : self.profileUserId)
                            self.feeds.append(fedd)
                            
                        }
                    }
                }
                
                //                print("^^^^^^^^^^^^")
                //                print("Feeds : ", self.feeds)
                self.feeds = self.feeds.sorted(by: { $0.timeStamp > $1.timeStamp })
                for i in 0..<self.feeds.count{
                    self.postids.append(self.feeds[i].id)
                }
                //                print(self.postids)
            }
            completed()
        })
        
    }
    
    func sortfeeds(){
        self.feeds = self.feeds.sorted(by: { $0.timeStamp > $1.timeStamp })
        self.postids = []
        for i in 0..<self.feeds.count{
            self.postids.append(self.feeds[i].id)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell
        cell.delegate = self
        let timePostedString = date.offset(from: Date(timeIntervalSince1970: feeds[indexPath.row].timeStamp))
        
        cell.configure(feedDescription: feeds[indexPath.row].feedDescription, feedPostUserName: feeds[indexPath.row].feedPostUser, feedPostUserImgURL: feeds[indexPath.row].feedPostUserImg, lastCommentUserImgURL: feeds[indexPath.row].lastCommentUserImg, feedImageURL: feeds[indexPath.row].feedImage, likes: feeds[indexPath.row].likes, isLiked: feeds[indexPath.row].isLiked, timePosted : timePostedString, isOtherUser : isOtherUser)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 580
    }
    
    //Conforming to FeedTableViewCelldelegate
    func feedTableViewCellDidTapComment(_ sender: FeedCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        
        if let commentViewController = storyboard?.instantiateViewController(withIdentifier: "commentViewController") as? CommentViewController {
            // Pass Data
            commentViewController.postid = self.postids[tappedIndexPath.row]
            navigationController?.pushViewController(commentViewController, animated: true)
        }
        
    }
    
    func feedTableViewCellDidTapPost(_ sender: FeedCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        
        let index = IndexPath(row: tappedIndexPath.row, section: 0)
        let cell: FeedCell = self.tableView.cellForRow(at: index) as! FeedCell
        let timeInterval = NSDate().timeIntervalSince1970
        if (cell.commentText.text != ""){
            cell.postBtn.isEnabled = true
            let comments = ["comment" : cell.commentText.text!,
                            "uid" : Auth.auth().currentUser?.uid,
                            "timestamp" : timeInterval] as [String : Any]
            
            refDatabase.child("postsWithComments").child(self.postids[tappedIndexPath.row]).childByAutoId().updateChildValues(comments)
        }
        
        
    }
    
    func feedTableViewCellDidTapTrash(_ sender: FeedCell) {
        guard let tappedIndexPath = tableView.indexPath(for: sender) else { return }
        let index = IndexPath(row: tappedIndexPath.row, section: 0)
        let alertBox = UIAlertController(title: "Delete Post", message: "Are you sure to delete this Post", preferredStyle:.alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.refDatabase.child("posts").child(self.postids[tappedIndexPath.row]).removeValue()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        alertBox.addAction(cancelAction)
        alertBox.addAction(okAction)
        self.present(alertBox, animated:true)
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
    
    @IBAction func onLogoutClick(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            GIDSignIn.sharedInstance().signOut()
            
            //Grabbing the nearrest tabBarController and then its nearest navController then poping
            tabBarController?.performSegue(withIdentifier: "logoutToLogin", sender: self)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
    @objc func imageTapped(){
        showEditProfileModal()
    }
    func showEditProfileModal(){
        performSegue(withIdentifier: "profileToModal", sender: self)
        //        editProfileModalViewController.isModalInPopover = true
        //        editProfileModalViewController.modalPresentationStyle = .overCurrentContext
        //        present(editProfileModalViewController, animated: true, completion: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "profileToModal"{
            var editProfileModalViewController = segue.destination as! EditProfileModalController
            editProfileModalViewController.user = self.user
        }
    }   
    
    @IBAction func onBackClick(_ sender: Any) {
        UserDefaults.standard.set(1, forKey: "noOfFollowings")
        UserDefaults.standard.set(0, forKey: "noOfFollowers")
        self.navigationController?.popViewController(animated: true)
    }
    
    func feedTableViewCellDidTapUserImage(_ sender: FeedCell) {
        
    }
    
    func feedTableViewCellDidTapFeedImage(_ sender: FeedCell) {
        
    }
    
}
