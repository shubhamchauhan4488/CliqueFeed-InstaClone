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


class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    var feeds = [Feed]()
    var following = [String]()
    @IBOutlet weak var tableView: UITableView!
    var refDatabase : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refDatabase = Database.database().reference()
        feeds = []
        fetchFeed()
        tableView.reloadData()
    }
    
    func fetchFeed(){
        
        refDatabase.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let usersnap = snapshot.value as! [String : AnyObject]
            for(_, value) in usersnap{
                if let userid = value["uid"] as? String{
                    if userid == Auth.auth().currentUser?.uid{
//                        let name = value["name"] as! String
//                        let userImageUrl = value["urlImage"] as! String
                        if let followingUsers = value["following"] as? [String:String]{
                            for(_, user) in followingUsers{
                                self.following.append(user)
                                print("users appended in following")
                            }
                        }
                        self.following.append((Auth.auth().currentUser?.uid)!)
                        
                        self.refDatabase.child("posts").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snap) in
                            print("entered posts in database")
                            let postsnap = snap.value as! Dictionary<String, AnyObject>
                            
                            for (_,userPosts) in postsnap{
                                // print("**********")
                                if let posts = userPosts as? [Dictionary<String, AnyObject>]{
                                    
                                    for postDetails in posts {
                                        if let details = postDetails as? Dictionary<String, AnyObject>{
                                            if let userID = details["uid"] as? String{
                                                //print(userID)
                                                //print(self.following)
                                                if   self.following.contains(userID) {
                                                    
                                                    let fedd = Feed()
                                                    print("feed created")
                                                    fedd.lastComment = details["comment"] as! String
                                                    fedd.feedImage = details["urlImage"] as! String
                                                    var name : String!
                                                    var userImageUrl: String!
                                                        for(k, value) in usersnap{
                                                            if k == userID{
                                                                    name = value["name"] as! String
                                                                    userImageUrl = value["urlImage"] as! String
                                                            }
                                                    }
                                                    fedd.feedPostUser = name
                                                    fedd.feedPostUserImg = userImageUrl
                                                    print(fedd.feedImage)
                                                    self.feeds.append(fedd)
                                                    
                                                }
                                            }
                                        }
                                        
                                    }
                                    self.tableView.reloadData()
                                    
                                }
                            }
                            print(self.feeds)
                            
                        })
                    }
                }

                self.refDatabase.removeAllObservers()
                //print(self.feeds)
            }
            
            
            //            let firebaseFeed = snapshot.value as! [String, AnyObject]
            //            if let innerData = firebaseFeed.value as? Dictionary<String, AnyObject>{
            //                if let
            
        })
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! FeedCell
        
//       cell.feedPostUser.text = feeds[indexPath.row].feedPostUser
        cell.lastComment.text = feeds[indexPath.row].lastComment
        cell.feedPostUser.text = feeds[indexPath.row].feedPostUser
        cell.feedPostUserImg.downloadImage(from: feeds[indexPath.row].feedPostUserImg)
        cell.feedImage.downloadImage(from: feeds[indexPath.row].feedImage)
        
        return cell
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 500
        
    }
    

    
    
}

//
//extension UIImageView{
//    func downloadImage(from imgurl : String){
//        let urlRequest = URLRequest(url: URL(string: imgurl)!)
//        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
//            if(error != nil){
//                print(error!)
//                return
//            }
//            //Whenever u have to update the UI u have to do it in main thread, otherwise it will crash
//            DispatchQueue.main.async {
//                self.image = UIImage(data : data!)
//            }
//        }
//        task.resume()
//    }
//}

