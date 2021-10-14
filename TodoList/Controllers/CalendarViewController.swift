//
//  CalendarViewController.swift
//  TodoList
//
//  Created by Apple on 19/09/2021.
//

import UIKit
//import SideMenu
import FSCalendar
import Firebase
import FirebaseFirestore
import AVFoundation

class CalendarViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance, UIGestureRecognizerDelegate {
    
    let db = Firestore.firestore().collection("users")
    var userDocument: DocumentReference!
    var todoCollection: CollectionReference!
    var completedTodoCollection: CollectionReference!
    var listCollection: CollectionReference!
    var todoData = [Todo]()
    
    var calendarTheme = "defaultBlue"
    var displayDate = Date()
    
    var listData = [List]()
    lazy var dateData = [Todo]()
    
    let tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        return table
    }()
    
    
    let floatingButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 66, height: 66))
        
        let plusImage = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 35, weight: .medium))
        button.setImage(plusImage, for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.1
        button.layer.cornerRadius = 33
        return button
    }()
    
//    var menu : SideMenuNavigationController?
    
    fileprivate weak var calendar: FSCalendar!
    var  animationSwitch: Bool = true
    
    fileprivate weak var  calendarHeightConstraint: NSLayoutConstraint!
    
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    fileprivate lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self.calendar, action: #selector(self.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
   
    let pianoSound = URL(fileURLWithPath: Bundle.main.path(forResource: "prist", ofType: "mp3")!)
      var audioPlayer = AVAudioPlayer()

    // MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = convertColor("defaultBlue")
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white

        self.addLeftBarButtonWithImage(UIImage(named: "sidemenu")!)
        
        let optionMenu = UIBarButtonItem(image: UIImage(named: "optionmenu"), style: .done, target: self, action: #selector(viewModePress))
        navigationItem.rightBarButtonItem = optionMenu

        
        // calendar
        let calendar = FSCalendar(frame: CGRect(x: 0, y: 0, width: 320, height: 300))
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.backgroundColor = .white
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.headerTitleColor = .black
        calendar.appearance.todayColor =  convertColor("red")
        calendar.appearance.selectionColor = convertColor(self.calendarTheme)
        
        calendar.dataSource = self
        calendar.delegate = self
        
        // tableView
        tableView.delegate = self
        tableView.dataSource = self
        let footerView = UIView()
        footerView.frame.size.height = 1
        tableView.tableFooterView = footerView
        self.tableView.backgroundColor =  #colorLiteral(red: 0.9208939678, green: 0.9208939678, blue: 0.9208939678, alpha: 1)
        tableView.showsVerticalScrollIndicator = true
        self.tableView.separatorStyle = .none
        
        self.calendar = calendar
        self.calendar.select(Date())
        
        self.view.addGestureRecognizer(self.scopeGesture)
        //        self.tableView.panGestureRecognizer.require(toFail: self.scopeGesture)
        self.calendar.scope = .week
       
        // setup floating button
        floatingButton.addTarget(self, action: #selector(didTapFloatingButton), for: .touchUpInside)
        floatingButton.backgroundColor = convertColor("defaultBlue")
        
        setupConstraints()
        fetchData()
    }
    
    deinit {
        print("deinit calendar")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        floatingButton.frame = CGRect(x: view.frame.size.width - 85, y: view.frame.size.height - 90, width: 66, height: 66)
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK:- fetchData
    private func fetchData() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        userDocument = db.document(user.uid)
        todoCollection = userDocument.collection("ToDoData")
      
        todoCollection.addSnapshotListener { querySnapshot, error in
            
            guard let querySnapshot = querySnapshot else {
                return
            }
            
            self.todoData = querySnapshot.documents.map{
                return Todo.init(snapShot : $0)}
            
            querySnapshot.documentChanges.forEach { diff in
                switch diff.type {
                case  .added:
                    let data = diff.document.data()
                    if let dueDate = data["dueDate"] as? String {
                        
                        if Calendar.current.isDate(self.getDate(dueDate), inSameDayAs: self.displayDate) {
                            
                            self.dateData.insert(Todo.init(diff.document.documentID, data["toDoName"] as! String, data["listID"] as! String, data["listName"] as! String, data["description"] as! String, data["dueDate"] as? String, data["remindTime"] as? String, data["repeatToDo"] as! String, data["isComplete"] as! Bool, data["isPrioritized"] as! Bool, data["originalDueDate"] as? String, data["originalRemind"] as? String, data["repeatTimes"] as! Int), at: 0)
                            
                            switch UserDefaults.standard.string(forKey: "sortBy") {
                            case "Importance":
                                self.dateData.sort {
                                    $0.isPrioritized && !$1.isPrioritized
                                }
                                
                            case "Alphabet":
                                self.dateData.sort {
                                    $0.toDoName < $1.toDoName
                                }
                                
                            default:
                                self.dateData.sort {
                                    self.getDate($0.createDate) > self.getDate($1.createDate)
                                }
                            }
                            
                            for (index, item) in self.dateData.enumerated() {
                                if item.id == diff.document.documentID {
                                    self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                                    break
                                }
                            }
                            
//                            self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                        }
                    }
                    
                    if let remindTime = data["remindTime"] as? String {
                        notiManager.notifications.append(Notification(id: diff.document.documentID, title: data["toDoName"] as! String, datetime: self.getDate(remindTime)))
                        
                        notiManager.schedule()
                    }
                    
                case  .modified:
                    let data = diff.document.data()
                    for (index, item) in self.dateData.enumerated() {
                        if item.id == diff.document.documentID {
                            
                            guard let dueDate = data["dueDate"] else {
                                self.dateData.remove(at: index)
                                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                                return }
                            
                            if Calendar.current.isDate(self.getDate(dueDate as? String ?? "\(self.displayDate+100000)"), inSameDayAs: self.displayDate) {
                                item.toDoName = data["toDoName"] as! String
                                item.listID = data["listID"] as! String
                                item.listName = data["listName"] as! String
                                item.description = data["description"] as! String
                                item.dueDate = dueDate as? String
                                item.remindTime = data["remindTime"] as? String
                                item.repeatToDo = data["repeatToDo"] as! String
                                item.isComplete = data["isComplete"] as! Bool
                                item.isPrioritized = data["isPrioritized"] as! Bool
                                item.originalDueDate = data["originalDueDate"] as? String
                                item.originalRemind = data["originalRemind"] as? String
                                item.repeatTimes = data["repeatTimes"] as! Int
                                
                                self.tableView.reloadData()
                                
                                
                                var oldRow : Int = 0
                                var newRow : Int = 0
                                
                                for (index, item) in self.dateData.enumerated() {
                                    if item.id == diff.document.documentID {
                                        oldRow = index
                                        break
                                    }
                                }
                                
                                switch UserDefaults.standard.string(forKey: "sortBy") {
                                case "Importance":
                                    
                                    self.dateData.sort {
                                        $0.isPrioritized && !$1.isPrioritized
                                    }
                                    
                                case "Alphabet":
                                    
                                    self.dateData.sort {
                                        $0.toDoName < $1.toDoName
                                    }
                                    
                                default:
                                    self.dateData.sort {
                                        self.getDate($0.createDate) > self.getDate($1.createDate)
                                    }
                                }
                                
                                for (index, item) in self.dateData.enumerated() {
                                    if item.id == diff.document.documentID {
                                        newRow = index
                                        break
                                    }
                                }
                                self.tableView.moveRow(at: IndexPath(row: oldRow, section: 0), to: IndexPath(row: newRow, section: 0))
                                
                                break
                            } else {
                                self.dateData.remove(at: index)
                                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                                break
                            }
                        }
                    }
                    
                case .removed:
                    let data = diff.document.data()
                    
                    for (index, item) in self.dateData.enumerated() {
                        if item.id == diff.document.documentID {
                            self.dateData.remove(at: index)
                            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                            break
                        }
                    }
                    if let _ = data["remindTime"] {
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [diff.document.documentID])
                    }
                    
                }
                
            }
        }
        
        self.listCollection = userDocument.collection("Lists")
        self.listCollection.addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else {
                return
            }
            self.listData = querySnapshot.documents.map({
                return List.init(snapShot: $0)
            })
            self.tableView.reloadData()
        }
    }
    // MARK:- setupConstraints
    func setupConstraints() {
        view.addSubview(calendar)
        view.addSubview(tableView)
        view.addSubview(floatingButton)
        
        NSLayoutConstraint.activate([
            calendar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0),
            calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendar.heightAnchor.constraint(equalToConstant: 300),
            tableView.topAnchor.constraint(equalTo: calendar.bottomAnchor, constant: 10),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    @objc func viewModePress() {
        if self.calendar.scope == .month {
            self.calendar.setScope(.week, animated: self.animationSwitch)
           
        } else {
            self.calendar.setScope(.month, animated: self.animationSwitch)
        }
    }
    
    @objc func didTapFloatingButton (){
        let newToDoVC = NewToDoViewController()
        newToDoVC.canResetDate = false
        newToDoVC.newToDoDueDate = "\(displayDate.endOfDay)"
        newToDoVC.dueDateIcon.tintColor = convertColor(calendarTheme)
        newToDoVC.dueDateLabel.textColor = convertColor(calendarTheme)
        newToDoVC.dueDateLabel.text = Date().relativeDate(displayDate)
        
        newToDoVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(newToDoVC, animated: false, completion: nil)
    }
    
    
    func getListTheme(listID : String) -> String {
        
        var listTheme = defaultTaskList.listTheme
        
        for i in self.listData {
            if listID == i.listID {
                listTheme = i.listTheme
                break
            }
        }
        return listTheme
        
    }
    // MARK:- UIGestureRecognizerDelegate
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = self.tableView.contentOffset.y <= -self.tableView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch self.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            @unknown default:
                print("default")
            }
        }
        return shouldBegin
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        //        self.calendarHeightConstraint.constant = bounds.height
        if let constraint = (calendar.constraints.filter{$0.firstAttribute == .height}.first) {
            constraint.constant = bounds.height
            self.view.layoutIfNeeded()
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {

        self.displayDate = date
        self.dateData = self.todoData.filter { Calendar.current.isDate(self.getDate($0.dueDate ?? "\(self.displayDate+100000)"), inSameDayAs: self.displayDate)}
        
        
        switch UserDefaults.standard.string(forKey: "sortBy") {
        case "Importance":
            
            self.dateData.sort {
                $0.isPrioritized && !$1.isPrioritized
            }
            
        case "Alphabet":
            
            self.dateData.sort {
                $0.toDoName < $1.toDoName
            }
            
        default:
            self.dateData.sort {
                self.getDate($0.createDate) > self.getDate($1.createDate)
            }
        }
    
        self.tableView.reloadData()
        
        if monthPosition == .next || monthPosition == .previous {
            calendar.setCurrentPage(date, animated: true)
        }
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("\(self.dateFormatter.string(from: calendar.currentPage))")
    }
    
    // MARK:- UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dateData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
        
        // Set up text, colors and icon for image
        cell.toDoLabel.attributedText = dateData[indexPath.row].toDoName.removeStrikeThrough()
        cell.toDoLabel.textColor = .black
        cell.listLabel.text = dateData[indexPath.row].listName + "  "
        let listTheme = getListTheme(listID: dateData[indexPath.row].listID)
        cell.listLabel.textColor = convertColor(listTheme)
        if let dueDate = dateData[indexPath.row].dueDate {
            cell.dateLabel.text = Date().relativeDate(getDate(dueDate))
            
            if getDate(dueDate) > Date() {
                cell.dateLabel.textColor = .systemBlue
            } else {
                cell.dateLabel.textColor = .red
            }
        }
        if let _ = dateData[indexPath.row].remindTime {
            cell.remindImageView.tintColor = .darkGray
        } else {
            cell.remindImageView.tintColor = .white
        }
        
        if  dateData[indexPath.row].repeatToDo != "none" {
            cell.repeatImageView.tintColor = .darkGray
        } else {
            cell.repeatImageView.tintColor = .white
        }
        
        cell.completeButtonImageView.image = UIImage(named: "circle")
        
        if dateData[indexPath.row].isPrioritized == true {
            cell.prioritizedButtonImageView.image = UIImage(named: "star-fill")!.tinted(with: convertColor(calendarTheme))
        } else {
            cell.prioritizedButtonImageView.image = UIImage(named: "star")!.tinted(with: .lightGray)
        }
        
        // Complete button
        let onTapCompleteGesture = UITapGestureRecognizer(target: self, action: #selector(completeTap(_:)))
        cell.completeButtonImageView.addGestureRecognizer(onTapCompleteGesture)
        
        // Prioritized button
        let onTapPrioritizedGesture = UITapGestureRecognizer(target: self, action: #selector(prioritizedTap(_:)))
        cell.prioritizedButtonImageView.addGestureRecognizer(onTapPrioritizedGesture)
        return cell
        
    }
    // MARK:- completeTap
    
    @objc func completeTap(_ gesture: UITapGestureRecognizer){
        let tapLocation = gesture.location(in: self.tableView)
        if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: pianoSound)
                audioPlayer.play()
            } catch {
                      // error handle
            }
            
            let completedTodo = dateData[tapIndexPath.row]
            completedTodoCollection = userDocument.collection("CompletedToDoData")
            let completedTodoDocument = completedTodoCollection.document(completedTodo.id)
            
            completedTodoDocument.setData(["toDoName": completedTodo.toDoName, "listID" : completedTodo.listID,"listName": completedTodo.listName, "description" : completedTodo.description, "createDate": "\(Date())", "dueDate": completedTodo.dueDate, "remindTime" : completedTodo.remindTime, "repeatToDo" :  "none", "isComplete" : true, "isPrioritized" : completedTodo.isPrioritized, "originalDueDate" : completedTodo.originalDueDate, "originalRemind" : completedTodo.originalRemind , "repeatTimes" : completedTodo.repeatTimes])
            
            todoCollection = userDocument.collection("ToDoData")
   
            // MARK:- Repeat todo
            switch completedTodo.repeatToDo {
            case "daily":
                
                let nextDueDate = Date().nextDayDate(getDate(completedTodo.dueDate ?? "\(Date())"))
                
                var nextToDoRemind : String? = nil
                
                if let remind = completedTodo.remindTime  {
                    let nextRemindDate = Date().nextDayDate(getDate(remind))
                    nextToDoRemind = "\(nextRemindDate)"
                    let  repeatTodoDocument = todoCollection.document(UUID().uuidString)
                    repeatTodoDocument.setData(["toDoName": completedTodo.toDoName, "listID" : completedTodo.listID,"listName": completedTodo.listName, "description" : completedTodo.description, "createDate": "\(Date())", "dueDate": "\(nextDueDate)", "remindTime" :  "\(nextRemindDate)", "repeatToDo" :  completedTodo.repeatToDo, "isComplete" : false, "isPrioritized" : completedTodo.isPrioritized, "originalDueDate" : completedTodo.originalDueDate, "originalRemind" : completedTodo.originalRemind , "repeatTimes" : completedTodo.repeatTimes])
                } else {
                let  repeatTodoDocument = todoCollection.document(UUID().uuidString)
                repeatTodoDocument.setData(["toDoName": completedTodo.toDoName, "listID" : completedTodo.listID,"listName": completedTodo.listName, "description" : completedTodo.description, "createDate": "\(Date())", "dueDate": "\(nextDueDate)", "remindTime" :  nextToDoRemind, "repeatToDo" :  completedTodo.repeatToDo, "isComplete" : false, "isPrioritized" : completedTodo.isPrioritized, "originalDueDate" : completedTodo.originalDueDate, "originalRemind" : completedTodo.originalRemind , "repeatTimes" : completedTodo.repeatTimes])
                
                completedTodo.repeatTimes += 1
                }
            case "weekly":
                
                let nextDueDate = Date().nextWeekDate(getDate(completedTodo.dueDate ?? "\(Date())"))
                
                var nextToDoRemind : String? = nil
                
                if let remind = completedTodo.remindTime  {
                    let nextRemindDate = Date().nextWeekDate(getDate(remind))
                    let  repeatTodoDocument = todoCollection.document(UUID().uuidString)
                    
                    repeatTodoDocument.setData(["toDoName": completedTodo.toDoName, "listID" : completedTodo.listID,"listName": completedTodo.listName, "description" : completedTodo.description, "createDate": "\(Date())", "dueDate": "\(nextDueDate)", "remindTime" :  "\(nextRemindDate)", "repeatToDo" :  completedTodo.repeatToDo, "isComplete" : false, "isPrioritized" : completedTodo.isPrioritized, "originalDueDate" : completedTodo.originalDueDate, "originalRemind" : completedTodo.originalRemind , "repeatTimes" : completedTodo.repeatTimes])
                } else {
                    
                let  repeatTodoDocument = todoCollection.document(UUID().uuidString)
                repeatTodoDocument.setData(["toDoName": completedTodo.toDoName, "listID" : completedTodo.listID,"listName": completedTodo.listName, "description" : completedTodo.description, "createDate": "\(Date())", "dueDate": "\(nextDueDate)", "remindTime" :  nextToDoRemind, "repeatToDo" :  completedTodo.repeatToDo, "isComplete" : false, "isPrioritized" : completedTodo.isPrioritized, "originalDueDate" : completedTodo.originalDueDate, "originalRemind" : completedTodo.originalRemind , "repeatTimes" : completedTodo.repeatTimes])
                }
                
                completedTodo.repeatTimes += 1
                
            case "monthly":
                
                let nextDueDate = Date().nextMonthDate(date: getDate(completedTodo.originalDueDate!), times: completedTodo.repeatTimes+1)
                
                var nextToDoRemind : String? = nil
                if let remind = completedTodo.originalRemind  {
                    let nextRemindDate = Date().nextMonthDate(date: getDate(remind), times: completedTodo.repeatTimes+1)
                    completedTodo.repeatTimes += 1
                    let  repeatTodoDocument = todoCollection.document(UUID().uuidString)
                    
                    repeatTodoDocument.setData(["toDoName": completedTodo.toDoName, "listID" : completedTodo.listID,"listName": completedTodo.listName, "description" : completedTodo.description, "createDate": "\(Date())", "dueDate": "\(nextDueDate)", "remindTime" :  "\(nextRemindDate)", "repeatToDo" :  completedTodo.repeatToDo, "isComplete" : false, "isPrioritized" : completedTodo.isPrioritized, "originalDueDate" : completedTodo.originalDueDate, "originalRemind" : completedTodo.originalRemind , "repeatTimes" : completedTodo.repeatTimes])
                } else {
                    completedTodo.repeatTimes += 1
                let  repeatTodoDocument = todoCollection.document(UUID().uuidString)
                repeatTodoDocument.setData(["toDoName": completedTodo.toDoName, "listID" : completedTodo.listID,"listName": completedTodo.listName, "description" : completedTodo.description, "createDate": "\(Date())", "dueDate": "\(nextDueDate)", "remindTime" :  nextToDoRemind, "repeatToDo" :  completedTodo.repeatToDo, "isComplete" : false, "isPrioritized" : completedTodo.isPrioritized, "originalDueDate" : completedTodo.originalDueDate, "originalRemind" : completedTodo.originalRemind , "repeatTimes" : completedTodo.repeatTimes])
                }
      
            case "yearly":
                let nextDueDate = Date().nextYearDate(date: getDate(completedTodo.originalDueDate!), times: completedTodo.repeatTimes+1)
                
                var nextToDoRemind : String? = nil
                if let remind = completedTodo.originalRemind  {
                    let nextRemindDate = Date().nextYearDate(date: getDate(remind), times: completedTodo.repeatTimes+1)
                    
                    completedTodo.repeatTimes += 1
                    
                    let  repeatTodoDocument = todoCollection.document(UUID().uuidString)
                    
                    repeatTodoDocument.setData(["toDoName": completedTodo.toDoName, "listID" : completedTodo.listID,"listName": completedTodo.listName, "description" : completedTodo.description, "createDate": "\(Date())", "dueDate": "\(nextDueDate)", "remindTime" :  "\(nextRemindDate)", "repeatToDo" :  completedTodo.repeatToDo, "isComplete" : false, "isPrioritized" : completedTodo.isPrioritized, "originalDueDate" : completedTodo.originalDueDate, "originalRemind" : completedTodo.originalRemind , "repeatTimes" : completedTodo.repeatTimes])
                } else {
                completedTodo.repeatTimes += 1
                    
                let  repeatTodoDocument = todoCollection.document(UUID().uuidString)
                repeatTodoDocument.setData(["toDoName": completedTodo.toDoName, "listID" : completedTodo.listID,"listName": completedTodo.listName, "description" : completedTodo.description, "createDate": "\(Date())", "dueDate": "\(nextDueDate)", "remindTime" :  nextToDoRemind, "repeatToDo" :  completedTodo.repeatToDo, "isComplete" : false, "isPrioritized" : completedTodo.isPrioritized, "originalDueDate" : completedTodo.originalDueDate, "originalRemind" : completedTodo.originalRemind , "repeatTimes" : completedTodo.repeatTimes])
                }
                
                completedTodo.repeatTimes += 1
                
            default:
                print("repeat none")
            }
            
            // Delete completed Todo from ToDoData
            let document = todoCollection.document(dateData[tapIndexPath.row].id)
            document.delete()
        }
    }
    
    @objc func prioritizedTap(_ gesture: UITapGestureRecognizer){
        let tapLocation = gesture.location(in: self.tableView)
        if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
            
            todoCollection = userDocument.collection("ToDoData")
            let todoDocument = todoCollection.document(dateData[tapIndexPath.row].id)
            if dateData[tapIndexPath.row].isPrioritized == true {
                todoDocument.updateData(["isPrioritized": false])
            } else {
                todoDocument.updateData(["isPrioritized": true])
            }
        }
    }
    
    // MARK:- UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //        tableView.deselectRow(at: indexPath, animated: true)
        let editVC = EditViewController()
        editVC.pushedFromCompletedSection = false
        editVC.todo = dateData[indexPath.row]
        editVC.listData = self.listData
        
        editVC.backLabel.text = "Calendar"
        editVC.editTheme = "defaultBlue"
        
        
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction (style: .normal, title: "Delete") { action, view, closure  in
            self.todoCollection = self.userDocument.collection("ToDoData")
            let document = self.todoCollection.document(self.dateData[indexPath.row].id)
            document.delete()
        }
        delete.backgroundColor = #colorLiteral(red: 0.9208939678, green: 0.9208939678, blue: 0.9208939678, alpha: 1)
        let actionConfig = UISwipeActionsConfiguration(actions: [delete])
        return actionConfig
    }
    
}
