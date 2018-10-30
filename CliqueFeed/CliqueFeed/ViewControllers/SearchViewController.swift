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
    
    @IBOutlet weak var findFriendsBtn: UIButton!
    @IBOutlet weak var findFriendsLabel: UILabel!
    @IBOutlet weak var myMapView: MKMapView!
    @IBOutlet weak var findFriendsBottomToMapConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var findFriendsTopConstraint: NSLayoutConstraint!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.findFriendsBottomToMapConstraint.constant = 800
        self.findFriendsTopConstraint.constant = 140
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refDatabase = Database.database().reference()
        following = []
        pins = []
        locs = []
        nearByFriendsDetailsArray = []
  
        let allAnnotations = self.myMapView.annotations
        self.myMapView.removeAnnotations(allAnnotations)
        myMapView.delegate = self
        myMapView.mapType = .standard
    }
    
    func fetchUsers(){
        refDatabase.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
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
        })
        fetchNearbyFriends()
    }
    
    func fetchNearbyFriends(){
        refDatabase.child("users").observeSingleEvent(of: .value, with: { (snapshot) in
            let usersnap = snapshot.value as! [String : AnyObject]
            for(_, value) in usersnap{
                if let userid = value["uid"] as? String{
                    print(self.following.count)
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
                            //                            print(loc)
                            print(distance)
                            self.distances.append(distance)
                            
                        }
                    }
                }
                
            }
            
            //Sorting the array of object ON ditance parameter
            self.nearByFriendsDetailsArray = self.nearByFriendsDetailsArray.sorted(by: { (first, second) -> Bool in
                first.distance < second.distance
            })
            self.distances.sort()
            for e in self.nearByFriendsDetailsArray{
                print("^^^^^^^^^^")
                print(e.distance)
            }
            
            //Checking if the friends are less than 3 then map should display them and not crash
            if self.nearByFriendsDetailsArray.count < 3{
                self.numberOfNearByFriends = self.nearByFriendsDetailsArray.count
            }else{
                //Finding nearnest 3 friends
                self.numberOfNearByFriends = 3
            }
            
            
            //Adding pins to map for nearby frinds
            let allAnnotations = self.myMapView.annotations
            self.myMapView.removeAnnotations(allAnnotations)
            for index in 0..<self.numberOfNearByFriends{
                let dropPin = MKPointAnnotation()
                dropPin.coordinate = self.nearByFriendsDetailsArray[index].location.coordinate
                dropPin.title = self.nearByFriendsDetailsArray[index].locTitle
                print("_________THESE ARE YOUR NEARBY FRIENDS VISIBLE ON MAP_______________")
                print(dropPin.title)
                self.myMapView.addAnnotation(dropPin)
            }
            
            
            //Setting the region and span of the map to a location near to the location of the first friend
            if self.nearByFriendsDetailsArray.count == 0{
                print("No friends to display")
            }else{
                let coord = CLLocationCoordinate2DMake(self.nearByFriendsDetailsArray[0].location.coordinate.latitude, self.nearByFriendsDetailsArray[0].location.coordinate.longitude)
                let span = MKCoordinateSpanMake(0.005, 0.005)
                let regionA = MKCoordinateRegionMake(coord, span)
                self.myMapView.setRegion(regionA, animated:true)
                self.myMapView.isZoomEnabled = true
                self.myMapView.isRotateEnabled = true
            }
        })
    }
    
    @IBAction func onFindNearbyFriendsPress(_ sender: Any) {
        fetchUsers()
        UIView.animate(withDuration: 1.0, animations: {
            self.findFriendsBottomToMapConstraint.constant = 5
            self.findFriendsTopConstraint.constant = 10
            self.findFriendsLabel.isHidden = true
            self.findFriendsBtn.isHidden = true
            self.view.layoutIfNeeded()
        })
    }
    
}
