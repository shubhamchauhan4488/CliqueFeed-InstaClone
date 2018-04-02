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
    
    var feed : Feed!
    var postid : String!
    var refDatabase : DatabaseReference!
    var ref : DatabaseReference!
    var uid : String!
    var comments : [Comment] = []
    //var users  [user]()
    
    var userMeta : [UserIntermediate] = []
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        print("THIIIsSsssssSSSS here is the feed paassed : \(feed.feedDescription!)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refDatabase = Database.database().reference()
        ref = Database.database().reference()
        self.navigationController?.navigationBar.isHidden = false
        comments = []
        //users = []
        self.fetchComments()
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        
        cell.textLabel?.text = comments[indexPath.row].postinguserName
        cell.detailTextLabel?.text = comments[indexPath.row].postingUserComment
        cell.imageView?.downloadImage(from: comments[indexPath.row].postingUserImg)
        
        return cell
    }
    
    func fetchComments(){
        
        self.refDatabase.child("postsWithComments").observeSingleEvent(of: .value, with: { (snap) in
            print("entered comments in database")
            let postsWithCommentssnap = snap.value as! Dictionary<String, AnyObject>
            //            print(postsWithCommentssnap)
            if let posts = postsWithCommentssnap as? Dictionary<String,AnyObject>{
                let postsarray = posts as! Dictionary<String,AnyObject>
                for (k,v) in postsarray{
                    if k == self.postid{
                        let postinguserdetails = v as! Dictionary<String,AnyObject>
                        for (_,ve) in postinguserdetails{
                            if let uid = ve["uid"] as? String, let comment = ve["comment"] as? String {
                                let userObj = UserIntermediate(uid: uid, comment: comment)
                                self.userMeta.append(userObj)
                            }
                        }
                    }
                }
            }
            self.refDatabase.removeAllObservers()
        })
        
        self.refDatabase.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let usersnap = snapshot.value as? [String : AnyObject]{
                
                for user in self.userMeta {
                    let userkeys = usersnap.keys.filter({ (id) -> Bool in
                        id == user.uid
                    })
                    let newComment = Comment(postingUserImg: usersnap[userkeys[0]]!["urlImage"] as! String, postinguserName: usersnap[userkeys[0]]!["name"] as! String, postingUserComment: user.comment)
                    self.comments.append(newComment)
                }
                self.tableView.reloadData()
            }
        })
        
    }
    
    
    
    
}
