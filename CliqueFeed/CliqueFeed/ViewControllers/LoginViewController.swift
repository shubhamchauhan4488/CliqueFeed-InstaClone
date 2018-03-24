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

class LoginViewController: UIViewController {

    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
}

