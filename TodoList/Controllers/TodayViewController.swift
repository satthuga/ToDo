//
//  TodayViewController.swift
//  TodoList
//
//  Created by Apple on 09/09/2021.
//

//import SideMenu
import UIKit
import Firebase
import FirebaseFirestore
import AVFoundation

class TodayViewController: UIViewController {
    
    let db = Firestore.firestore().collection("users")
    var userDocument: DocumentReference!
    var todoCollection: CollectionReference!
    var completedTodoCollection: CollectionReference!
    var listCollection: CollectionReference!
    
    var listData = [List]()
    var todoData = [Todo]()
    var completedData = [Todo]()
    var todayData = [Todo]()
    var todayCompletedData = [Todo]()
    
//    var menu : SideMenuNavigationController?
    
    
    // TableView
    let tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        return table
    }()
    
    var isCollapsed = false
    var todayTheme = UserDefaults.standard.string(forKey: "todayTheme") ?? ""
    
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
    
    
    // MARK: -viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        // Navigation Bar
        self.navigationController?.isNavigationBarHidden = false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM dd"
        
        self.navigationItem.title = dateFormatter.string(from: Date()) + "  ☁️"
        
        currentWeather(city: "hanoi", appid: "2709af9ee3a443c96e5c8a30ac695658")
        
        navigationController?.navigationBar.tintColor = convertColor(todayTheme)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.titleTextAttributes = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .regular),NSAttributedString.Key.foregroundColor: UIColor.black]
        navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedString.Key.font: UIFont.systemFont(ofSize: 26, weight: .regular),NSAttributedString.Key.foregroundColor: UIColor.black]
        
        
        // menu action
        self.addLeftBarButtonWithImage(UIImage(named: "sidemenu")!)
        
        let optionMenu = UIBarButtonItem(image: UIImage(named: "optionmenu"), style: .done, target: self, action: #selector(optionMenu))
        navigationItem.rightBarButtonItem = optionMenu
        
        fetchData()
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
        floatingButton.backgroundColor = convertColor(todayTheme)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        floatingButton.frame = CGRect(x: view.frame.size.width - 85, y: view.frame.size.height - 90, width: 66, height: 66)
    }
    
    func currentWeather(city: String, appid: String) {
        var urlString = "https://api.openweathermap.org/data/2.5/weather"
        urlString += "?"
        urlString += "q=\(city)"
        urlString += "&"
        urlString += "appid=\(appid)"
        let url = URL.init(string: urlString)
        var request = URLRequest.init(url: url!)
        
        //ProgressHud.show
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let weather = Weather.init(data: responseJSON)
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "EEEE, MMMM dd"
                    
                    DispatchQueue.main.async {
                        self.navigationItem.title = dateFormatter.string(from: Date()) + self.getEmoji(weather.main)
                        
                        print(weather.main)
                    }
                }
                
            }
        }
        task.resume()
    }
    
    
    func getEmoji(_ weather : String) -> String {
        
        let hour = Calendar.current.component(.hour, from: Date())
        switch weather {
        case "Clouds":
            if hour > 6 && hour < 18 {
                return "  🌤"
            } else {
                return "  ☁️"
            }
        case "Fog","Drizzle", "Haze", "Smoke","Mist":
            return "  🌁"
            
        case "Rain" :
            return "  🌧"
            
        case "Thunderstorm":
            return "  ⛈"
            
        case "Tornado", "Squall":
            return "  🌪"
            
        case "Snow":
            return "  🎄☃️"
            
        case "Clear":
            if hour > 6 && hour < 18 {
                return "  ☀️"
            } else {
                return "  ✨"
            }
        default:
            return "  ☁️"
        }
    }
    
    
    
    // MARK: - fetchData
    func fetchData() {
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
                    if let dueDate = data["dueDate"] as? String {
                        
                        if Calendar.current.isDate(self.getDate(dueDate), inSameDayAs: Date()) {
                            
                            self.todayData.insert(Todo.init(diff.document.documentID, data["toDoName"] as! String, data["listID"] as! String, data["listName"] as! String, data["description"] as! String, data["dueDate"] as? String, data["remindTime"] as? String, data["repeatToDo"] as! String, data["isComplete"] as! Bool, data["isPrioritized"] as! Bool, data["originalDueDate"] as? String, data["originalRemind"] as? String, data["repeatTimes"] as! Int ), at: 0)
                            
                            switch UserDefaults.standard.string(forKey: "sortBy") {
                            case "Importance":
                                self.todayData.sort {
                                    $0.isPrioritized && !$1.isPrioritized
                                }
                                
                            case "Alphabet":
                                
                                self.todayData.sort {
                                    $0.toDoName < $1.toDoName
                                }
                                
                            default:
                                self.todayData.sort {
                                    self.getDate($0.createDate) > self.getDate($1.createDate)
                                }
                            }
                            
                            for (index, item) in self.todayData.enumerated() {
                                if item.id == diff.document.documentID {
                                    self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                                    break
                                }
                            }
                        }
                    }
                    
                    if let remindTime = data["remindTime"] as? String {
                        notiManager.notifications.append(Notification(id: diff.document.documentID, title: data["toDoName"] as! String, datetime: self.getDate(remindTime)))
                        
                        notiManager.schedule()
                    }
                    
                case  .modified:
                    let data = diff.document.data()
                    for (index, item) in self.todayData.enumerated() {
                        if item.id == diff.document.documentID {
                            
                            guard let dueDate = data["dueDate"] else {
                                self.todayData.remove(at: index)
                                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                                return }
                            
                            if Calendar.current.isDate(self.getDate(dueDate as? String ?? "\(Date()+100000)"), inSameDayAs: Date()) {
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
                                
                                for (index, item) in self.todayData.enumerated() {
                                    if item.id == diff.document.documentID {
                                        oldRow = index
                                        break
                                    }
                                }
                                
                                switch UserDefaults.standard.string(forKey: "sortBy") {
                                case "Importance":
                                    
                                    self.todayData.sort {
                                        $0.isPrioritized && !$1.isPrioritized
                                    }
                                    
                                case "Alphabet":
                                    
                                    self.todayData.sort {
                                        $0.toDoName < $1.toDoName
                                    }
                                    
                                default:
                                    self.todayData.sort {
                                        self.getDate($0.createDate) > self.getDate($1.createDate)
                                    }
                                }
                                
                                for (index, item) in self.todayData.enumerated() {
                                    if item.id == diff.document.documentID {
                                        newRow = index
                                        break
                                    }
                                }
                                
                                self.tableView.moveRow(at: IndexPath(row: oldRow, section: 0), to: IndexPath(row: newRow, section: 0))
                                
                                break
                            } else {
                                self.todayData.remove(at: index)
                                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                                break
                            }
                        }
                    }
                    
                case .removed:
                    let data = diff.document.data()
                    
                    for (index, item) in self.todayData.enumerated() {
                        if item.id == diff.document.documentID {
                            self.todayData.remove(at: index)
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
                    if let dueDate = data["dueDate"] as? String {
                        if Calendar.current.isDate(self.getDate(dueDate), inSameDayAs: Date()) {
                            self.todayCompletedData.insert(Todo.init(diff.document.documentID, data["toDoName"] as! String, data["listID"] as! String, data["listName"] as! String, data["description"] as! String, data["dueDate"] as? String, data["remindTime"] as? String, data["repeatToDo"] as! String, data["isComplete"] as! Bool, data["isPrioritized"] as! Bool,data["originalDueDate"] as? String, data["originalRemind"] as? String, data["repeatTimes"] as! Int), at: 0)
                            
                            self.tableView.insertRows(at: [IndexPath(row: 0, section: 1)], with: .fade)
                        }
                    }
                    
                case  .modified:
                    let data = diff.document.data()
                    for (index, item) in self.todayCompletedData.enumerated() {
                        
                        guard let dueDate = data["dueDate"] else {
                            self.todayCompletedData.remove(at: index)
                            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                            return }
                        
                        if Calendar.current.isDate(self.getDate(dueDate as? String ?? "\(Date()+100000)"), inSameDayAs: Date()) {
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
                            break
                        } else {
                            self.todayCompletedData.remove(at: index)
                            self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
                            break
                        }
                    }
                    
                case .removed:
                    for (index, item) in self.todayCompletedData.enumerated() {
                        if item.id == diff.document.documentID {
                            self.todayCompletedData.remove(at: index)
                            self.tableView.deleteRows(at: [IndexPath(row: index, section: 1)], with: .fade)
                            break
                        }
                    }
                }
            }
        }
        
        listCollection = userDocument.collection("Lists")
        listCollection.addSnapshotListener { querySnapshot, error in
            guard let querySnapshot = querySnapshot else {
                return
            }
            self.listData = querySnapshot.documents.map({
                return List.init(snapShot: $0)
            })
            
            self.tableView.reloadData()
        }
        
        userDocument.getDocument { snapshot, error in
            guard let data = snapshot?.data() as? [String : String],
                  let firstName = data["firstName"], let lastName = data["lastName"] else {
                print("Data was empty")
                return
            }
            UserDefaults.standard.set(firstName + " " + lastName, forKey: "userName")
        }
    }
    
    // Setup Constraints
    func setupConstraints() {
        
        view.addSubview(tableView)
        view.addSubview(floatingButton)
        tableView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
//    @objc func sideMenu(){
//        present(menu!, animated: true, completion: nil)
//    }
//
    @objc func optionMenu(){
        let alert = UIAlertController(title: nil, message: nil , preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Sort by", style: .default, handler: { action in

            let sortAlert = UIAlertController(title: "Sort by", message: nil , preferredStyle: .actionSheet)
            
            sortAlert.addAction(UIAlertAction(title: "Importance", style: .default, handler: { action in
                UserDefaults.standard.set("Importance", forKey: "sortBy")

                self.todayData.sort {
                    $0.isPrioritized && !$1.isPrioritized
                }

                self.tableView.reloadData()
          
            }))
            
            sortAlert.addAction(UIAlertAction(title: "Creation Date", style: .default, handler: { action in
                UserDefaults.standard.set("Creation Date", forKey: "sortBy")
                
                self.todayData.sort {
                    self.getDate($0.createDate) > self.getDate($1.createDate)
                }
                
                self.tableView.reloadData()
                
            }))
            
            
            sortAlert.addAction(UIAlertAction(title: "Alphabet", style: .default, handler: { action in
                UserDefaults.standard.set("Alphabet", forKey: "sortBy")
                
                self.todayData.sort {
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
                
                themeAlert.addAction(UIAlertAction(title: "Blue", style: .default, handler: { action in
                    UserDefaults.standard.set("defaultBlue", forKey: "todayTheme")
                    self.todayTheme = UserDefaults.standard.string(forKey: "todayTheme") ?? ""
                    
                    self.navigationController?.navigationBar.tintColor = self.convertColor(self.todayTheme)
                    self.floatingButton.backgroundColor = self.convertColor(self.todayTheme)
                    self.tableView.reloadData()
                }))
                
                themeAlert.addAction(UIAlertAction(title: "Red", style: .default, handler: { action in
                    UserDefaults.standard.set("red", forKey: "todayTheme")
                    self.todayTheme = UserDefaults.standard.string(forKey: "todayTheme") ?? ""
                    
                    self.navigationController?.navigationBar.tintColor = self.convertColor(self.todayTheme)
                    self.floatingButton.backgroundColor = self.convertColor(self.todayTheme)
                    self.tableView.reloadData()
                    
                }))
                
                themeAlert.addAction(UIAlertAction(title: "Purple", style: .default, handler: { action in
                    UserDefaults.standard.set("purple", forKey: "todayTheme")
                    self.todayTheme = UserDefaults.standard.string(forKey: "todayTheme") ?? ""
                    
                    self.navigationController?.navigationBar.tintColor = self.convertColor(self.todayTheme)
                    self.floatingButton.backgroundColor = self.convertColor(self.todayTheme)
                    self.tableView.reloadData()
                }))
            
                themeAlert.addAction(UIAlertAction(title: "Green", style: .default, handler: { action in
                    UserDefaults.standard.set("green", forKey: "todayTheme")
                    self.todayTheme = UserDefaults.standard.string(forKey: "todayTheme") ?? ""
                    
                    self.navigationController?.navigationBar.tintColor = self.convertColor(self.todayTheme)
                    self.floatingButton.backgroundColor = self.convertColor(self.todayTheme)
                    self.tableView.reloadData()
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
        newToDoVC.canResetDate = false
        newToDoVC.newToDoDueDate = "\(Date().endOfDay)"
        newToDoVC.dueDateIcon.tintColor = convertColor(todayTheme)
        newToDoVC.dueDateLabel.textColor = convertColor(todayTheme)
        newToDoVC.dueDateLabel.text = "Today"
        
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
}
// MARK: - UITableViewDelegate

extension TodayViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView (_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return todayData.count
        case 1:
            if isCollapsed == true {
                return 0
            } else {
                return todayCompletedData.count
            }
        default:
            return 0
        }
    }
    
    // Completed header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            return nil
        case 1:
            let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 50))
            sectionView.backgroundColor = #colorLiteral(red: 0.9208939678, green: 0.9208939678, blue: 0.9208939678, alpha: 1)
            let label = UILabel()
            label.text = "Completed"
            label.font = UIFont.systemFont(ofSize: 17, weight: .light)
            label.textColor = .darkGray
            label.translatesAutoresizingMaskIntoConstraints = false
            
            let tap = UITapGestureRecognizer(target: self, action:#selector(self.sectionTap(_:)))
            sectionView.addGestureRecognizer(tap)
            
            let arrowImage = UIImageView()
            arrowImage.tintColor = .darkGray
            arrowImage.translatesAutoresizingMaskIntoConstraints = false
            if isCollapsed == false {
                arrowImage.image = UIImage(systemName: "arrow.down")
            } else {
                arrowImage.image = UIImage(systemName: "arrow.right")
            }
            
            sectionView.isUserInteractionEnabled = true
            
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
            editVC.todo = todayData[indexPath.row]
            editVC.listData = self.listData
            editVC.backLabel.text = "Today"
            editVC.editTheme = todayTheme
        } else {
            editVC.backLabel.text = "Today"
            editVC.editTheme = todayTheme
            editVC.pushedFromCompletedSection = true
            editVC.todo = todayCompletedData[indexPath.row]
            editVC.listData = self.listData
        }
        self.navigationController?.pushViewController(editVC, animated: true)
    }
    
    // Delete button
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
        case 0:
            let delete = UIContextualAction (style: .destructive, title: "Delete") { action, view, closure  in
                self.todoCollection = self.userDocument.collection("ToDoData")
                let document = self.todoCollection.document(self.todayData[indexPath.row].id)
                document.delete()
            }
            
            delete.backgroundColor = #colorLiteral(red: 0.9208939678, green: 0.9208939678, blue: 0.9208939678, alpha: 1)
            let actionConfig = UISwipeActionsConfiguration(actions: [delete])
            return actionConfig
        case 1:
            let delete = UIContextualAction (style: .destructive, title: "Delete") { action, view, closure  in
                self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
                let document = self.completedTodoCollection.document(self.todayCompletedData[indexPath.row].id)
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
extension TodayViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell") as! TableViewCell
            
            // Set up text, colors and icon for image
            cell.toDoLabel.attributedText = todayData[indexPath.row].toDoName.removeStrikeThrough()
            cell.toDoLabel.textColor = .black
            cell.listLabel.text = "\(todayData[indexPath.row].listName)" + "  "
            
            let listTheme = getListTheme(listID: todayData[indexPath.row].listID)
            cell.listLabel.textColor = convertColor(listTheme)
            
            if let dueDate = todayData[indexPath.row].dueDate {
                cell.dateLabel.text = Date().relativeDate(getDate(dueDate))
                
                if getDate(dueDate) > Date() {
                    cell.dateLabel.textColor = .systemBlue
                } else {
                    cell.dateLabel.textColor = .red
                }
            } 
            
            if let _ = todayData[indexPath.row].remindTime {
                cell.remindImageView.tintColor = .darkGray
            } else {
                cell.remindImageView.tintColor = .white
            }
            
            if  todayData[indexPath.row].repeatToDo != "none" {
                cell.repeatImageView.tintColor = .darkGray
            } else {
                cell.repeatImageView.tintColor = .white
            }
            
            cell.completeButtonImageView.image = UIImage(named: "circle")
            
            if todayData[indexPath.row].isPrioritized == true {
                cell.prioritizedButtonImageView.image = UIImage(named: "star-fill")!.tinted(with: convertColor(todayTheme))
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
            cell.toDoLabel.attributedText = todayCompletedData[indexPath.row].toDoName.strikeThrough()
            cell.toDoLabel.textColor = .lightGray
            cell.listLabel.text = todayCompletedData[indexPath.row].listName + "  "
            let listTheme = getListTheme(listID: todayCompletedData[indexPath.row].listID)
            cell.listLabel.textColor = convertColor(listTheme)
            
            if let dueDate = todayCompletedData[indexPath.row].dueDate {
                cell.dateLabel.text = Date().relativeDate(getDate(dueDate))
                
                if getDate(dueDate) > Date() {
                    cell.dateLabel.textColor = .systemBlue
                } else {
                    cell.dateLabel.textColor = .red
                }
            }
            if let _ = todayCompletedData[indexPath.row].remindTime {
                cell.remindImageView.tintColor = .lightGray
            } else {
                cell.remindImageView.tintColor = .white
            }
            
            if  todayCompletedData[indexPath.row].repeatToDo != "none" {
                cell.repeatImageView.tintColor = .lightGray
            } else {
                cell.repeatImageView.tintColor = .white
            }
            
            cell.completeButtonImageView.image = UIImage(named: "check")!.tinted(with: .lightGray)
            if todayCompletedData[indexPath.row].isPrioritized == true {
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
                
                let completedTodo = todayData[tapIndexPath.row]
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
                let document = todoCollection.document(todayData[tapIndexPath.row].id)
                document.delete()
                
            } else {
                let reversedTodo = todayCompletedData[tapIndexPath.row]
                todoCollection = userDocument.collection("ToDoData")
                let reversedTodoDocument = todoCollection.document(reversedTodo.id)
                reversedTodoDocument.setData(["toDoName": reversedTodo.toDoName, "listID" : reversedTodo.listID,"listName": reversedTodo.listName, "description" : reversedTodo.description, "createDate": "\(Date())", "dueDate": reversedTodo.dueDate, "remindTime" : reversedTodo.remindTime, "repeatToDo" :  reversedTodo.repeatToDo, "isComplete" : false, "isPrioritized" : reversedTodo.isPrioritized, "originalDueDate" : reversedTodo.originalDueDate, "originalRemind" : reversedTodo.originalRemind , "repeatTimes" : reversedTodo.repeatTimes])
                
                completedTodoCollection = userDocument.collection("CompletedToDoData")
                let document = completedTodoCollection.document(todayCompletedData[tapIndexPath.row].id)
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
                let todoDocument = todoCollection.document(todayData[tapIndexPath.row].id)
                if todayData[tapIndexPath.row].isPrioritized == true {
                    todoDocument.updateData(["isPrioritized": false])
                } else {
                    todoDocument.updateData(["isPrioritized": true])
                }
                
            case 1:
                completedTodoCollection = userDocument.collection("CompletedToDoData")
                let completedTodoDocument = completedTodoCollection.document(todayCompletedData[tapIndexPath.row].id)
                
                if todayCompletedData[tapIndexPath.row].isPrioritized == true {
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


