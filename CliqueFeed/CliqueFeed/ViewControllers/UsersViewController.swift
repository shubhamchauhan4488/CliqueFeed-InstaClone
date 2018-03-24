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

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var users = [User]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        retrieveData()
    }
    
    func retrieveData(){
        let ref = Database.database().reference()
        print("ENTERED retrieve data FUNCTION")
        
        //Listen in real time whenever it updates by observeSingleEvent of eventType : value
        ref.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            
            self.users.removeAll()
            
            if let firebaseusers = snapshot.value as? Dictionary<String, AnyObject>{
                print(firebaseusers)
                print(self.users)
                for (_, value) in firebaseusers{
                    if let uid = value["uid"] as? String{
                        if(uid != Auth.auth().currentUser?.uid){
                            let userToShow = User()
                            if let name = value["name"] as? String, let imagePath = value["urlImage"] as? String{
                                  print("ENTERED")
                                userToShow.name = name
                                userToShow.imagePath = imagePath
                                userToShow.uid = uid
                                print(userToShow.name)
                                self.users.append(userToShow)
                            }
                        }
                    }
                    
                }
               self.tableView.reloadData()
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
        return users.count //it will not crash if the number of users is 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as? UserCell{
        print(cell.username.text ?? "aksdland")
        cell.username.text = self.users[indexPath.row].name
        cell.userID = self.users[indexPath.row].uid
        cell.befriendImg.image = UIImage(named : "handshake")
        cell.befriendImg.isHidden = true
        cell.userimage.downloadImage(from: users[indexPath.row].imagePath!)
        
        print(cell.userID)
    
        return cell
    }else {
    print("There is some error")
            
    return UITableViewCell()
    }
  }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let uid = Auth.auth().currentUser?.uid
        let ref = Database.database().reference()
        let key = ref.child("users").childByAutoId().key
        var isFollower = false
        
        ref.child("users").child(uid!).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with:
         { (snapshot) in
            
            if let following = snapshot.value as? [String : AnyObject] {
                for(k, value) in following{
                    if value as! String == self.users[indexPath.row].uid{
                        
                    isFollower = true
                    print("IAM INSIDE UN FOLLOW METHOD")
                    ref.child("users").child(uid!).child("following/\(k)").removeValue()
                    ref.child("users").child(self.users[indexPath.row].uid).child("followers/\(k)").removeValue()
                    
                        let newcell =  tableView.cellForRow(at: indexPath) as! UserCell
                        newcell.befriendImg.isHidden = true
                }
            }
        }
        
        if  !isFollower {
                    
            let following = ["following/\(key)" : self.users[indexPath.row].uid]
            let followers = ["followers/\(key)" : uid]
            
            ref.child("users").child(uid!).updateChildValues(following)
            ref.child("users").child(self.users[indexPath.row].uid).updateChildValues(followers)
            
            let newcell =  tableView.cellForRow(at: indexPath) as! UserCell
            newcell.befriendImg.isHidden = false

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
