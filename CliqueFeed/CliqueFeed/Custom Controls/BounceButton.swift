//
//  BounceButton.swift
//  CliqueFeed
//
//  Created by SHUBHAM  CHAUHAN on 05/09/18.
//  Copyright © 2018 shubhamchauhan. All rights reserved.
//

import UIKit

class BounceButton :UIButton {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.transform = CGAffineTransform(scaleX: 1.2 , y: 1.2)
        
        UIView.animate(withDuration: 2, delay: 1.5, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .allowUserInteraction, animations: {
            self.transform = CGAffineTransform.identity
        }, completion: nil)
        
        super.touchesBegan(touches, with: event)
    }
}
