//
//  LocalNotificationManager.swift
//  TodoList
//
//  Created by Apple on 03/10/2021.
//

import Foundation
import UserNotifications

struct Notification {
    var id:String
    var title:String
//    var datetime:DateComponents
    var datetime : Date
}


class LocalNotificationManager
{
    var notifications = [Notification]()
 
    func listScheduledNotifications()
    {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
            
            for notification in notifications {
                print(notification)
            }
        }
    }
    
    private func requestAuthorization()
    {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            
            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }
    
    func schedule()
    {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            
            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break // Do nothing
            }
        }
    }
    
    private func scheduleNotifications()
    {
        for notification in notifications
        {
            let content      = UNMutableNotificationContent()
            content.title    = notification.title
            content.sound    = .default
//
//            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.datetime, repeats: false)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notification.datetime), repeats: false)
            
            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                
                guard error == nil else { return }
//                print("Notification scheduled! --- ID = \(notification.id)")
            }
        }
    }
    func removeNotifications(id : String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
     }
    
}

let notiManager = LocalNotificationManager()

