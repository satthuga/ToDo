//
//  SideMenuViewController.swift
//  TodoList
//
//  Created by Apple on 19/09/2021.
//

import UIKit
import Firebase
import FirebaseFirestore

class SideMenuViewController: UIViewController {
    let db = Firestore.firestore().collection("users")
    var userDocument: DocumentReference!
    var listCollection: CollectionReference!
    var listData = [List]()
    
    var currentVC : String = ""
    
    let headerView :UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let userView :UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let userImage: UIImageView = {
        let image = UIImageView()
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.layer.cornerRadius = 14
        image.clipsToBounds = true
        image.image = UIImage(named: "user")
        
        return image
    }()
    
    let userNameLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        return label
    }()
    
    
    // TableView
    let tableView: UITableView = {
        let table = UITableView(frame: CGRect.zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(SideMenuViewCell.self, forCellReuseIdentifier: "SideMenuViewCell")
        return table
    }()
    
    let newListButton: UIButton = {
        let button = UIButton()
        button.setTitle("New List +", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
  
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userNameLabel.text = UserDefaults.standard.string(forKey: "userName") ?? ""
        
        tableView.delegate = self
        tableView.dataSource = self
        let footerView = UIView()
        footerView.frame.size.height = 1
        tableView.tableFooterView = footerView
        self.tableView.backgroundColor =  .white
        tableView.showsVerticalScrollIndicator = false
        self.tableView.separatorStyle = .none
        
        // actions
        let onTapUserViewGesture = UITapGestureRecognizer(target: self, action: #selector(self.userViewTap(_:)))
        userView.addGestureRecognizer(onTapUserViewGesture)
        
        newListButton.addTarget(self, action: #selector(didTapNewListButton), for: .touchUpInside)
        
        fetchData()
        setupConstraints()
    }
    
    // add new list
    @objc func didTapNewListButton() {
        let alert = UIAlertController(title: nil, message: "New list", preferredStyle: .alert)
        alert.view.backgroundColor = .white
        alert.view.layer.cornerRadius = 18
        alert.addTextField()
        
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { action in
            guard let textfield = alert.textFields else { return }
            guard let text = textfield[0].text else { return }
            if text != "" {
                let newList = List()
                newList.listID = UUID().uuidString
                newList.listName = text
                self.listCollection = self.userDocument.collection("Lists")
                let newListoDocument = self.listCollection.document(newList.listID)
                newListoDocument.setData(["listID": newList.listID, "listName" : newList.listName,"listTheme": "defaultBlue", "createDate": "\(Date())"])
            } else {
                return
            }

        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
            
        }))
        self.present(alert, animated: true)
    }
    
    // log out, update profile
    @objc func userViewTap(_ gesture: UITapGestureRecognizer){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.view.backgroundColor = .white
        alert.view.layer.cornerRadius = 18
        //        alert.view.tintColor = convertColor("defaultBlue")
        
        alert.addAction(UIAlertAction(title: "Update Profile", style: .default, handler: { action in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Share App", style: .default, handler: { action in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Log out", style: .default, handler: { action in
            try? Auth.auth().signOut()
            if let scenseDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                scenseDelegate.setRootViewController()
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: { action in
            
        }))
        
        self.present(alert, animated: true)
    }
    
    
    // MARK: - fetchData
    private func fetchData() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        userDocument = db.document(user.uid)
        listCollection = userDocument.collection("Lists")
        listCollection.addSnapshotListener { snapShot, error in
            guard let snapShot = snapShot else {
                return
            }
            self.listData = snapShot.documents.map({
                return List.init(snapShot: $0)
            })
            self.tableView.reloadData()
            
            
        }
        
//        userDocument.getDocument { snapshot, error in
//            guard let data = snapshot?.data() as? [String : String],
//                  let firstName = data["firstName"], let lastName = data["lastName"] else {
//                print("Data was empty")
//                return
//            }
            
            
            
//        }
        
    }
// MARK: fetchData
    func setupConstraints() {
        view.backgroundColor = .white
        view.addSubview(headerView)
        view.addSubview(tableView)
        view.addSubview(newListButton)
        headerView.addSubview(userView)
        
        headerView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        headerView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.12).isActive = true
        headerView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        userView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 0).isActive = true
        userView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 15).isActive = true
        userView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        userView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15).isActive = true
        
        userView.addSubview(userImage)
        userView.addSubview(userNameLabel)
        
        userImage.bottomAnchor.constraint(equalTo: userView.bottomAnchor, constant: 0).isActive = true
        userImage.leadingAnchor.constraint(equalTo: userView.leadingAnchor).isActive = true
        userImage.heightAnchor.constraint(equalToConstant: 28).isActive = true
        userImage.widthAnchor.constraint(equalToConstant: 28).isActive = true
        
        userNameLabel.centerYAnchor.constraint(equalTo: userImage.centerYAnchor).isActive = true
        userNameLabel.leadingAnchor.constraint(equalTo: userImage.trailingAnchor, constant: 12).isActive = true
        userNameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        userNameLabel.trailingAnchor.constraint(equalTo: userView.trailingAnchor).isActive = true
        
        
        tableView.topAnchor.constraint(equalTo: userView.bottomAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        newListButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 15).isActive = true
        newListButton.leadingAnchor.constraint(equalTo: tableView.leadingAnchor, constant: 15).isActive = true
        newListButton.widthAnchor.constraint(equalToConstant: 100).isActive = true
        newListButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    
}

// MARK: UITableViewDelegate
extension SideMenuViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView (_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return listData.count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 1:
            let sectionView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 10))
            sectionView.backgroundColor = .white
            let label = UILabel()
            label.backgroundColor = .lightGray
            label.translatesAutoresizingMaskIntoConstraints = false
            sectionView.addSubview(label)
            
            label.trailingAnchor.constraint(equalTo: sectionView.trailingAnchor).isActive = true
            label.leadingAnchor.constraint(equalTo: sectionView.leadingAnchor).isActive = true
            label.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
            label.topAnchor.constraint(equalTo: sectionView.topAnchor, constant: 0).isActive = true
            
            
            
            return sectionView
        default:
            return UIView()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let listVC = ListAndTaskViewController()
        
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
//            self.navigationController?.pushViewController(todayVC, animated: true)
                let todayVC = TodayViewController()
                let todayController = UINavigationController(rootViewController: todayVC)
                self.slideMenuController()?.changeMainViewController(todayController, close: true)
            
            case 1:
                listVC.navigationItem.title = "Task"
                listVC.list = defaultTaskList
                listVC.listAndTaskTheme = UserDefaults.standard.string(forKey: "taskTheme") ?? ""
                let listController = UINavigationController(rootViewController: listVC)
                self.slideMenuController()?.changeMainViewController(listController, close: true)

            case 2:
                let calendarVC = CalendarViewController()
                let calendarController = UINavigationController(rootViewController: calendarVC)
                self.slideMenuController()?.changeMainViewController(calendarController, close: true)

            default:
                print("default")
            }
            
        } else {
            listVC.navigationItem.title = listData[indexPath.row].listName
            listVC.list = listData[indexPath.row]
            listVC.listAndTaskTheme = listData[indexPath.row].listTheme
            let listController = UINavigationController(rootViewController: listVC)
            self.slideMenuController()?.changeMainViewController(listController, close: true)
            
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if indexPath.section == 1 {
            let delete = UIContextualAction (style: .normal, title: "Delete") { action, view, closure  in
                self.listCollection = self.userDocument.collection("Lists")
                let document = self.listCollection.document(self.listData[indexPath.row].listID)
                document.delete()
                self.tableView.reloadData()
            }
            delete.backgroundColor = .black
            let actionConfig = UISwipeActionsConfiguration(actions: [delete])
            return actionConfig
        } else {
            return nil
        }
    }
    
}

// MARK: -UITableViewDataSource
extension SideMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuViewCell") as! SideMenuViewCell
            switch indexPath.row {
            case 0:
                cell.listNameLabel.text = "Today"
                cell.iconImageView.image = UIImage(systemName: "sun.max")
                cell.iconImageView.tintColor = convertColor(UserDefaults.standard.string(forKey: "todayTheme") ?? "")
                
            case 1:
                cell.listNameLabel.text = "Task"
                cell.iconImageView.image = UIImage(systemName: "list.bullet.rectangle")
                cell.iconImageView.tintColor = convertColor(UserDefaults.standard.string(forKey: "taskTheme") ?? "")
                return cell
            case 2:
                cell.listNameLabel.text = "Calendar"
                cell.iconImageView.image = UIImage(systemName: "calendar")
                cell.iconImageView.tintColor = convertColor("defaultBlue")
                return cell
            default:
                print("default")
            }
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuViewCell") as! SideMenuViewCell
            cell.listNameLabel.text = "\(listData[indexPath.row].listName )"
            cell.iconImageView.tintColor = convertColor((listData[indexPath.row].listTheme))
            
            return cell
        default:
            return UITableViewCell()
        }
        
    }
    
    
}
