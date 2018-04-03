//
//  SearchViewController.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 01/04/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class SearchViewController: UIViewController, MKMapViewDelegate {

    var locManager : CLLocationManager!
    var currentLocation : CLLocation!
    var following = [String]()
    var refDatabase : DatabaseReference!
  
    var locs : [Location] = []
    var pins = [MKPointAnnotation]()
    var distances : [CLLocationDistance] = []
    var nearByFriendsDetailsArray : [Location] = []
    
    var numberOfNearByFriends  = 3

    @IBOutlet weak var myMapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
   
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refDatabase = Database.database().reference()
        following = []
        pins = []
        locs = []
        nearByFriendsDetailsArray = []
        fetchUsers()
        myMapView.delegate = self
        myMapView.mapType = .standard
    }
    
    func fetchUsers(){
        
        refDatabase.child("users").queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
            let usersnap = snapshot.value as! [String : AnyObject]
            for(_, value) in usersnap{
                if let userid = value["uid"] as? String{
                    print(userid)
                    if userid == Auth.auth().currentUser?.uid{
                        self.currentLocation = CLLocation(latitude: value["latitude"] as! Double!, longitude: value["longitude"] as! Double!)
                        if let followingUsers = value["following"] as? [String:String]{
                            for(_, user) in followingUsers{
                                self.following.append(user)
                                print("users appended in following")
                            }
                        }
    
                    }
                }
            }
            for(_, value) in usersnap{
                if let userid = value["uid"] as? String{
                    for element in 0..<self.following.count{
                        if userid == self.following[element]{
                            let lat = value["latitude"] as? Double
                            let long = value["longitude"] as? Double
                            let title = value["name"] as? String
                            let loc = CLLocation(latitude: lat!, longitude: long!)
                            let distance = self.currentLocation.distance(from: loc)
                            let newFriendObject = Location(distance: distance, location: loc, locTitle: title!)
                            self.nearByFriendsDetailsArray.append(newFriendObject)
                            print("*********")
                            print(loc)
                            print(distance)
                            self.distances.append(distance)
                           
                        }
                    }
                }
                
            }
            self.nearByFriendsDetailsArray = self.nearByFriendsDetailsArray.sorted(by: { (first, second) -> Bool in
                first.distance < second.distance
            })
            self.distances.sort()
            for e in self.nearByFriendsDetailsArray{
                print("^^^^^^^^^^")
                print(e.distance)
            }
            
            if self.nearByFriendsDetailsArray.count < 3{
                self.numberOfNearByFriends = self.nearByFriendsDetailsArray.count
            }
            
            
            for index in 0..<self.numberOfNearByFriends{
                 let dropPin = MKPointAnnotation()
                 dropPin.coordinate = self.nearByFriendsDetailsArray[index].location.coordinate
                 dropPin.title = self.nearByFriendsDetailsArray[index].locTitle
                 self.myMapView.addAnnotation(dropPin)
   
            }

            if self.nearByFriendsDetailsArray.count == 0{
                print("No friends to display")
            }else{
            let coord = CLLocationCoordinate2DMake(self.nearByFriendsDetailsArray[0].location.coordinate.latitude, self.nearByFriendsDetailsArray[0].location.coordinate.longitude)
            let span = MKCoordinateSpanMake(0.001, 0.001)
            let regionA = MKCoordinateRegionMake(coord, span)
            self.myMapView.setRegion(regionA, animated:true)
            self.myMapView.isZoomEnabled = true
            self.myMapView.isRotateEnabled = true
            }
        })
    }
    
  

}
