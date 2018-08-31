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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FeedTableViewCellDelegate {
    
    var feeds = [Feed]()
    var postids = [String]()
    var following = [String]()
    var feedUsers = [User]()
    var comments = [String]()
    var commentUserImageUrl : String!
    var currentUserImagePath = String()
    var counter = 0
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var likeButton: FaveButton!
    var refDatabase : DatabaseReference!
    let faveButton = FaveButton(
        frame: CGRect(x:200, y:200, width: 44, height: 44),
        faveIconNormal: UIImage(named: "heart")
    )
    override func viewDidLoad() {
        super.viewDidLoad()
        //Adding tap gesture recognizer anywhere on the screen
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action:    #selector(self.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
       
        faveButton.delegate = self
       
        tableView.delegate = self
        tableView.dataSource = self
        let key = "esf32rradasdwd"
        let following = ["following/\(key)" : Auth.auth().currentUser?.uid]
         refDatabase = Database.database().reference()
        refDatabase.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(following)
    }
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        view.endEditing(true);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        refDatabase = Database.database().reference()
        postids = []
        feeds = []
       
        following = []
         feedUsers = []
        fetchFeed()
       
        //        tableView.showLoader()
        //        tableView.reloadData()
        self.navigationController?.navigationBar.isHidden = true
    }
    
    func fetchFeed(){

        refDatabase.child("users").observe(.value, with: { (snapshot) in
            self.postids = []
            self.feeds = []

             self.following = []
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
                                        print("Appending \(v["name"])")
                                        let user = User(name : v["name"] as! String, uid:  userid, imagePath : v["urlImage"] as! String)
                                        print(user)
                                        self.feedUsers.append(user)
//                                        print("************")
                                        print(self.feedUsers)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        })
 
        
        self.refDatabase.child("posts").observe(.value, with: { (snap) in

                if let postsnap = snap.value as? Dictionary<String, AnyObject>{
                        for (ke,userPosts) in postsnap{
                        if let details = userPosts as? Dictionary<String, AnyObject>{
                            print(self.feedUsers)
//                                let filterfeedusers = self.feedUsers.filter({ (user) -> Bool  in
//                                    user.uid == details["uid"] as! String
//                                })
                            for i in self.feedUsers{
                              
                                if i.uid == Auth.auth().currentUser?.uid{
                                    self.currentUserImagePath = i.imagePath
                                }
                                if i.uid == details["uid"] as! String
    
//                                if(filterfeedusers[0].uid == details["uid"] as! String )
                                {
                                print("Found the users with IDs")
//                                    print(filterfeedusers[0].name)
                                    let fedd = Feed(feedPostUserImg:  i.imagePath, feedImage: details["urlImage"] as! String, feedPostUser: i.name, feedDescription: details["comment"] as! String, lastCommentUserImg: self.currentUserImagePath, timeStamp: details["timestamp"] as! Double,id: ke)
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
                    self.tableView.reloadData()
            }})
       
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell
        
        cell.feedView.addSubview(faveButton)
        
        faveButton.translatesAutoresizingMaskIntoConstraints = false
        // 2
        faveButton.leadingAnchor.constraint(
            equalTo: cell.feedView.leadingAnchor).isActive = true
        faveButton.trailingAnchor.constraint(
            equalTo: cell.feedView.trailingAnchor).isActive = true
        faveButton.bottomAnchor.constraint(
            equalTo: cell.feedView.bottomAnchor,
            constant: -20).isActive = true
        // 3
        faveButton.heightAnchor.constraint(
            equalTo: cell.feedView.heightAnchor,
            multiplier: 0.65).isActive = true
        
        cell.feedDescription.text = feeds[indexPath.row].feedDescription
        cell.feedPostUser.text = feeds[indexPath.row].feedPostUser
        cell.feedPostUserImg.downloadImage(from: feeds[indexPath.row].feedPostUserImg)
        //Image added using extension
        cell.feedImage.downloadImage(from: feeds[indexPath.row].feedImage)
        print(feeds[indexPath.row].feedImage);
        cell.lastCommentUserIMg.downloadImage(from: feeds[indexPath.row].lastCommentUserImg)
        
        
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


