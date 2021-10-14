//
//  TodoData.swift
//  TodoList
//
//  Created by Apple on 11/09/2021.
//

import Foundation
import Firebase
import FirebaseFirestore

// MARK: -List model and mockup data

//public enum listTheme {
//    case defaultBlue
//    case red
//    case purple
//    case green
//}

class List {
    
    var listID: String = ""
    var listName: String = ""
    var listTheme: String = "defaultBlue"
    var createDate: String = "\(Date())"
    
    init() {
    }
    
    init(snapShot: QueryDocumentSnapshot) {
        self.listID = snapShot.reference.documentID
        self.listName = snapShot.data()["listName"] as! String
        self.listTheme = snapShot.data()["listTheme"] as! String
        self.createDate = snapShot.data()["createDate"] as! String
    }
    
    
}

var defaultTaskList : List = {
    let list = List()
    list.listID = "6ADC157A-B1C2-4411-89E3-738A2333A3B7"
    list.listName = "Task"
    list.listTheme = "defaultBlue"
    return list
}()



// MARK: -Todo model and mockup data


class Todo {
    
    var id: String = ""
    var toDoName: String = ""
    var listID : String = defaultTaskList.listID
    var listName : String = "Task"
    var description: String = ""
    var createDate: String = ""
    var dueDate: String? = nil
    var remindTime: String? = nil
    var repeatToDo: String = "none"
    var isComplete: Bool = false
    var isPrioritized: Bool = false
    var originalDueDate: String? = nil
    var originalRemind: String? = nil
    var repeatTimes: Int = 0

    init() {
    }
    
    init(snapShot: QueryDocumentSnapshot) {
        self.id = snapShot.reference.documentID
        self.toDoName = snapShot.data()["toDoName"] as! String
        self.listID = snapShot.data()["listID"] as! String
        self.listName = snapShot.data()["listName"] as! String
        self.description = snapShot.data()["description"] as! String
        self.createDate = snapShot.data()["createDate"] as! String
        self.dueDate = snapShot.data()["dueDate"] as? String
        self.remindTime = snapShot.data()["remindTime"] as? String
        self.repeatToDo = snapShot.data()["repeatToDo"] as! String
        self.isComplete = snapShot.data()["isComplete"] as! Bool
        self.isPrioritized = snapShot.data()["isPrioritized"] as! Bool
        self.originalDueDate = snapShot.data()["originalDueDate"] as? String
        self.originalRemind = snapShot.data()["originalRemind"] as? String
        self.repeatTimes  = snapShot.data()["repeatTimes"] as! Int
        
    }

    
    init(_ id : String,_ toDoName : String,_ listID : String,_ listName : String,_ description : String,_ dueDate : String?,_ remindTime : String?,_ repeatToDo : String,_ isComplete : Bool,_ isPrioritized : Bool, _ originalDueDate: String?, _ originalRemind : String?, _ repeatTimes : Int) {
        self.id = id
        self.toDoName = toDoName
        self.listID = listID
        self.listName = listName
        self.description = description
        self.dueDate = dueDate
        self.remindTime = remindTime
        self.dueDate = dueDate
        self.remindTime = remindTime
        self.repeatToDo = repeatToDo
        self.isComplete = isComplete
        self.isPrioritized = isPrioritized
        self.originalDueDate = originalDueDate
        self.originalRemind = originalRemind
        self.repeatTimes  = repeatTimes
        
    }
}
