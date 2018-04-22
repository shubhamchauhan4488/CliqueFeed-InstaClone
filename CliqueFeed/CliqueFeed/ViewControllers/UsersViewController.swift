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
    }
    
    
    func retrieveData(){
        followingUserids = []
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
                                print("ENTERED")
                                userToShow.name = name
                                userToShow.imagePath = imagePath
                                userToShow.uid = uid
                                //                                print(userToShow.name)
                                self.users.append(userToShow)
                            }
                        }else{
                            print("---------")
                            print("ENTERED ELSE")
                            if let followingUsers = value["following"] as? [String:String]{
                                for(_, user) in followingUsers{
                                    self.followingUserids.append(user)
                                    print("users appended in following")
                                }
                            }
                        }
                        print("_________________+++++++++++++++++++______________")
//                        print(self.followingUserids)
                    }
                    
                }
//                self.tableView.setContentOffset(.zero, animated: true)
                AnimatableReload.reload(tableView: self.tableView, animationDirection: "up")
            }
        }) { (error) in
            print(error)
        }
        ref.removeAllObservers()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
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
                //            UIViewPropertyAnimator(duration: 3.0, curve: .easeIn) {
                //                }.startAnimation()
                //            cell.username.text = self.users[indexPath.row].name
                //            cell.userID = self.users[indexPath.row].uid
                cell.configure(username: self.users[indexPath.row].name, imageURL: users[indexPath.row].imagePath!, userID: self.users[indexPath.row].uid, isFollowing: followingUserids.contains(users[indexPath.row].uid))
                
                //            print("=============================")
                //            print(followingUserids);
            }
            //            cell.userimage.downloadImage(from: users[indexPath.row].imagePath!)
            return cell
            
        }else {
            print("There is some error")
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
//        tableView.setContentOffset(.zero, animated: true)
        retrieveData()
//        AnimatableReload.reload(tableView: self.tableView, animationDirection: "up")
    }
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //        let uid = Auth.auth().currentUser?.uid
    //        let ref = Database.database().reference()
    //        let key = ref.child("users").childByAutoId().key
    //        var isFollower = false
    //
    //        ref.child("users").child(uid!).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with:
    //         { (snapshot) in
    //
    //            if let following = snapshot.value as? [String : AnyObject] {
    //                for(k, value) in following{
    //                    if value as! String == self.users[indexPath.row].uid{
    //
    //                    isFollower = true
    //                    print("IAM INSIDE UN FOLLOW METHOD")
    //                    ref.child("users").child(uid!).child("following/\(k)").removeValue()
    //                    ref.child("users").child(self.users[indexPath.row].uid).child("followers/\(k)").removeValue()
    //
    //
    //                    let newcell =  tableView.cellForRow(at: indexPath) as! UserCell
    //                    newcell.followUnfollowBtn.imageView?.image = UIImage(named : "Follow_icon")
    //                }
    //            }
    //        }
    //
    //        if  !isFollower {
    //
    //            let following = ["following/\(key)" : self.users[indexPath.row].uid]
    //            let followers = ["followers/\(key)" : uid]
    //
    //            ref.child("users").child(uid!).updateChildValues(following)
    //            ref.child("users").child(self.users[indexPath.row].uid).updateChildValues(followers)
    //
    //            let newcell =  tableView.cellForRow(at: indexPath) as! UserCell
    //            newcell.followUnfollowBtn.imageView?.image = UIImage(named : "Following_icon")
    ////            newcell.followLabel.text = "Following"
    ////            newcell.followLabel.layer.borderWidth = 1
    ////            newcell.followLabel.layer.cornerRadius = 5
    ////            newcell.followLabel.backgroundColor = UIColor.white
    ////            newcell.followLabel.textColor = UIColor.black
    ////            newcell.followLabel.layer.borderColor = UIColor.lightGray.cgColor
    //            }
    //
    //        })
    //        ref.removeAllObservers()
    //    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         tableView.setContentOffset(.zero, animated: true)
         retrieveData()
//         AnimatableReload.reload(tableView: self.tableView, animationDirection: "up")
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
                                //                            self.followingUserids.remove(at: tag)
                                
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
                
        })
        ref.removeAllObservers()
    }
    
}

extension UIImageView{
    func downloadImage(from imgurl : String){
        let urlRequest = URLRequest(url: URL(string: imgurl)!)
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if(error != nil){
                print(error!)
                return
            }
            //Whenever u have to update the UI u have to do it in main thread, otherwise it will crash
            DispatchQueue.main.async {
                self.image = UIImage(data : data!)
            }
        }
        task.resume()
    }
}


