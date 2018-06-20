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
import DKLoginButton

class LoginViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    var locManager : CLLocationManager!
    var currentLocation : CLLocation!
    var databaseRef : DatabaseReference!
    var lat : Double!
    var long : Double!
    var userDefault = UserDefaults.standard
    
    @IBOutlet weak var mySwitch: UISwitch!
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        databaseRef = Database.database().reference()
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
//        email.text = "shubhamchauhan@gmail.com"
//        password.text = "123456"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print(userDefault)
        print(userDefault.bool(forKey: "username"))
        print("Valueeee")
        print(userDefault.value(forKey: "username"))
        
        if(userDefault.value(forKey: "username") == nil)
        {
            email.text = ""
        }else{
            email.text = userDefault.string(forKey: "username")
        }
        if(userDefault.value(forKey: "password") == nil)
        {
            password.text = ""
        }else{
            password.text = userDefault.string(forKey: "password")
        }

    }
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        password.resignFirstResponder()
        email.resignFirstResponder()
    }
    
    @IBAction func onLoginPress(_ button: DKTransitionButton) {
            if mySwitch.isOn{
                print("+++++++++++++++")
                print("inside swtichis ON")
                userDefault.set(email.text! as String, forKey: "username")
                userDefault.set(password.text! as String, forKey: "password")
                
            }else{
                print("--------")
                print("inside swtichis of")
                userDefault.removeObject(forKey: "username")
                userDefault.removeObject(forKey: "password")
            }
        print(userDefault)
        
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
                    button.startLoadingAnimation()
                    button.startSwitchAnimation(1, completion: { () -> () in
                        self.performSegue(withIdentifier: "loginToUsers", sender: self)
                        })
                }else{
                    print("No user found")
                    let alertBox = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle:.alert)
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
        
        let i = locations.count - 1
        currentLocation = manager.location
        let coordinate = manager.location?.coordinate
        lat = coordinate!.latitude
        long = coordinate!.longitude
        print(lat)
    }
}

