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
    @IBOutlet weak var loginButtn: UIButton!
    
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
        //email.text = "shubhamchauhan@gmail.com"
        //password.text = "123456"
        if(email.text != "" && password.text != "" )
        {
            loginButtn.isEnabled = true
            loginButtn.setTitleColor(UIColor.white, for: UIControlState.normal)
            loginButtn.backgroundColor = UIColor(red:24/255, green:144/255, blue:248/255, alpha: 1)
            loginButtn.layer.cornerRadius = 5
            loginButtn.layer.borderWidth = 1
            loginButtn.layer.borderColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 1).cgColor
        }
        else
        {
            loginButtn.isEnabled = false
            loginButtn.setTitleColor(UIColor.gray, for: UIControlState.normal)
            loginButtn.backgroundColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 1)
            loginButtn.layer.cornerRadius = 5
            loginButtn.layer.borderWidth = 1
            loginButtn.layer.borderColor = UIColor(red:180/255, green:205/255, blue:239/255, alpha: 1).cgColor
        }
        setupAddTargetIsNotEmptyTextFields()
        
        
    }
    
    @IBAction func onLoginPress(_ sender: Any) {
        
        if(email.text != "" && password.text != "" )
        {
            Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, error) in
                if let error = error
                {
                    let alert = UIAlertController(title: "Error Message", message: "Email or Password you've entered is incorrect", preferredStyle: UIAlertControllerStyle.alert)
                    // add the actions (buttons)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
                if let u = user{
                    UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
                    UserDefaults.standard.synchronize()
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
    func setupAddTargetIsNotEmptyTextFields(){

        email.addTarget(self, action: #selector(textFieldsIsNotEmpty),
                             for: .editingChanged)
        password.addTarget(self, action: #selector(textFieldsIsNotEmpty),
                                for: .editingChanged)
    }
    @objc func textFieldsIsNotEmpty(sender: UITextField)
    {
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        guard
            let email = email.text, !email.isEmpty,
            let password = password.text, !password.isEmpty
            
            else
        {
            self.loginButtn.isEnabled = false
            loginButtn.setTitleColor(UIColor.gray, for: UIControlState.normal)
            loginButtn.backgroundColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 1)
            loginButtn.layer.cornerRadius = 5
            loginButtn.layer.borderWidth = 1
            loginButtn.layer.borderColor = UIColor(red:180/255, green:205/255, blue:239/255, alpha: 1).cgColor
            return
        }
        // enable okButton if all conditions are met
        loginButtn.isEnabled = true
        loginButtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        loginButtn.backgroundColor = UIColor(red:24/255, green:144/255, blue:248/255, alpha: 1)
        loginButtn.layer.cornerRadius = 5
        loginButtn.layer.borderWidth = 1
        loginButtn.layer.borderColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 1).cgColor
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

