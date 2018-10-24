//
//  LaunchViewController.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 22/10/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {

    @IBOutlet weak var animationImageLeadingConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.animationImageLeadingConstraint.constant = -200
        UIView.animate(withDuration: 3.0, animations: {
            self.animationImageLeadingConstraint.constant = 200
            self.view.layoutIfNeeded()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
           
           
            self.performSegue(withIdentifier: "toLogin", sender: self)
            }
//             {(finished) in
//                if (finished){
//                    self.performSegue(withIdentifier: "toLogin", sender: self)
//                    //                self.animationImageLeadingConstraint.constant = -300
//                    //                    self.view.layoutIfNeeded()
//                }
//            }
        }
//        UIView.animate(withDuration: 7.1, animations : {
//            self.animationImageLeadingConstraint.constant = 300
//            }) {(finished) in
//                if (finished){
//                    self.performSegue(withIdentifier: "toLogin", sender: self)
////                self.animationImageLeadingConstraint.constant = -300
////                    self.view.layoutIfNeeded()
//                }
//            }
    

}
