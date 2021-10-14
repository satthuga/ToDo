//
//  Weather.swift
//  TodoList
//
//  Created by Apple on 08/10/2021.
//

import Foundation
import UIKit

class Weather {
 
    var main = ""
    
    init(data: [String: Any]) {
        if let coordJson = data["weather"] as? [[String: Any]], let weather = coordJson.first {
            if let main = weather["main"] as? String {
                self.main = main
            }
            
        }
    }
}
