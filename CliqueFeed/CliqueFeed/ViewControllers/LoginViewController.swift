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
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController, CLLocationManagerDelegate, GIDSignInUIDelegate, GIDSignInDelegate {
    
    @IBOutlet weak var signUpStack: UIStackView!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var loginButton: DKTransitionButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var mySwitch: UISwitch!
    
    let customFbLoginButton = UIButton()
    let googleSignInButton = UIButton()
    var locManager : CLLocationManager!
    var currentLocation : CLLocation!
    var databaseRef : DatabaseReference!
    var lat : Double!
    var long : Double!
    var userDefault = UserDefaults.standard
    var FBUserEmail = ""
    var FBUserName = ""
    var FBUserID = ""
    var FBuserImageURL = ""
    var googleUserName = ""
    var googleUserEmail = ""
    var googleUserImageURL = ""
    var currentUserId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        locManager = CLLocationManager()
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
        
        self.navigationController?.navigationBar.isHidden = true
        
        //Setting up FB sign in button
        setupFacebookLoginButton()
        
        //Step 2: Setting up google sign in button
        setupGoogleLoginButton()
        
        //Step 3: To present the sign in view and dismiss the view
        //Step 4: To setup the URl in project - info - urltypes as reverse_client_id from googleService-info.plist
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        print("Profile" ,signIn.currentUser.profile)
    }
    
    fileprivate func setupFacebookLoginButton(){
        
        customFbLoginButton.backgroundColor = UIColor(red: 255/255, green: 47/255, blue: 146/255, alpha: 1)
        customFbLoginButton.setTitle("Login with Facebook", for: .normal)
        customFbLoginButton.setTitleColor(.white, for: .normal)
        customFbLoginButton.titleLabel?.font = UIFont(name: "Avenir Book", size: 17)
        customFbLoginButton.showsTouchWhenHighlighted = true
        customFbLoginButton.layer.cornerRadius = 20
        
        view.addSubview(customFbLoginButton)
        
        //By default we will not get the email in graphRequest
        //        fbLoginButton.readPermissions = ["email", "public_profile"] OR
        //        define FBSDKFielManager.readPermission for custom btn
        
        //Setting auto-layout for FB loginbutton programmatically
        customFbLoginButton.translatesAutoresizingMaskIntoConstraints = false
        let yCenterConstraint = NSLayoutConstraint(item: customFbLoginButton, attribute: .bottom, relatedBy: .equal, toItem:  signUpStack, attribute: .top, multiplier: 1, constant: -80)
        let xCenterConstraint = NSLayoutConstraint(item: customFbLoginButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let leadingConstraint1 = NSLayoutConstraint(item: customFbLoginButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20)
        let trailingConstraint1 = NSLayoutConstraint(item: customFbLoginButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -20)
        
        view.addConstraints([xCenterConstraint, yCenterConstraint, leadingConstraint1, trailingConstraint1])
        customFbLoginButton.addTarget(self, action: #selector(handleCustomFBLoginClick), for: .touchUpInside)
        
    }
    
    fileprivate func setupGoogleLoginButton() {
        
        googleSignInButton.backgroundColor = UIColor(red: 255/255, green: 47/255, blue: 146/255, alpha: 1)
        googleSignInButton.setTitle("Login with Google", for: .normal)
        googleSignInButton.setTitleColor(.white, for: .normal)
        googleSignInButton.titleLabel?.font = UIFont(name: "Avenir Book", size: 17)
        googleSignInButton.showsTouchWhenHighlighted = true
        googleSignInButton.layer.cornerRadius = 20
        
        //Add Google Sign in
        view.addSubview(googleSignInButton)
        googleSignInButton.translatesAutoresizingMaskIntoConstraints = false
        let yCenterConstraint = NSLayoutConstraint(item: googleSignInButton, attribute: .bottom, relatedBy: .equal, toItem:  signUpStack, attribute: .top, multiplier: 1, constant: -20)
        let xCenterConstraint = NSLayoutConstraint(item: googleSignInButton, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let leadingConstraint1 = NSLayoutConstraint(item: googleSignInButton, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 20)
        let trailingConstraint1 = NSLayoutConstraint(item: googleSignInButton, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: -20)
        
        view.addConstraints([xCenterConstraint, yCenterConstraint, leadingConstraint1, trailingConstraint1])
        googleSignInButton.addTarget(self, action: #selector(handleCustomGoogleLoginClick), for: .touchUpInside)
        
    }
    
    @objc func handleCustomGoogleLoginClick(){
        GIDSignIn.sharedInstance().signIn()
    }
    
    func setUserDetailsAfterGoogleLogin(){
        
        if let lastLocation = self.currentLocation {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(lastLocation,completionHandler: { (placemarks, error) in
                if error == nil {
                    
                    let firstLocation = placemarks?[0]
                    
                    let userDetails = [ "latitude" : self.lat!,
                                        "longitude" : self.long!,
                                        "email" : self.googleUserEmail,
                                        "name" : self.googleUserName,
                                        "uid" : Auth.auth().currentUser?.uid,
                                        "urlImage" : self.googleUserImageURL,
                                        "placemark" : firstLocation?.name] as [String : Any]
                    
                    
                    self.databaseRef.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(userDetails);
                }
                else {
                    // An error occurred during geocoding.
                    print("error while geocoding")
                }
            })
        }
    }
    
    //GIDSignInDelegate method
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let err = error {
            print("Failed to Sign in with Google : ", err)
            return
        }
        print("Successfully signed in")
        //Signing into Firebase Auth with google credentials
        
        //Get a Google ID token and Google access token from the GIDAuthentication object and exchange them for a Firebase credential
        guard let googleCurrentUser = GIDSignIn.sharedInstance().currentUser else {return}
        guard let authentication = googleCurrentUser.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        //authenticate with Firebase using the credential:
        Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let err = error {
                print("Failed to create Firebase user with credentials from Google: ", err)
                return
            }
            self.googleUserName = googleCurrentUser.profile.name
            self.googleUserEmail = googleCurrentUser.profile.email
            self.googleUserImageURL = googleCurrentUser.profile.imageURL(withDimension: 120).absoluteString
            self.setUserDetailsAfterGoogleLogin()
            if let homeTabBarViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarViewController") as? UITabBarController {
                self.navigationController?.pushViewController(homeTabBarViewController, animated: true)
            }
            self.googleSignInButton.isUserInteractionEnabled = false
        }
        
    }
    
    
    //MARK :- Handles click on custom FB btn and assigns read permissions and signs in
    @objc func handleCustomFBLoginClick(){
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: self) { (result, err) in
            if err != nil {
                print("Login Failed : ", err!.localizedDescription)
            }
            self.signInWithFB();
        }
    }
    
    //    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
    //
    //    }
    //
    //    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    //        if error != nil {
    //            print(error.localizedDescription)
    //            return
    //        }
    //        showEmailAddress();
    //    }
    
    func signInWithFB(){
        let accessToken = FBSDKAccessToken.current();
        guard let accessTokenString = accessToken?.tokenString else {
            return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Auth.auth().signIn(with: credential) { (user, err) in
            if err != nil {
                print("Failed to login : ", err!.localizedDescription)
                return
            }
            print("Successfully signed in")
            if user != nil{
                self.setUserDetailsAfterFBLogin();
                if let homeTabBarViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarViewController") as? UITabBarController {
                    self.navigationController?.pushViewController(homeTabBarViewController, animated: true)
                }
            }else{
                print("No user found")
                let alertBox = UIAlertController(title: "Error", message: err?.localizedDescription, preferredStyle:.alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertBox.addAction(okAction)
                self.present(alertBox, animated:true)
            }
        }
        
        
        //Creating graph request to get the ID, Name and Email
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "id, name, email " ]).start { (connection, result, err) in
            if err != nil {
                print("Failed to start graph request : ", err!.localizedDescription)
                return
            }
            if  let res = result as? Dictionary<String, Any>{
                
                if let name = res["name"] as? String {
                    self.FBUserName = name
                }
                
                if let id = res["id"] as? String {
                    self.FBUserID = id
                    self.FBuserImageURL = "https://graph.facebook.com/\(id)/picture?type=large"
                    print(self.FBuserImageURL)
                }
                
                if let email = res["email"] as? String {
                    self.FBUserEmail = email
                }
                
            }
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        view.bringSubview(toFront: loginButton)
        //        loginButton.isUserInteractionEnabled = true
        googleSignInButton.isUserInteractionEnabled = true
        customFbLoginButton.isUserInteractionEnabled = true
        
        if Auth.auth().currentUser?.uid != nil {
            currentUserId = (Auth.auth().currentUser?.uid)!
        }else{
            currentUserId = ""
        }
        
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
    
    
    @IBAction func onLoginPress(_ button: DKTransitionButton) {
        loginButton.isUserInteractionEnabled = false
        if mySwitch.isOn{
            print("+++++++++++++++")
            print("inside swtich is ON")
            userDefault.set(email.text! as String, forKey: "username")
            userDefault.set(password.text! as String, forKey: "password")
            
        }else{
            print("--------")
            print("inside swtich is off")
            userDefault.removeObject(forKey: "username")
            userDefault.removeObject(forKey: "password")
        }
        
        if(email.text != "" && password.text != "" )
        {
            Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, error) in
                
                if user != nil{
                    self.getCoordinates();
                    button.startLoadingAnimation()
                    button.startSwitchAnimation(1, completion: { () -> () in
                        if let homeTabBarViewController = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarViewController") as? UITabBarController {
                            self.navigationController?.pushViewController(homeTabBarViewController, animated: true)
                        }
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
    
    
    func setUserDetailsAfterFBLogin(){
        if let lastLocation = self.currentLocation {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(lastLocation,completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    
                    let userDetails = [ "latitude" : self.lat!,
                                        "longitude" : self.long!,
                                        "email" : self.FBUserEmail,
                                        "name" : self.FBUserName,
                                        "uid" : Auth.auth().currentUser?.uid,
                                        "urlImage" : self.FBuserImageURL,
                                        "placemark" : firstLocation?.name] as [String : Any]
                    
                    
                    self.databaseRef.child("users").child((Auth.auth().currentUser?.uid)!).updateChildValues(userDetails);
                    
                }
                else {
                    // An error occurred during geocoding.
                    print("error while geocoding")
                }
            })
        }
    }
    
    func getCoordinates(){
        print("user exists")
        if let lastLocation = self.currentLocation {
            print("lastlocation : ", self.currentLocation)
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
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = manager.location
        let coordinate = manager.location?.coordinate
        lat = coordinate!.latitude
        long = coordinate!.longitude
    }
    @IBAction func onSignUpPress(_ sender: Any) {
        if let signUpVC = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? UIViewController {
            self.navigationController?.pushViewController(signUpVC, animated: true)
        }
    }
    
}

