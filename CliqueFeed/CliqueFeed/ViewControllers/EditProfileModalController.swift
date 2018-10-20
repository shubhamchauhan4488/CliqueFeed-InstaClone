//
//  EditProfileModalController.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 07/10/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Fusuma
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class EditProfileModalController: UIViewController, FusumaDelegate{
  
    var user = User()
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: SkyFloatingLabelTextField!
    @IBOutlet weak var email: SkyFloatingLabelTextField!
    @IBOutlet weak var password: SkyFloatingLabelTextField!
    @IBOutlet weak var confirmPassword: SkyFloatingLabelTextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    var userStorage : StorageReference!
    var databaseRef : DatabaseReference!
    var userInfo = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let storage = Storage.storage().reference(forURL: "gs://cliquefeed-48d9c.appspot.com")
        userStorage = storage.child("users")
        databaseRef = Database.database().reference()

        self.profileImage.downloadImage(from: self.user.imagePath)
        self.name.text = self.user.name
        self.email.text = self.user.email
        self.password.text = ""
        self.confirmPassword.text = ""
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        profileImage.isUserInteractionEnabled = true
        profileImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @IBAction func onEmailTextChanged(_ sender: Any) {
        
        if email.isEditing{
            if let text = email.text {
                if(text.count < 3 || !(text.contains("@")) || !(text.contains(".com"))) {
                    email.errorMessage = "Invalid Email"
                }
                else {
                    // The error message will only disappear when we reset it to nil or empty string
                    email.errorMessage = ""
                }
            }
        }
        if email.text == "" {
            email.errorMessage = ""
        }
    }
    
    
    
    @IBAction func onNameTextChanged(_ sender: Any) {
        
        if name.isEditing{
            if let text = name.text {
                if(text.count < 2 ) {
                    name.errorMessage = "Enter more than one character"
                }
                else {
                    // The error message will only disappear when we reset it to nil or empty string
                    name.errorMessage = ""
                }
            }
        }
        
        if name.text == "" {
            name.errorMessage = ""
        }
    }
    
    @IBAction func onPasswordTextChanged(_ sender: Any) {
        if let passwordtext = password.text {
            let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
            if !(passwordTest.evaluate(with: passwordtext)){
                password.errorMessage = "Invalid Password"
            }
            else {
                password.errorMessage = ""
            }
        }
        
        if password.text == "" {
            password.errorMessage = ""
        }
    }
    @IBAction func onConfirmPasswordTextChanged(_ sender: Any) {
        
        if let confirmPasssword = confirmPassword.text {
            if (confirmPasssword != password.text!) {
                confirmPassword.errorMessage = "Passwords donot match"
            }
            else{
                confirmPassword.errorMessage = ""
            }
        }
        
        if confirmPassword.text == "" {
            confirmPassword.errorMessage = ""
        }
    }

    @IBAction func onCancelClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onApplyClick(_ sender: Any) {
        if ( name.errorMessage != "Enter more than one character" && email.errorMessage != "Invalid Email" && password.errorMessage != "Invalid Password"  && confirmPassword.errorMessage != "Passwords donot match")
        {
                let imageRef = self.userStorage.child("\(Auth.auth().currentUser?.uid).jpg")
                //Downgrading the image selected by the user and putting in 'data' variable
                let data = UIImageJPEGRepresentation(self.profileImage.image!, 0.5 )
                
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
                            self.uploadUserToFirebase(url : url)
                        }
                        
                    })
                })
                uploadTask.resume()
                self.errorLabel.isHidden = true
              self.dismiss(animated: true, completion: nil)
            }
      
        else
        {
            errorLabel.text = "(* Remove all Errors to Proceed)"
        }
      
    }
    
    func uploadUserToFirebase(url : URL){
        if( password.text != "" && confirmPassword.text != "" && password.text == confirmPassword.text){
                userInfo = [
                "name" : name.text!,
                "email" : email.text!,
                "password" : password.text!,
                "urlImage": url.absoluteString]
        }else{
                userInfo = [
                "name" : name.text!,
                "email" : email.text!,
                "urlImage": url.absoluteString]
        }
   self.databaseRef.child("users").child(Auth.auth().currentUser!.uid).updateChildValues(userInfo)
    }
    
    
    @objc func imageTapped()
    {
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        //fusuma.hasVideo = true //To allow for video capturing with .library and .camera available by default
        fusuma.cropHeightRatio = 1 // Height-to-width ratio. The default value is 1, which means a squared-size photo.
        //fusuma.allowMultipleSelection = true // You can select multiple photos from the camera roll. The default value is false.
        self.present(fusuma, animated: true, completion: nil)
    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        self.profileImage.image = image
    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
    }
    
    func fusumaCameraRollUnauthorized() {
    }
    

    

}
