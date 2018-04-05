

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import FirebaseCore

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    @IBOutlet weak var nxtBtn: UIButton!
    
    let picker = UIImagePickerController()
    var userStorage : StorageReference!
    var databaseRef : DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.delegate = self
        let storage = Storage.storage().reference(forURL: "gs://cliquefeed-3b099.appspot.com")
        userStorage = storage.child("users")
        databaseRef = Database.database().reference()
        setupSignUpTargetIsNotEmptyTextFields()
        nxtBtn.setTitleColor(UIColor.gray, for: UIControlState.normal)
        nxtBtn.backgroundColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 1)
        nxtBtn.layer.cornerRadius = 5
        nxtBtn.layer.borderWidth = 1
        nxtBtn.layer.borderColor = UIColor(red:180/255, green:205/255, blue:239/255, alpha: 1).cgColor
    }

  
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage
        {
        profileImage.image = image
        profileImage.contentMode = .scaleAspectFill
        profileImage.layer.masksToBounds = false
        profileImage.layer.cornerRadius = profileImage.frame.size.height/2
        profileImage.clipsToBounds = true
        }
        else
        {
            //error message
        }
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func onImageSelect(_ sender: UIButton) {
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
        let controller = UIImagePickerController()
        controller.delegate = self
        //controller.sourceType = .photoLibrary
        //controller.allowsEditing = false
        //present(controller, animated: true, completion: nil)
        
        //Open an Alert and Choose a Picture
        let alert = UIAlertController(title: "Photo Source", message: "Choose a source?", preferredStyle: UIAlertControllerStyle.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Camera", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) in
            if UIImagePickerController.isSourceTypeAvailable(.camera)
            {
                
                controller.sourceType = .camera
                self.present(controller, animated: true, completion: nil)
            }
            else
            {
                let alert = UIAlertController(title: "No Camera", message: "Camera Not Available", preferredStyle: UIAlertControllerStyle.alert)
                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
                
                // show the alert
                self.present(alert, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.default,handler:{ (action:UIAlertAction) in
            controller.sourceType = .photoLibrary
            self.present(controller, animated: true, completion: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
        
    }
    func setupSignUpTargetIsNotEmptyTextFields()
    {
        nxtBtn.isEnabled = false
        nxtBtn.addTarget(self, action: #selector(textFieldsIsNotEmpty),for: .editingChanged)
        name.addTarget(self, action: #selector(textFieldsIsNotEmpty),for: .editingChanged)
        password.addTarget(self, action: #selector(textFieldsIsNotEmpty),for: .editingChanged)
        confirmPassword.addTarget(self, action: #selector(textFieldsIsNotEmpty),for: .editingChanged)
    }
    
    // Check all the fields are filled if yes then signup button will enable
    @objc func textFieldsIsNotEmpty(sender: UITextField)
    {
        guard
            let email = email.text, !email.isEmpty,
            let name = name.text, !name.isEmpty,
            let password = password.text, !password.isEmpty,
            let confirmPassword = confirmPassword.text, !confirmPassword.isEmpty
            else
        {
            self.nxtBtn.isEnabled = false
            nxtBtn.setTitleColor(UIColor.gray, for: UIControlState.normal)
            nxtBtn.backgroundColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 1)
            nxtBtn.layer.cornerRadius = 5
            nxtBtn.layer.borderWidth = 1
            nxtBtn.layer.borderColor = UIColor(red:180/255, green:205/255, blue:239/255, alpha: 1).cgColor
            return
        }
        
        // enable SignUpButton if all conditions are met
        nxtBtn.isEnabled = true
        nxtBtn.setTitleColor(UIColor.white, for: UIControlState.normal)
        nxtBtn.backgroundColor = UIColor(red:24/255, green:144/255, blue:248/255, alpha: 1)
        nxtBtn.layer.cornerRadius = 5
        nxtBtn.layer.borderWidth = 1
        nxtBtn.layer.borderColor = UIColor(red:255/255, green:255/255, blue:255/255, alpha: 1).cgColor
    }
    
    @IBAction func onNextPress(_ sender: UIButton) {
        //checking if any field is empty
        guard name.text != "", email.text != "", password.text != "", confirmPassword.text != "" else
        {
            return
        }
        
        //checking if passwords entered match
        if(password.text == confirmPassword.text)
        {
            
            //Creating user via firebase
            Auth.auth().createUser(withEmail: email.text!, password: password.text!, completion: { (user, error) in
                
                //catching the error
                if let error = error
                {
                    //print(error.localizedDescription)
                    // print(error.localizedDescription)
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                    // add the actions (buttons)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    
                    // show the alert
                    self.present(alert, animated: true, completion: nil)
                }
                
                UserDefaults.standard.set(self.email, forKey: "email")
                UserDefaults.standard.set(self.password, forKey: "password")
                UserDefaults.standard.synchronize()
                //If user is successfully created on firebase
                if let user = user
                {
                  // let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                  // changeRequest?.displayName = self.name.text
                  // changeRequest?.commitChanges(completion: nil)
                    
                    let imageRef = self.userStorage.child("\(user.uid).jpg")
                    //Downgrading the image selected by the user and putting in 'data' variable
                    let data = UIImageJPEGRepresentation(self.profileImage.image!, 0.5 )
                    
                    //Putting the image on the 'unique' reference created on Firebase inside Users folder
                    let uploadTask = imageRef.putData(data!, metadata: nil, completion: { (metadata, err) in
                        if let err = err {
                            //print(err.localizedDescription)
                            let alert = UIAlertController(title: "Check Error Message while image upload", message: err.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                            // add the actions (buttons)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            
                            // show the alert
                            self.present(alert, animated: true, completion: nil)
                        }
                        imageRef.downloadURL(completion: { (url, er) in
                            if let er = er {
                                //print(er.localizedDescription)
                                let alert = UIAlertController(title: "Check Error Message while image download", message: er.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
                                // add the actions (buttons)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                                // show the alert
                                self.present(alert, animated: true, completion: nil)
                            }
                            
                            if let url = url{
                                let userInfo : [String:Any] = ["uid": user.uid,
                                                               "name" : self.name.text!,
                                                               "email" : self.email.text!,
                                                               "password" : self.password.text!,
                                                               "urlImage": url.absoluteString]
                                
                                self.databaseRef.child("users").child(user.uid).setValue(userInfo)
                            }
                            
                            
                        })
                    })
                    uploadTask.resume()
                    
                }
            })
        }
        else
        {
            let alert = UIAlertController(title: "Check Password", message: "Passwords are not matching", preferredStyle: UIAlertControllerStyle.alert)
            // add the actions (buttons)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    //User Cancel the Imaage
    
}
