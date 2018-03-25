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


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    var feeds = [Feed]()
    @IBOutlet weak var tableView: UITableView!
    var refDatabase : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        refDatabase = Database.database().reference()
     downloadData()
    }
    
    func downloadData(){
        
        refDatabase.child("posts").childByAutoId().observeSingleEvent(of: .value) { (snapshot) in
            
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell
        
        cell.feedPostUser.text = feeds[indexPath.row].feedPostUser
        cell.lastComment.text = feeds[indexPath.row].lastComment
        
        
        return cell
        
        
    }
    

    
    
}
