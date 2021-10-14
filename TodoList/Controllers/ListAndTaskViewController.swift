//
//  ListAndTaskViewController.swift
//  TodoList
//
//  Created by Apple on 19/09/2021.
//

import UIKit
//import SideMenu
import Firebase
import FirebaseFirestore
import AVFoundation

class ListAndTaskViewController: UIViewController {
    
    let db = Firestore.firestore().collection("users")
    var userDocument: DocumentReference!
    var todoCollection: CollectionReference!
    var completedTodoCollection: CollectionReference!
    var listCollection: CollectionReference!
    
    var list = defaultTaskList
    var todoData = [Todo]()
    var completedData = [Todo]()
    var listData = [Todo]()
    var listCompletedData = [Todo]()
    
//    var menu : SideMenuNavigationController?
    // TableView
    let tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        return table
    }()
    
    var isCollapsed = false
    var listAndTaskTheme = "defaultBlue"
    
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
    
    let pianoSound = URL(fileURLWithPath: Bundle.main.path(forResource: "prist", ofType: "mp3")!)
      var audioPlayer = AVAudioPlayer()

    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        // Navigation Bar
        self.navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.tintColor = convertColor(listAndTaskTheme)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .regular),NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30, weight: .regular),NSAttributedString.Key.foregroundColor: UIColor.black]
        
        // side menu
//        menu = SideMenuNavigationController(rootViewController: SideMenuViewController())
//        menu?.leftSide = true
//        menu?.setNavigationBarHidden(true, animated: false)
//        SideMenuManager.default.leftMenuNavigationController = menu
//        SideMenuManager.default.addPanGestureToPresent(toView: self.navigationController!.navigationBar)
//
//        SideMenuManager.default.leftMenuNavigationController?.statusBarEndAlpha = 0
//
//        let sideMenu = UIBarButtonItem(image: UIImage(named: "sidemenu"), style: .done, target: self, action: #selector(sideMenu))
//        navigationItem.leftBarButtonItem = sideMenu
        
        self.addLeftBarButtonWithImage(UIImage(named: "sidemenu")!)
        
        let optionMenu = UIBarButtonItem(image: UIImage(named: "optionmenu"), style: .done, target: self, action: #selector(optionMenu))
        navigationItem.rightBarButtonItem = optionMenu
        
        // Setup table view
        setupConstraints()
        tableView.delegate = self
        tableView.dataSource = self
        let footerView = UIView()
        footerView.frame.size.height = 1
        tableView.tableFooterView = footerView
        self.tableView.backgroundColor =  #colorLiteral(red: 0.9208939678, green: 0.9208939678, blue: 0.9208939678, alpha: 1)
        tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        
        // setup floating button
        floatingButton.addTarget(self, action: #selector(didTapFloatingButton), for: .touchUpInside)
        floatingButton.backgroundColor = convertColor(listAndTaskTheme)
        
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        floatingButton.frame = CGRect(x: view.frame.size.width - 85, y: view.frame.size.height - 90, width: 66, height: 66)
    }
    
    // MARK: - fetchData
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
            
            querySnapshot.documentChanges.forEach { diff in
                switch diff.type {
                case  .added:
                    let data = diff.document.data()
                    if self.list.listID == data["listID"] as! String {
                        
                        self.listData.insert(Todo.init(diff.document.documentID, data["toDoName"] as! String, data["listID"] as! String, data["listName"] as! String, data["description"] as! String, data["dueDate"] as? String, data["remindTime"] as? String, data["repeatToDo"] as! String, data["isComplete"] as! Bool, data["isPrioritized"] as! Bool, data["originalDueDate"] as? String, data["originalRemind"] as? String, data["repeatTimes"] as! Int), at: 0)
                        
                        switch UserDefaults.standard.string(forKey: "sortBy") {
                        case "Importance":
                            self.listData.sort {
                                $0.isPrioritized && !$1.isPrioritized
                            }
                            
                        case "Alphabet":
                            
                            self.listData.sort {
                                $0.toDoName < $1.toDoName
                            }
                            
                        default:
                            self.listData.sort {
                                self.getDate($0.createDate) > self.getDate($1.createDate)
                            }
                        }
                        
                        for (index, item) in self.listData.enumerated() {
                            if item.id == diff.document.documentID {
                                self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                                break
                            }
                        }
                        
//                        self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
                    }
                    
                    
                    if let remindTime = data["remindTime"] as? String {
                        notiManager.notifications.append(Notification(id: diff.document.documentID, title: data["toDoName"] as! String, datetime: self.getDate(remindTime)))
                        
                        notiManager.schedule()
                    }
                    
                case  .modified:
                    let data = diff.document.data()
                    for (index, item) in self.listData.enumerated() {
                        if item.id == diff.document.documentID {
                            
                            if self.list.listID == data["listID"] as! String {
                                item.toDoName = data["toDoName"] as! String
                                item.description = data["description"] as! String
                                item.dueDate = data["dueDate"] as? String
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
                                
                                for (index, item) in self.listData.enumerated() {
                                    if item.id == diff.document.documentID {
                                        oldRow = index
                                        break
                                    }
                                }
                                
                                switch UserDefaults.standard.string(forKey: "sortBy") {
                                case "Importance":
                                    
                                    self.listData.sort {
                                        $0.isPrioritized && !$1.isPrioritized
                                    }
                                    
                                case "Alphabet":
                                    
                                    self.listData.sort {
                                        $0.toDoName < $1.toDoName
                                    }
                                    
                                default:
                                    self.listData.sort {
                                        self.getDate($0.createDate) > self.getDate($1.createDate)
                                    }
                                }
                                
                                for (index, item) in self.listData.enumerated() {
                                    if item.id == diff.document.documentID {
                                        newRow = index
                                        break
                                    }
                                }
                                self.tableView.moveRow(at: IndexPath(row: oldRow, section: 0), to: IndexPath(row: newRow, section: 0))
                                
                                break
                            } else {
                                self.listData.remove(at: index)
                                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                                break
                            }
                        }
                    }
                    
                case .removed:
                    let data = diff.document.data()
                    
                    for (index, item) in self.listData.enumerated() {
                        if item.id == diff.document.documentID {
                            self.listData.remove(at: index)
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
        
        completedTodoCollection = userDocument.collection("CompletedToDoData")
        completedTodoCollection.addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else {
                return
            }
            
            querySnapshot.documentChanges.forEach { diff in
                switch diff.type {
                case  .added:
                    let data = diff.document.data()
                    if self.list.listID == data["listID"] as! String {
                        self.listCompletedData.insert(Todo.init(diff.document.documentID, data["toDoName"] as! String, data["listID"] as! String, data["listName"] as! String, data["description"] as! String, data["dueDate"] as? String, data["remindTime"] as? String, data["repeatToDo"] as! String, data["isComplete"] as! Bool, data["isPrioritized"] as! Bool,data["originalDueDate"] as? String,  data["originalRemind"] as? String, data["repeatTimes"] as! Int), at: 0)
                        
                        self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                        
                    }
                    
                case  .modified:
                    let data = diff.document.data()
                    for (index, item) in self.listCompletedData.enumerated() {
                        
                        
                        if self.list.listID == data["listID"] as! String {
                            item.toDoName = data["toDoName"] as! String
                            item.description = data["description"] as! String
                            item.dueDate = data["dueDate"] as? String
                            item.remindTime = data["remindTime"] as? String
                            item.repeatToDo = data["repeatToDo"] as! String
                            item.isComplete = data["isComplete"] as! Bool
                            item.isPrioritized = data["isPrioritized"] as! Bool
                            item.originalDueDate = data["originalDueDate"] as? String
                            item.originalRemind = data["originalRemind"] as? String
                            item.repeatTimes = data["repeatTimes"] as! Int
                            
                            self.tableView.reloadData()
                            break
                        } else {
                            self.listCompletedData.remove(at: index)
                            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                            break
                        }
                    }
                    
                    
                case .removed:
                    for (index, item) in self.listCompletedData.enumerated() {
                        if item.id == diff.document.documentID {
                            self.listCompletedData.remove(at: index)
                            self.tableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .fade)
                            break
                        }
                    }
                }
            }
        }
    }
    
    
    // MARK: - setupConstraints
    func setupConstraints() {
        
        view.addSubview(tableView)
        view.addSubview(floatingButton)
        tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
//    
//    @objc func sideMenu(){
//        present(menu!, animated: true, completion: nil)
//    }
//    
    @objc func optionMenu(){
        
        guard let user = Auth.auth().currentUser else {
            return
        }
        
        let alert = UIAlertController(title: nil, message: nil , preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Sort by", style: .default, handler: { action in

            let sortAlert = UIAlertController(title: "Sort by", message: nil , preferredStyle: .actionSheet)
            
            sortAlert.addAction(UIAlertAction(title: "Importance", style: .default, handler: { action in
                UserDefaults.standard.set("Importance", forKey: "sortBy")
                
                self.listData.sort {
                    $0.isPrioritized && !$1.isPrioritized
                }
                
                self.tableView.reloadData()
            }))
            
            sortAlert.addAction(UIAlertAction(title: "Creation Date", style: .default, handler: { action in
                UserDefaults.standard.set("Creation Date", forKey: "sortBy")
                
                self.listData.sort {
                    self.getDate($0.createDate) > self.getDate($1.createDate)
                }
                
                self.tableView.reloadData()
                
            }))
            
            
            sortAlert.addAction(UIAlertAction(title: "Alphabet", style: .default, handler: { action in
                UserDefaults.standard.set("Alphabet", forKey: "sortBy")
                
                self.listData.sort {
                    $0.toDoName < $1.toDoName
                }
                
                self.tableView.reloadData()
                
            }))
            
            sortAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
                
            }))
            
            self.present(sortAlert, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Choose Theme", style: .default, handler: { action in
            
            let themeAlert = UIAlertController(title: "Theme", message: nil , preferredStyle: .actionSheet)
            themeAlert.addAction(UIAlertAction(title: "Blue", style: .default, handler: { [self] action in
             
                self.listAndTaskTheme = "blue"
                
                self.navigationController?.navigationBar.tintColor = self.convertColor(self.listAndTaskTheme)
                self.floatingButton.backgroundColor = self.convertColor(self.listAndTaskTheme)
                self.tableView.reloadData()
                
                if self.list !== defaultTaskList {
                    self.userDocument = self.db.document(user.uid)
                    self.todoCollection = self.userDocument.collection("Lists")
                    let listDocument = self.todoCollection.document(self.list.listID)
                    listDocument.updateData(["listTheme": "defaultBlue"])
                } else {
                    UserDefaults.standard.set("defaultBlue", forKey: "taskTheme")
                }
                
            }))
            
            themeAlert.addAction(UIAlertAction(title: "Red", style: .default, handler: { action in
                self.listAndTaskTheme = "red"
                self.navigationController?.navigationBar.tintColor = self.convertColor(self.listAndTaskTheme)
                self.floatingButton.backgroundColor = self.convertColor(self.listAndTaskTheme)
                self.tableView.reloadData()
                
                if self.list !== defaultTaskList {
                    self.userDocument = self.db.document(user.uid)
                    self.todoCollection = self.userDocument.collection("Lists")
                    let listDocument = self.todoCollection.document(self.list.listID)
                    listDocument.updateData(["listTheme": "red"])
                    
                }  else {
                    UserDefaults.standard.set("red", forKey: "taskTheme")
                }
            }))
            
            themeAlert.addAction(UIAlertAction(title: "Purple", style: .default, handler: { action in
                self.listAndTaskTheme = "purple"
                self.navigationController?.navigationBar.tintColor = self.convertColor(self.listAndTaskTheme)
                self.floatingButton.backgroundColor = self.convertColor(self.listAndTaskTheme)
                self.tableView.reloadData()
                
                if self.list !== defaultTaskList {
                    self.userDocument = self.db.document(user.uid)
                    self.todoCollection = self.userDocument.collection("Lists")
                    let listDocument = self.todoCollection.document(self.list.listID)
                    listDocument.updateData(["listTheme": "purple"])
                    
                } else {
                    UserDefaults.standard.set("purple", forKey: "taskTheme")
                }
            }))
            
            themeAlert.addAction(UIAlertAction(title: "Green", style: .default, handler: { action in
                self.listAndTaskTheme = "green"
                self.navigationController?.navigationBar.tintColor = self.convertColor(self.listAndTaskTheme)
                self.floatingButton.backgroundColor = self.convertColor(self.listAndTaskTheme)
                self.tableView.reloadData()
                
                if self.list !== defaultTaskList {
                    self.userDocument = self.db.document(user.uid)
                    self.todoCollection = self.userDocument.collection("Lists")
                    let listDocument = self.todoCollection.document(self.list.listID)
                    listDocument.updateData(["listTheme": "green"])
                } else {
                    UserDefaults.standard.set("green", forKey: "taskTheme")
                }
            }))
            
            themeAlert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
                
            }))
            self.present(themeAlert, animated: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
            
        }))
        
        self.present(alert, animated: true)
    }
    
    @objc func didTapFloatingButton (){
        let newToDoVC = NewToDoViewController()
        if list !== defaultTaskList {
            newToDoVC.canResetList = false
            newToDoVC.newToDoList = list
            newToDoVC.listIcon.tintColor = convertColor(listAndTaskTheme)
            newToDoVC.listLabel.textColor = convertColor(listAndTaskTheme)
            newToDoVC.listLabel.text = list.listName
        }
        newToDoVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(newToDoVC, animated: false, completion: nil)
    }
    
}

// MARK: - UITableViewDelegate
extension ListAndTaskViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView (_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return listData.count
        case 1:
            if isCollapsed == true {
                return 0
            } else {
                return listCompletedData.count
            }
        default:
            return 0
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return nil
        case 1:
            let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
            sectionView.backgroundColor = #colorLiteral(red: 0.9208939678, green: 0.9208939678, blue: 0.9208939678, alpha: 1)
            sectionView.isUserInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action:#selector(self.sectionTap(_:)))
            sectionView.addGestureRecognizer(tap)
            
            let label = UILabel()
            label.text = "Completed"
            label.font = UIFont.systemFont(ofSize: 17, weight: .light)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let arrowImage = UIImageView()
            arrowImage.tintColor = .darkGray
            arrowImage.translatesAutoresizingMaskIntoConstraints = false
            if isCollapsed == false {
                arrowImage.image = UIImage(systemName: "arrow.down")
            } else {
                arrowImage.image = UIImage(systemName: "arrow.right")
            }
            
            sectionView.addSubview(label)
            sectionView.addSubview(arrowImage)
            
            arrowImage.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor, constant: 10).isActive = true
            arrowImage.centerYAnchor.constraint(equalTo: sectionView.centerYAnchor, constant: 0).isActive = true
            arrowImage.widthAnchor.constraint(equalToConstant: 16).isActive = true
            arrowImage.heightAnchor.constraint(equalToConstant: 16).isActive = true
            
            label.centerYAnchor.constraint(equalTo: arrowImage.centerYAnchor, constant: 0).isActive = true
            label.leadingAnchor.constraint(equalTo: arrowImage.leadingAnchor, constant: 20).isActive = true
            label.widthAnchor.constraint(equalTo: sectionView.widthAnchor, multiplier: 1).isActive = true
            label.heightAnchor.constraint(equalToConstant: 20).isActive = true
            
            return sectionView
        default:
            return UIView()
        }
    }
    
    @objc func sectionTap(_ sender: UITapGestureRecognizer) {
        if isCollapsed == false {
            isCollapsed = true
            self.tableView.reloadData()
        } else {
            isCollapsed = false
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let editVC = EditViewController()
        if indexPath.section == 0 {
            editVC.pushedFromCompletedSection = false
            editVC.todo = listData[indexPath.row]
            editVC.listData = [list]
            editVC.backLabel.text = list.listName
            editVC.editTheme = listAndTaskTheme
            
        } else {
            editVC.pushedFromCompletedSection = true
            editVC.todo = listCompletedData[indexPath.row]
            editVC.listData = [list]
            editVC.backLabel.text = list.listName
            editVC.editTheme = listAndTaskTheme
            
            
        }
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
        case 0:
            let delete = UIContextualAction (style: .destructive, title: "Delete") { _, _, _  in
                self.todoCollection = self.userDocument.collection("ToDoData")
                let document = self.todoCollection.document(self.listData[indexPath.row].id)
                document.delete()
            }
            delete.backgroundColor = #colorLiteral(red: 0.9208939678, green: 0.9208939678, blue: 0.9208939678, alpha: 1)
            let actionConfig = UISwipeActionsConfiguration(actions: [delete])
            return actionConfig
        case 1:
            let delete = UIContextualAction (style: .normal, title: "Delete") { action, view, closure  in
                self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
                let document = self.completedTodoCollection.document(self.listCompletedData[indexPath.row].id)
                document.delete()
            }
            delete.backgroundColor = #colorLiteral(red: 0.9208939678, green: 0.9208939678, blue: 0.9208939678, alpha: 1)
            let actionConfig = UISwipeActionsConfiguration(actions: [delete])
            return actionConfig
        default:
            return UISwipeActionsConfiguration()
        }
    }
    
    
}

// MARK: - UITableViewDataSource
extension ListAndTaskViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
            
            // Set up text, colors and icon for image
            cell.toDoLabel.attributedText = listData[indexPath.row].toDoName.removeStrikeThrough()
            cell.toDoLabel.textColor = .black
            cell.listLabel.text = ""
            
            if let dueDate = listData[indexPath.row].dueDate {
                cell.dateLabel.isHidden = false
                cell.dateLabel.text = Date().relativeDate(getDate(dueDate))
                
                if getDate(dueDate) > Date() {
                    cell.dateLabel.textColor = .systemBlue
                } else {
                    cell.dateLabel.textColor = .red
                }
            }  else {
                cell.dateLabel.isHidden = true
                }
            
            if let _ = listData[indexPath.row].remindTime {
                cell.remindImageView.tintColor = .darkGray
            }  else {
                cell.remindImageView.tintColor = .white
            }
            
            if  listData[indexPath.row].repeatToDo != "none" {
                cell.repeatImageView.tintColor = .darkGray
            } else {
                cell.repeatImageView.tintColor = .white
            }
            
            cell.completeButtonImageView.image = UIImage(named: "circle")

            if listData[indexPath.row].isPrioritized == true {
                cell.prioritizedButtonImageView.image = UIImage(named: "star-fill")!.tinted(with: convertColor(listAndTaskTheme))
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
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
            
            // Set up text, colors and icon for image
            cell.toDoLabel.attributedText = listCompletedData[indexPath.row].toDoName.strikeThrough()
            cell.toDoLabel.textColor = .lightGray
            cell.listLabel.text = ""
            
            
            if let dueDate = listCompletedData[indexPath.row].dueDate {
                cell.dateLabel.text = Date().relativeDate(getDate(dueDate))
                
                if getDate(dueDate) > Date() {
                    cell.dateLabel.textColor = .systemBlue
                } else {
                    cell.dateLabel.textColor = .red
                }
            } else {
            cell.dateLabel.isHidden = true
            }
            
            if let _ = listCompletedData[indexPath.row].remindTime {
                cell.remindImageView.tintColor = .lightGray
            } else {
                cell.remindImageView.tintColor = .white
            }
            
            if  listCompletedData[indexPath.row].repeatToDo != "none" {
                cell.repeatImageView.tintColor = .lightGray
            } else {
                cell.repeatImageView.tintColor = .white
            }
            
            cell.completeButtonImageView.image = UIImage(named: "check")!.tinted(with: .lightGray)
            
            if listCompletedData[indexPath.row].isPrioritized == true {
                cell.prioritizedButtonImageView.image = UIImage(named: "star-fill")!.tinted(with: .lightGray)
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
        default:
            return UITableViewCell()
        }
        
    }
    @objc func completeTap(_ gesture: UITapGestureRecognizer){
        let tapLocation = gesture.location(in: self.tableView)
        if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
            //          if let tappedCell = self.tableView.cellForRow(at: tapIndexPath) as? TableViewCell {
            if tapIndexPath.section == 0 {
                   
                    do {
                                audioPlayer = try AVAudioPlayer(contentsOf: pianoSound)
                                audioPlayer.play()
                           } catch {
                              // error handle
                           }
                    
                let completedTodo = listData[tapIndexPath.row]
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
                let document = todoCollection.document(listData[tapIndexPath.row].id)
                document.delete()
                
            } else {
                let reversedTodo = listCompletedData[tapIndexPath.row]
                todoCollection = userDocument.collection("ToDoData")
                let reversedTodoDocument = todoCollection.document(reversedTodo.id)
                reversedTodoDocument.setData(["toDoName": reversedTodo.toDoName, "listID" : reversedTodo.listID,"listName": reversedTodo.listName, "description" : reversedTodo.description, "createDate": "\(Date())", "dueDate": reversedTodo.dueDate, "remindTime" : reversedTodo.remindTime, "repeatToDo" :  reversedTodo.repeatToDo, "isComplete" : false, "isPrioritized" : reversedTodo.isPrioritized, "originalDueDate" : reversedTodo.originalDueDate, "originalRemind" : reversedTodo.originalRemind , "repeatTimes" : reversedTodo.repeatTimes])
                
                completedTodoCollection = userDocument.collection("CompletedToDoData")
                let document = completedTodoCollection.document(listCompletedData[tapIndexPath.row].id)
                document.delete()
                
            }
            
        }
    }
    
    @objc func prioritizedTap(_ gesture: UITapGestureRecognizer){
        let tapLocation = gesture.location(in: self.tableView)
        if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
            switch tapIndexPath.section {
            case 0 :
                todoCollection = userDocument.collection("ToDoData")
                let todoDocument = todoCollection.document(listData[tapIndexPath.row].id)
                if listData[tapIndexPath.row].isPrioritized == true {
                    todoDocument.updateData(["isPrioritized": false])
                } else {
                    todoDocument.updateData(["isPrioritized": true])
                }
                
            case 1:
                completedTodoCollection = userDocument.collection("CompletedToDoData")
                let completedTodoDocument = completedTodoCollection.document(listCompletedData[tapIndexPath.row].id)
                
                if listCompletedData[tapIndexPath.row].isPrioritized == true {
                    completedTodoDocument.updateData(["isPrioritized": false])
                } else {
                    completedTodoDocument.updateData(["isPrioritized": true])
                }
                
            default:
                print("default")
            }
        }
    }
}
