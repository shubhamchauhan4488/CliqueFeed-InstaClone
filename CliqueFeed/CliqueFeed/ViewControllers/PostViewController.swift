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

class PostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

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
    var postCounter : Int!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locManager.requestAlwaysAuthorization()
        
        if( CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedAlways){
            currentLocation = locManager.location
            
        }
        
        picker.delegate = self
        let storage = Storage.storage().reference(forURL: "gs://cliquefeed-48d9c.appspot.com")
        feedStorage = storage.child("feed")
        databaseRef = Database.database().reference()
        postCounter = 0

        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        postImage.isUserInteractionEnabled = true
        postImage.addGestureRecognizer(tapGestureRecognizer)

    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
//        let tappedImage = tapGestureRecognizer.view as! UIImageView
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)

    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage
        {
            self.postImage.image = image
        }
        print(currentLocation.coordinate.latitude)
        print(currentLocation.coordinate.longitude)
        
            if let lastLocation = self.currentLocation {
                let geocoder = CLGeocoder()
                
                // Look up the location and pass it to the completion handler
                geocoder.reverseGeocodeLocation(lastLocation,completionHandler: { (placemarks, error) in
                    if error == nil {
                        let firstLocation = placemarks?[0]
                       
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
                    let postInfo : [String:Any] = ["uid": self.userId!,
                                                   "urlImage": url.absoluteString,
                                                   "comment" : self.commentField.text!,
                                                   "comments" : [String](),
                                                   "latitude" : self.currentLocation.coordinate.latitude,
                                                   "longitude" : self.currentLocation.coordinate.longitude,
                                                   "geoTagLocation" : self.locationField.text! ]
                    
                    if(self.databaseRef.child("posts").child(self.userId!) != nil){
                        var str = self.userId! + String(self.postCounter);
                        print(type(of: str))
                        self.databaseRef.child("posts").child(str).setValue(postInfo)
                        self.postCounter =  self.postCounter + 1
                        
                    }else{
                      self.databaseRef.child("posts").child("0").setValue(postInfo)
                    }
                }
            })
        })
        uploadTask.resume()
        
    }
    

}
