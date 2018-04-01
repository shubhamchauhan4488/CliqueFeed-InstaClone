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
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationController?.navigationBar.isHidden = false
        print("THIIIsSsssssSSSS here is the feed paassed : \(feed.feedDescription!)")
        tableView.delegate = self
        tableView.dataSource = self
        self.fetchComments()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
        
        cell.textLabel?.text = self.feed.feedDescription
        return cell
    }
    
    func fetchComments(){
        self.refDatabase.child("postsWithComments").observeSingleEvent(of: .value, with: { (snap) in
            print("entered posts in database")
            let postsWithCommentssnap = snap.value as! Dictionary<String, AnyObject>
            print()
            let postingUsers = postsWithCommentssnap as! [Dictionary<String,AnyObject>]
            
            for (k,userPosts) in postingUsers{
                print("*****////*****")
                
                
        })
    }

    


}
