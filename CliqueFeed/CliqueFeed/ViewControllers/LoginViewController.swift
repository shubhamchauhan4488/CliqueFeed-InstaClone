//
//  ViewController.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 15/03/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import CoreLocation

class LoginViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    var locManager : CLLocationManager!
    var currentLocation : CLLocation!
    var databaseRef : DatabaseReference!
    var lat : Double!
    var long : Double!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        
        email.text = "shubhamchauhan@gmail.com"
        password.text = "123456"
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func onLoginPress(_ sender: Any) {
        
        if(email.text != "" && password.text != "" )
        {
            Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, error) in

                        if let u = user{
                            print("user exists")
                            
                            if let lastLocation = self.currentLocation {
                                let geocoder = CLGeocoder()
                                geocoder.reverseGeocodeLocation(lastLocation,completionHandler: { (placemarks, error) in
                                    if error == nil {
                                        let firstLocation = placemarks?[0]
                                        let coordinates = [ "latitude" : self.lat!,
                                                        "longitude" : self.long!,
                                                        "placemark" : firstLocation?.name] as [String : Any]
                                        
                                    self.databaseRef.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(coordinates)
                                        
                                        
                                    }
                                    else {
                                        // An error occurred during geocoding.
                                        print("error while geocoding")
                                    }
                                })
                            }
                            
             
                            
                            
                        self.performSegue(withIdentifier: "loginToUsers", sender: self)
                        }else{
                            print("No user found")
                            let alertBox = UIAlertController(title: "Login Failed", message: "Password/Username didnt match", preferredStyle:.alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                            alertBox.addAction(okAction)
                            self.present(alertBox, animated:true)
                        }
                }
        }else{
            let alertBox = UIAlertController(title: "Login Failed", message: "Password/Username didnt match", preferredStyle:.alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertBox.addAction(okAction)
            present(alertBox, animated:true)
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // get the most recent position
        let i = locations.count - 1
        
        
        // ui nonsense - update the map
        // to show the proper zoom level
        currentLocation = manager.location
        let coordinate = manager.location?.coordinate
        lat = coordinate!.latitude
        long = coordinate!.longitude
        print(lat)
        
     
    }
}

