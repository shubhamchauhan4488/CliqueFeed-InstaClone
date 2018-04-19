//
//  PostViewController.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 23/03/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import CoreLocation
import Fusuma

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, FusumaDelegate {
   
    
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var commentField: UITextField!
    
    @IBOutlet weak var locationField: UITextField!
    
    let picker = UIImagePickerController()
    var feedStorage : StorageReference!
    var databaseRef : DatabaseReference!
    let userId =  Auth.auth().currentUser?.uid
    var imgCounter = 0
    var locManager = CLLocationManager()
    var currentLocation: CLLocation!
    var postCounter = Int()
    var userDefaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        
        //        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
        //            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
        //            currentLocation = locManager.location
        //
        //        }
        
        picker.delegate = self
        let storage = Storage.storage().reference(forURL: "gs://cliquefeed-48d9c.appspot.com")
        feedStorage = storage.child("feed")
        databaseRef = Database.database().reference()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tapGestureRecognizer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (userDefaults.bool(forKey: "postcounter")) == false{
            userDefaults.set(0, forKey: "postcounter")
        }else{
            postCounter = userDefaults.integer(forKey: "postcounter")
        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        //fusuma.hasVideo = true //To allow for video capturing with .library and .camera available by default
        fusuma.cropHeightRatio = 1 // Height-to-width ratio. The default value is 1, which means a squared-size photo.
        //fusuma.allowMultipleSelection = true // You can select multiple photos from the camera roll. The default value is false.
        self.present(fusuma, animated: true, completion: nil)
        //        let tappedImage = tapGestureRecognizer.view as! UIImageView
//        picker.allowsEditing = true
//        picker.sourceType = .photoLibrary
//        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            self.postImage.image = image
        }
        
        if let lastLocation = self.currentLocation {
            print(currentLocation.coordinate.latitude)
            print(currentLocation.coordinate.longitude)
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    print(placemarks)
                    self.locationField.text = (firstLocation?.name)! + "," + (firstLocation?.locality)! + "," + (firstLocation?.country)!
                }
                else {
                    // An error occurred during geocoding.
                    print("error while geocoding")
                }
            })
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onPost(_ sender: Any) {
        
        let imageRef = self.feedStorage.child(userId!).child("\(imgCounter).jpg")
        imgCounter += 1
        //Downgrading the image selected by the user and putting in 'data' variable
        let data = UIImageJPEGRepresentation(self.postImage.image!, 0.5 )
        
        //Putting the image on the 'unique' reference created on Firebase inside Users folder
        let uploadTask = imageRef.putData(data!, metadata: nil, completion: { (metadata, err) in
            if let err = err {
                print(err.localizedDescription)
            }
            imageRef.downloadURL(completion: { (url, er) in
                if let er = er {
                    print(er.localizedDescription)
                }
                
                if let url = url{
                    if self.commentField.text == nil{
                        self.commentField.text = ""
                    }
                    let timeInterval = NSDate().timeIntervalSince1970
                    let postInfo : [String:Any] = ["uid": self.userId!,
                                                   "urlImage": url.absoluteString,
                                                   "comment" : self.commentField.text!,
                                                   "comments" : [String](),
                                                   "latitude" : self.currentLocation.coordinate.latitude,
                                                   "longitude" : self.currentLocation.coordinate.longitude,
                                                   "geoTagLocation" : self.locationField.text!,
                                                    "timestamp" : timeInterval]
                    
                      if(self.databaseRef.child("posts").child(self.userId!) != nil){
                        var str = self.userId! + String(self.postCounter);
                        print(type(of: str))
                        self.databaseRef.child("posts").childByAutoId().setValue(postInfo)
                        self.postCounter =  self.postCounter + 1
                        self.userDefaults.set(self.postCounter, forKey: "postcounter")
                        let alert = UIAlertController(title: "Successfull", message: "Image has been posted", preferredStyle: .actionSheet)
                                            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                            alert.addAction(okAction)
                                            self.present(alert, animated: true)
                        self.postImage.image = UIImage(named : "instalCam2")
                        self.commentField.text = ""
                        self.locationField.text = ""
                   
                    }else{
                        self.databaseRef.child("posts").child("0").setValue(postInfo)
                    }
                }
            })
        })
        uploadTask.resume()
        
        if let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "feedViewController") as? FeedViewController {
            // Present Second View
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }

        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let i = locations.count - 1
        currentLocation = manager.location  
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        
            self.postImage.image = image
        
        if let lastLocation = self.currentLocation {
            print(currentLocation.coordinate.latitude)
            print(currentLocation.coordinate.longitude)
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(lastLocation,completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    print(placemarks)
                    self.locationField.text = (firstLocation?.name)! + "," + (firstLocation?.locality)! + "," + (firstLocation?.country)!
                }
                else {
                    // An error occurred during geocoding.
                    print("error while geocoding")
                }
            })
        }
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        
    }
    
    func fusumaCameraRollUnauthorized() {
        
    }
    
    
}
