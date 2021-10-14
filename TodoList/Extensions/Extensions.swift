//
//  Extensions.swift
//  TodoList
//
//  Created by Apple on 08/10/2021.
//

import Foundation
import UIKit

// Color
extension UIViewController {
    func convertColor(_ listTheme : String) -> UIColor {
        switch listTheme {
        case "red":
            return #colorLiteral(red: 1, green: 0.3081811881, blue: 0.4493987297, alpha: 1)
        case "purple":
            return #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        case "green":
            return #colorLiteral(red: 0.1356851203, green: 0.5, blue: 0.2413828719, alpha: 1)
        default:
            return #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        }
    }
    
}


//  strikethrough String
extension String {
    func strikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0,attributeString.length))
        return attributeString
    }
    
    func removeStrikeThrough() -> NSAttributedString {
        let attributeString =  NSMutableAttributedString(string: self)
        attributeString.removeAttribute(NSAttributedString.Key.strikethroughStyle, range: NSMakeRange(0,attributeString.length))
        return attributeString
    }
}


// relative date

extension Date {
    func relativeDate(_ date: Date) -> String {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .none
        relativeDateFormatter.dateStyle = .medium
        relativeDateFormatter.locale = Locale(identifier: "en_GB")
        relativeDateFormatter.doesRelativeDateFormatting = true
        
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        
        let relativeDate = relativeDateFormatter.string(from: date)
        
        if let _ = relativeDate.rangeOfCharacter(from: .decimalDigits) {
            return dateFormatter.string(from: date)
        }
        return relativeDateFormatter.string(from: date)
        
    }
}

// end of date
extension Date {
    
    var startOfDay : Date {
        let calendar = Calendar.current
        let unitFlags = Set<Calendar.Component>([.year, .month, .day])
        let components = calendar.dateComponents(unitFlags, from: self)
        return calendar.date(from: components)!
    }
    
    var endOfDay : Date {
        var components = DateComponents()
        components.day = 1
        let date = Calendar.current.date(byAdding: components, to: self.startOfDay)
        return (date?.addingTimeInterval(-1))!
    }
}

extension Date {
    func nextDayDate(_ date: Date) -> Date {
        // Convert string to Date
        //    let dateF = DateFormatter()
        //    dateF.dateFormat = "dd/MM/yyyy"
        //    let myDate = dateF.date(from: date)!
        
        // Advancing date by a month, to get end of next month.
        return Calendar.current.date(byAdding: .day, value: 1, to: date) ?? Date()
        
    }
    
    func nextWeekDate(_ date: Date) -> Date {
        
        // Advancing date by a month, to get end of next month.
        return Calendar.current.date(byAdding: .day, value: 7, to: date) ?? Date()
        
    }
    
    
    func nextMonthDate( date: Date, times: Int) -> Date {
        
        // Advancing date by a month, to get end of next month.
        return Calendar.current.date(byAdding: .month, value: times, to: date) ?? Date()
        
    }
    
    func nextYearDate(date: Date, times: Int) -> Date {
        
        // Advancing date by a month, to get end of next month.
        return Calendar.current.date(byAdding: .year, value: times, to: date) ?? Date()
        
    }
}

// get date from string
extension UIViewController {

    func getDate(_ stringDate : String) -> Date {
        let dateFormatter = DateFormatter()
        //        dateFormatter.locale = Locale(identifier: "en_GB")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        
        let date = dateFormatter.date(from:stringDate)
        guard let date = date else {
            return Date()+100000
        }
        return date
    }
    
}
// change image color
extension UIImage {
    func tinted(with color: UIColor, isOpaque: Bool = false) -> UIImage? {
        let format = imageRendererFormat
        format.opaque = isOpaque
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            color.set()
            withRenderingMode(.alwaysTemplate).draw(at: .zero)
        }
    }
}

// Hide Keyboard When TappedAround
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
