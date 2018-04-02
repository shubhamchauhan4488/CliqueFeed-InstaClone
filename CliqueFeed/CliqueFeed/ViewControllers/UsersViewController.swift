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
    var isFollower = false
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
            
            cell.username.text = self.users[indexPath.row].name
            cell.userID = self.users[indexPath.row].uid
            
            if self.isFollower == true{

            cell.followLabel.text = "Follow"
            cell.followLabel.backgroundColor = UIColor(red: 56/255, green: 151/255, blue: 240/255, alpha: 1)
            cell.followLabel.textColor = UIColor.white
            cell.followLabel.layer.cornerRadius = 5
            cell.followLabel.layer.borderWidth = 1
            cell.followLabel.layer.borderColor = UIColor(red: 56/255, green: 151/255, blue: 240/255, alpha: 1).cgColor
            }else{
                cell.followLabel.text = "Following"
                cell.followLabel.layer.borderWidth = 1
                cell.followLabel.layer.cornerRadius = 5
                cell.followLabel.backgroundColor = UIColor.white
                cell.followLabel.textColor = UIColor.black
                cell.followLabel.layer.borderColor = UIColor.lightGray.cgColor
            }

            
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
        
        
        ref.child("users").child(uid!).child("following").queryOrderedByKey().observeSingleEvent(of: .value, with:
            { (snapshot) in
                
                if let following = snapshot.value as? [String : AnyObject] {
                    for(k, value) in following{
                        if value as! String == self.users[indexPath.row].uid{
                            
                            self.isFollower = true
                            print("IAM INSIDE UN FOLLOW METHOD")
                            ref.child("users").child(uid!).child("following/\(k)").removeValue()
                            ref.child("users").child(self.users[indexPath.row].uid).child("followers/\(k)").removeValue()
                            
                            
                            let newcell =  tableView.cellForRow(at: indexPath) as! UserCell
                            newcell.followLabel.text = "Follow"
                            newcell.followLabel.backgroundColor = UIColor(red: 56/255, green: 151/255, blue: 240/255, alpha: 1)
                            newcell.followLabel.textColor = UIColor.white
                            newcell.followLabel.layer.cornerRadius = 5
                            newcell.followLabel.layer.borderWidth = 1
                            newcell.followLabel.layer.borderColor = UIColor(red: 56/255, green: 151/255, blue: 240/255, alpha: 1).cgColor
                        }
                    }
                }
                
                if  !self.isFollower {
                    
                    let following = ["following/\(key)" : self.users[indexPath.row].uid]
                    let followers = ["followers/\(key)" : uid]
                    
                    ref.child("users").child(uid!).updateChildValues(following)
                    ref.child("users").child(self.users[indexPath.row].uid).updateChildValues(followers)
                    
                    let newcell =  tableView.cellForRow(at: indexPath) as! UserCell
                    //            newcell.befriendImg.isHidden = false
                    
                    newcell.followLabel.text = "Following"
                    newcell.followLabel.layer.borderWidth = 1
                    newcell.followLabel.layer.cornerRadius = 5
                    newcell.followLabel.backgroundColor = UIColor.white
                    newcell.followLabel.textColor = UIColor.black
                    newcell.followLabel.layer.borderColor = UIColor.lightGray.cgColor
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
