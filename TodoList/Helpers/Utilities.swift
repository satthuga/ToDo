//
//  Utilities.swift
//
//
//  Created by Apple on 01/10/2021.
//

import Foundation
import UIKit

class Utilities {
    
    static func styleTextField(_ textfield:UITextField) {
        
        let bottomLine = UIView()
         
        bottomLine.translatesAutoresizingMaskIntoConstraints = false
        bottomLine.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)

        textfield.addSubview(bottomLine)
        bottomLine.topAnchor.constraint(equalTo: textfield.bottomAnchor, constant: 0.5).isActive = true
        bottomLine.leadingAnchor.constraint(equalTo: textfield.leadingAnchor).isActive = true
        bottomLine.trailingAnchor.constraint(equalTo: textfield.trailingAnchor).isActive = true
        bottomLine.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        // Remove border on text field
        textfield.borderStyle = .none
     
    }
    
    static func styleFilledButton(_ button:UIButton) {
        
        // Filled rounded corner style
        button.backgroundColor = #colorLiteral(red: 0.2117647059, green: 0.6901960784, blue: 0.9568627451, alpha: 1)
        button.layer.cornerRadius = 10
        button.tintColor = UIColor.white
     
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    }
    
    static func styleHollowButton(_ button:UIButton) {
        
        // Hollow rounded corner style
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25.0
        button.tintColor = UIColor.black
    }
    
    static func isPasswordValid(_ password : String) -> Bool {
        
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordTest.evaluate(with: password)
    }
    
}

