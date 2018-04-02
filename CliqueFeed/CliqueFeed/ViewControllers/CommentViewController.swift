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
    var comments : [Comment]!
    
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
                print(posts)
                let postsarray = posts as! Dictionary<String,AnyObject>
                for (k,v) in postsarray{
                    print(self.postid)
                        if k == self.postid{
                            let postinguserdetails = v as! Dictionary<String,AnyObject>
                            for (_,ve) in postinguserdetails{
                                print("/////*******/////")
                                print(ve["uid"])
                                self.uid = ve["uid"] as! String
                                
                                
                                self.ref.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
                                    let usersnap = snapshot.value as! [String : AnyObject]
                                    for(k, value) in usersnap{
                                        if let userid = k as? String{
                                            if self.uid! == userid{
                                                print(":::::::::::::")
                                                print(userid)
                                                print(self.uid!)
                                                let com = Comment()
                                                com.postingUserImg = value["urlImage"] as! String
                                                com.postinguserName = value["name"] as! String
                                                com.postingUserComment = ve["comment"] as! String
                                                
                                                print(com.postingUserImg)
                                                print(com.postinguserName)
                                                self.comments.append(com)
//                                                print(self.comments)
                                            }
                                        }
                                    }
                                    print(self.comments.count)
                                    self.tableView.reloadData()
                                })
                                
                            }
                        }
                }
                self.refDatabase.removeAllObservers()
            }
        })
    }

    


}
