//
//  UsersViewController.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 21/03/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import AnimatableReload

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UserTableViewCellProtocol, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var users = [User]()
    var followingUserids = [String]()
    var filteredUsers = [User]()
    var isSearchActive : Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isSearchActive = false
        tableView.setContentOffset(.zero, animated: true)
        retrieveData()
        //        AnimatableReload.reload(tableView: self.tableView, animationDirection: "up")
    }
    
    
    func retrieveData(){
        
        let ref = Database.database().reference()
        print("ENTERED retrieve data FUNCTION")
        
        //Listen in real time whenever it updates by observeSingleEvent of eventType : value
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.users.removeAll()
            
            if let firebaseusers = snapshot.value as? Dictionary<String, AnyObject>{
                
                for (_, value) in firebaseusers{
                    if let uid = value["uid"] as? String{
                        if(uid != Auth.auth().currentUser?.uid){
                            let userToShow = User()
                            if let name = value["name"] as? String, let imagePath = value["urlImage"] as? String{
                                userToShow.name = name
                                userToShow.imagePath = imagePath
                                userToShow.uid = uid
                                //                                print(userToShow.name)
                                self.users.append(userToShow)
                            }
                        }else{
                            print("---------")
                            print("ENTERED ELSE")
                            print("Current user :",Auth.auth().currentUser?.uid)
                            
                            if let followingUsers = value["following"] as? [String:String]{
                                self.followingUserids = []
                                for(_, user) in followingUsers{
                                    self.followingUserids.append(user)
                                    print("followingUserids :", self.followingUserids)
                                }
                            }
                        }
                        print("_________________+++++++++++++++++++______________")
                        //                        print(self.followingUserids)
                    }
                    
                }
                self.tableView.reloadData()
                //                AnimatableReload.reload(tableView: self.tableView, animationDirection: "up")
            }
        }) { (error) in
            print(error)
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchActive{
            return filteredUsers.count
        }else{
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserCell{
            
            cell.delegate = self
            cell.tag = indexPath.row
            cell.followUnfollowBtn.tag = indexPath.row
            if isSearchActive{
                
                cell.configure(username: self.filteredUsers[indexPath.row].name, imageURL: filteredUsers[indexPath.row].imagePath!, userID: self.filteredUsers[indexPath.row].uid, isFollowing: followingUserids.contains(filteredUsers[indexPath.row].uid))
            }else{
                
                cell.configure(username: self.users[indexPath.row].name, imageURL: users[indexPath.row].imagePath!, userID: self.users[indexPath.row].uid, isFollowing: followingUserids.contains(users[indexPath.row].uid))
                
            }
            return cell
            
        }else {
            print("Unable to load TableView")
            return UITableViewCell()
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchBar.text == nil || searchBar.text == "")
        {
            isSearchActive = false
            view.endEditing(true)
        }
        else
        {
            isSearchActive = true
            let searchItem = searchBar.text!.lowercased()
            filteredUsers = users.filter({$0.name.lowercased().range(of: searchItem) != nil})
            print("@@@@@@@@@@@@ USERS IS FILTERED @@@@@@@@@@@@@@")
        }
        retrieveData()
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        tableView.setContentOffset(.zero, animated: true)
        retrieveData()
    }
    
    func userTableViewCellDidTapFollowUnfollow(_ tag: Int) {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let key = ref.child("users").childByAutoId().key
        var isFollower = false
        
        ref.child("users").child(uid!).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with:
            { (snapshot) in
                
                if let following = snapshot.value as? [String : AnyObject] {
                    for(k, value) in following{
                        if self.isSearchActive{
                            if value as! String == self.filteredUsers[tag].uid{
                                
                                isFollower = true
                                print("IAM INSIDE UN FOLLOW METHOD")
                                ref.child("users").child(uid!).child("following/\(k)").removeValue()
                                ref.child("users").child(self.filteredUsers[tag].uid).child("followers/\(k)").removeValue()
                                //                            self.followingUserids.remove(at: tag)
                                
                                let newcell =  self.tableView.cellForRow(at: IndexPath(row: tag, section: 0)) as! UserCell
                                newcell.followUnfollowBtn.imageView?.image = UIImage(named : "Follow_icon")
                                
                            }
                        }else{
                            if value as! String == self.users[tag].uid{
                                
                                isFollower = true
                                print("IAM INSIDE UN FOLLOW METHOD")
                                ref.child("users").child(uid!).child("following/\(k)").removeValue()
                                ref.child("users").child(self.users[tag].uid).child("followers/\(k)").removeValue()
                                
                                let newcell =  self.tableView.cellForRow(at: IndexPath(row: tag, section: 0)) as! UserCell
                                newcell.followUnfollowBtn.imageView?.image = UIImage(named : "Follow_icon")
                                
                            }
                        }
                    }
                }
                
                if  !isFollower {
                    
                    if self.isSearchActive{
                        let following = ["following/\(key)" : self.filteredUsers[tag].uid]
                        let followers = ["followers/\(key)" : uid]
                        
                        ref.child("users").child(uid!).updateChildValues(following)
                        ref.child("users").child(self.filteredUsers[tag].uid).updateChildValues(followers)
                        
                        let newcell =  self.tableView.cellForRow(at: IndexPath(row: tag, section: 0)) as! UserCell
                        newcell.followUnfollowBtn.imageView?.image = UIImage(named : "Following_icon")
                    }else{
                        
                        let following = ["following/\(key)" : self.users[tag].uid]
                        let followers = ["followers/\(key)" : uid]
                        
                        ref.child("users").child(uid!).updateChildValues(following)
                        ref.child("users").child(self.users[tag].uid).updateChildValues(followers)
                        
                        let newcell =  self.tableView.cellForRow(at: IndexPath(row: tag, section: 0)) as! UserCell
                        newcell.followUnfollowBtn.imageView?.image = UIImage(named : "Following_icon")
                        
                    }
                }
                self.retrieveData()
        })
    }
    
}

let imageCache = NSCache<AnyObject, AnyObject>();
extension UIImageView{
    func downloadImage(from imgurl : String){
        
        //check cache for the image first
        if let cachedImage = imageCache.object(forKey: imgurl as AnyObject) as? UIImage
        {
            self.image = cachedImage
            return;
        }
        
        let urlRequest = URLRequest(url: URL(string: imgurl)!)
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if(error != nil){
                print("Image could not be downloaded from URL : \(error)")
                return
            }
            //Whenever u have to update the UI u have to do it in main thread, otherwise it will crash/
            DispatchQueue.main.async {
                
                if let downloadedImage = UIImage(data : data!){
                    imageCache.setObject(downloadedImage, forKey: imgurl as AnyObject)
                    self.image = downloadedImage
                }
            }
            }.resume()
    }
}

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


