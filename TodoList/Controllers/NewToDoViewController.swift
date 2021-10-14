//
//  NewToDoViewController.swift
//  TodoList
//
//  Created by Apple on 13/09/2021.
//

import UIKit
import Firebase
import FirebaseFirestore

class NewToDoViewController: UIViewController {
    let db = Firestore.firestore().collection("users")
    var userDocument: DocumentReference!
    var listCollection: CollectionReference!
    var todoCollection: CollectionReference!
    
    var newToDoTheme = "defaultBlue"
    var newToDoList : List = defaultTaskList
    var listData : [List]?
    var newToDoDueDate : String? = nil
    var newToDoRemind : String? = nil
    var newToDoRepeat  = "none"
    var isPrioritized = false
    
    var canResetList = true
    var canResetDate = true
    
    // Keyboard contain view
    let keyboardView :UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = .white
        view.layer.shadowRadius = 2
        view.layer.shadowOpacity = 0.05
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Transparent Background
    let blurView :UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Initiate textfield
    let textField :UITextField = {
        let text = UITextField()
        text.placeholder = "Enter new task..."
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    let indicatorLineView :UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.8564838448, green: 0.8564838448, blue: 0.8564838448, alpha: 1)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let buttonsStackView : UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 0
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // Initiate List button
    let listView :UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let listIcon: UIImageView = {
        let image = UIImageView()
        
        image.translatesAutoresizingMaskIntoConstraints = false
        
        image.image = UIImage(systemName: "list.dash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .medium))
        image.tintColor = .lightGray
        
        return image
    }()
    
    let listLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "List"
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        label.textColor = .gray
        return label
    }()
    
    // Initiate Due Date Button
    let dueDateView :UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        //        view.isUserInteractionEnabled = true
        return view
    }()
    
    let dueDateCoverLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var dueDatePicker = UIDatePicker()
    
    let dueDateIcon: UIImageView = {
        let image = UIImageView()
        
        image.translatesAutoresizingMaskIntoConstraints = false
        
        image.image = UIImage(systemName: "calendar.badge.plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .medium))
        image.tintColor = .lightGray
        image.isUserInteractionEnabled = true
        return image
    }()
    
    let dueDateLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Due"
        
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        label.textColor = .gray
        return label
    }()
    
    // Initiate Remind Button
    let remindView :UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let remindCoverLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var remindDatePicker = UIDatePicker()
    
    let remindIcon: UIImageView = {
        let image = UIImageView()
        
        image.translatesAutoresizingMaskIntoConstraints = false
        
        image.image = UIImage(systemName: "bell.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .medium))
        image.tintColor = .lightGray
        image.isUserInteractionEnabled = true
        return image
    }()
    
    let remindLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Remind"
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        label.textColor = .gray
        return label
    }()
    
    // Initiate Repeat Button
    let repeatView :UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let repeatIcon: UIImageView = {
        let image = UIImageView()
        
        image.translatesAutoresizingMaskIntoConstraints = false
        
        image.image = UIImage(systemName: "repeat", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .medium))
        image.tintColor = .lightGray
        return image
    }()
    
    let repeatLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Repeat"
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        label.textColor = .gray
        return label
    }()
    
    let prioritizedButton: UIImageView = {
        let image = UIImageView()
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isUserInteractionEnabled = true
        image.image = UIImage(named: "star")!.tinted(with: .lightGray)
        return image
    }()
    
    let enterButton: UIImageView = {
        let image = UIImageView()
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isUserInteractionEnabled = true
        image.image = UIImage(systemName: "arrow.up.square.fill")
        return image
    }()
    
    // MARK: -viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prioritizedButton.tintColor = convertColor(newToDoTheme)
        enterButton.tintColor = convertColor(newToDoTheme)
        
        // List action
        let onTapListGesture = UITapGestureRecognizer(target: self, action: #selector(self.listTap(_:)))
        listView.addGestureRecognizer(onTapListGesture)
        
        // DueDate Action
        dueDatePicker.preferredDatePickerStyle = .compact
        dueDatePicker.addTarget(self, action: #selector(dueDatePickerValueChanged(_:)), for: .valueChanged)
        
        let onTapDueDateIconGesture = UITapGestureRecognizer(target: self, action: #selector(self.dueDateIconTap(_:)))
        dueDateIcon.addGestureRecognizer(onTapDueDateIconGesture)
        
        // Remind Action
        remindDatePicker.preferredDatePickerStyle = .compact
        remindDatePicker.addTarget(self, action: #selector(remindPickerValueChanged(_:)), for: .valueChanged)
        
        let onTapRemindIconGesture = UITapGestureRecognizer(target: self, action: #selector(self.remindIconTap(_:)))
        remindIcon.addGestureRecognizer(onTapRemindIconGesture)
        
        // Repeat Action
        let onTapRepeatGesture = UITapGestureRecognizer(target: self, action: #selector(self.repeatTap(_:)))
        repeatView.addGestureRecognizer(onTapRepeatGesture)
        
        // Prioritize Action
        let onTapPrioritizedGesture = UITapGestureRecognizer(target: self, action: #selector(self.prioritizedTap(_:)))
        prioritizedButton.addGestureRecognizer(onTapPrioritizedGesture)
        
        // Enter Action
        let onTapEnterGesture = UITapGestureRecognizer(target: self, action: #selector(self.enterTap(_:)))
        enterButton.addGestureRecognizer(onTapEnterGesture)
        
        // Dismiss View Action
        let dismissTap = UITapGestureRecognizer(target: self, action: #selector(self.dismissTap(_:)))
        self.blurView.addGestureRecognizer(dismissTap)
        
        setupConstraint()
        pushViewAboveKeyboard()
         
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.textField.becomeFirstResponder()
        }
    }
    // MARK: -fetchData
    private func fetchData() {
        guard let user = Auth.auth().currentUser else {
            return
        }
        userDocument = db.document(user.uid)
        listCollection = userDocument.collection("Lists")
        listCollection.addSnapshotListener { snapShot, error in
            self.listData = snapShot?.documents.map({
                return List.init(snapShot: $0)
            })
        }
    }
    
    // MARK: constraint
    func setupConstraint() {
        self.view.addSubview(blurView)
        self.view.addSubview(keyboardView)
        
        keyboardView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 20).isActive = true
        keyboardView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        keyboardView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        keyboardView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.18).isActive = true
        
        blurView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        blurView.bottomAnchor.constraint(equalTo: keyboardView.topAnchor).isActive = true
        
        blurView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        
        blurView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        // Keyboard View
        
        keyboardView.addSubview(textField)
        keyboardView.addSubview(prioritizedButton)
        keyboardView.addSubview(enterButton)
        keyboardView.addSubview(buttonsStackView)
        keyboardView.addSubview(indicatorLineView)
        
        indicatorLineView.topAnchor.constraint(equalTo: keyboardView.topAnchor, constant: 5).isActive = true
        indicatorLineView.centerXAnchor.constraint(equalTo: keyboardView.centerXAnchor).isActive = true
        indicatorLineView.heightAnchor.constraint(equalToConstant: 5).isActive = true
        indicatorLineView.widthAnchor.constraint(equalToConstant: 35).isActive = true
        indicatorLineView.layer.cornerRadius = 2
        
        enterButton.topAnchor.constraint(equalTo: indicatorLineView.bottomAnchor, constant: 10).isActive = true
        enterButton.trailingAnchor.constraint(equalTo: keyboardView.trailingAnchor, constant: -20).isActive = true
        enterButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        enterButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        prioritizedButton.centerYAnchor.constraint(equalTo: enterButton.centerYAnchor).isActive = true
        prioritizedButton.trailingAnchor.constraint(equalTo: enterButton.leadingAnchor, constant: -25).isActive = true
        prioritizedButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        prioritizedButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        
        textField.centerYAnchor.constraint(equalTo: prioritizedButton.centerYAnchor, constant: 0).isActive = true
        textField.leadingAnchor.constraint(equalTo: keyboardView.leadingAnchor, constant: 20).isActive = true
        textField.trailingAnchor.constraint(equalTo: prioritizedButton.leadingAnchor,constant: -10 ).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        buttonsStackView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 15).isActive = true
        buttonsStackView.trailingAnchor.constraint(equalTo: keyboardView.trailingAnchor, constant: 0).isActive = true
        buttonsStackView.leadingAnchor.constraint(equalTo: keyboardView.leadingAnchor, constant: 10).isActive = true
        buttonsStackView.bottomAnchor.constraint(equalTo: keyboardView.bottomAnchor, constant: -5).isActive = true
        
        buttonsStackView.addArrangedSubview(listView)
        buttonsStackView.addArrangedSubview(dueDateView)
        buttonsStackView.addArrangedSubview(remindView)
        buttonsStackView.addArrangedSubview(repeatView)
        
        listView.addSubview(listIcon)
        listView.addSubview(listLabel)
        
        listIcon.topAnchor.constraint(equalTo: listView.topAnchor).isActive = true
        listIcon.leadingAnchor.constraint(equalTo: listView.leadingAnchor).isActive = true
        listIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        listIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        listLabel.centerYAnchor.constraint(equalTo: listIcon.centerYAnchor).isActive = true
        listLabel.leadingAnchor.constraint(equalTo: listIcon.trailingAnchor, constant: 5).isActive = true
        listLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        listLabel.trailingAnchor.constraint(equalTo: listView.trailingAnchor).isActive = true
        
        dueDateView.addSubview(dueDatePicker)
        dueDateView.addSubview(dueDateCoverLabel)
        dueDateView.addSubview(dueDateIcon)
        dueDateView.addSubview(dueDateLabel)
        
        dueDateCoverLabel.topAnchor.constraint(equalTo: self.dueDateView.topAnchor).isActive = true
        dueDateCoverLabel.bottomAnchor.constraint(equalTo: dueDateView.bottomAnchor).isActive = true
        
        dueDateCoverLabel.leadingAnchor.constraint(equalTo: self.dueDateView.leadingAnchor).isActive = true
        
        dueDateCoverLabel.trailingAnchor.constraint(equalTo: self.dueDateView.trailingAnchor).isActive = true
        
        dueDateIcon.topAnchor.constraint(equalTo: dueDateView.topAnchor).isActive = true
        dueDateIcon.leadingAnchor.constraint(equalTo: dueDateView.leadingAnchor).isActive = true
        dueDateIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        dueDateIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        dueDateLabel.centerYAnchor.constraint(equalTo: dueDateIcon.centerYAnchor).isActive = true
        dueDateLabel.leadingAnchor.constraint(equalTo: dueDateIcon.trailingAnchor, constant: 5).isActive = true
        dueDateLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        dueDateLabel.trailingAnchor.constraint(equalTo: dueDateView.trailingAnchor).isActive = true
        
        remindView.addSubview(remindDatePicker)
        remindView.addSubview(remindCoverLabel)
        remindView.addSubview(remindIcon)
        remindView.addSubview(remindLabel)
        
        
        remindCoverLabel.topAnchor.constraint(equalTo: self.remindView.topAnchor).isActive = true
        remindCoverLabel.bottomAnchor.constraint(equalTo: remindView.bottomAnchor).isActive = true
        
        remindCoverLabel.leadingAnchor.constraint(equalTo: self.remindView.leadingAnchor).isActive = true
        
        remindCoverLabel.trailingAnchor.constraint(equalTo: self.remindView.trailingAnchor).isActive = true
        
        remindIcon.topAnchor.constraint(equalTo: remindView.topAnchor).isActive = true
        remindIcon.leadingAnchor.constraint(equalTo: remindView.leadingAnchor).isActive = true
        remindIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        remindIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        remindLabel.centerYAnchor.constraint(equalTo: remindIcon.centerYAnchor).isActive = true
        remindLabel.leadingAnchor.constraint(equalTo: remindIcon.trailingAnchor, constant: 5).isActive = true
        remindLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        remindLabel.trailingAnchor.constraint(equalTo: remindView.trailingAnchor).isActive = true
        
        repeatView.addSubview(repeatIcon)
        repeatView.addSubview(repeatLabel)
        
        repeatIcon.topAnchor.constraint(equalTo: repeatView.topAnchor).isActive = true
        repeatIcon.leadingAnchor.constraint(equalTo: repeatView.leadingAnchor).isActive = true
        repeatIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        repeatIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        
        repeatLabel.centerYAnchor.constraint(equalTo: repeatIcon.centerYAnchor).isActive = true
        repeatLabel.leadingAnchor.constraint(equalTo: repeatIcon.trailingAnchor, constant: 5).isActive = true
        repeatLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        repeatLabel.trailingAnchor.constraint(equalTo: repeatView.trailingAnchor).isActive = true
    }
    
    @objc func dismissTap(_ sender:
                            UITapGestureRecognizer? = nil) {
        self.textField.resignFirstResponder()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func listTap(_ gesture: UITapGestureRecognizer) {
        let listAlert = UIAlertController(title: nil, message: "Choose List", preferredStyle: .actionSheet)
        listAlert.view.backgroundColor = .white
        listAlert.view.layer.cornerRadius = 18
        listAlert.view.tintColor = self.convertColor(self.newToDoTheme)
        
        guard let listData = listData else {
            return
        }
        switch listData.count {
        case 0:
            print(0)
        case 1:
            listAlert.addAction(UIAlertAction(title: listData[0].listName, style: .default, handler: { action in
                
                self.newToDoList = listData[0]
                self.listIcon.tintColor = self.convertColor(listData[0].listTheme)
                self.listLabel.text = listData[0].listName
                self.listLabel.textColor = self.convertColor(listData[0].listTheme)
            }))
        default:
            for i in listData[0...listData.count-1] {
                listAlert.addAction(UIAlertAction(title: i.listName, style: .default, handler: { action in
                    
                    self.newToDoList = i
                    self.listIcon.tintColor = self.convertColor(i.listTheme)
                    self.listLabel.text = i.listName
                    self.listLabel.textColor = self.convertColor(i.listTheme)
                }))
            }
        }
        
        listAlert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: { action in
            self.resetList()
        }))
        self.present(listAlert, animated: true)
    }
    
    @objc func dueDateIconTap(_ gesture: UITapGestureRecognizer) {
        self.resetDueDate()
    }
    
    @objc func dueDatePickerValueChanged(_ sender: UIDatePicker) {
        self.newToDoDueDate = "\(sender.date)"
        self.dueDateLabel.text = Date().relativeDate(sender.date)
        
        if sender.date > Date() {
            self.dueDateLabel.textColor = self.convertColor(newToDoTheme)
            self.dueDateIcon.tintColor = self.convertColor(newToDoTheme)
        } else {
            self.dueDateLabel.textColor = .red
            self.dueDateIcon.tintColor = .red
        }
    }
    
    @objc func remindPickerValueChanged(_ sender: UIDatePicker) {
        self.newToDoRemind = "\(sender.date)"
        self.remindLabel.text = Date().relativeDate(sender.date)
        
        if sender.date > Date() {
            self.remindIcon.tintColor = self.convertColor(newToDoTheme)
            self.remindLabel.textColor = self.convertColor(newToDoTheme)
        } else {
            self.remindIcon.tintColor = .red
            self.remindLabel.textColor = .red
        }
    }
    
    @objc func remindIconTap(_ gesture: UITapGestureRecognizer) {
        self.resetRemind()
    }
    
    @objc func repeatTap(_ gesture: UITapGestureRecognizer) {
        let repeatAlert = UIAlertController(title: nil, message: "Repeat", preferredStyle: .alert)
        repeatAlert.view.backgroundColor = .white
        repeatAlert.view.layer.cornerRadius = 18
        repeatAlert.view.tintColor = self.convertColor(self.newToDoTheme)
        repeatAlert.addAction(UIAlertAction(title: "Daily", style: .default, handler: { action in
            self.newToDoRepeat = "daily"
            self.repeatIcon.tintColor = self.convertColor(self.newToDoTheme)
            self.repeatLabel.text = "Daily"
            self.repeatLabel.textColor = self.convertColor(self.newToDoTheme)
        }))
        
        repeatAlert.addAction(UIAlertAction(title: "Weekly", style: .default, handler: { action in
            self.newToDoRepeat = "weekly"
            self.repeatIcon.tintColor = self.convertColor(self.newToDoTheme)
            self.repeatLabel.text = "Weekly"
            self.repeatLabel.textColor = self.convertColor(self.newToDoTheme)
        }))
        
        repeatAlert.addAction(UIAlertAction(title: "Monthly", style: .default, handler: { action in
            self.newToDoRepeat = "monthly"
            self.repeatIcon.tintColor = self.convertColor(self.newToDoTheme)
            self.repeatLabel.text = "Monthly"
            self.repeatLabel.textColor = self.convertColor(self.newToDoTheme)
        }))
        
        repeatAlert.addAction(UIAlertAction(title: "Yearly", style: .default, handler: { action in
            self.newToDoRepeat = "yearly"
            self.repeatIcon.tintColor = self.convertColor(self.newToDoTheme)
            self.repeatLabel.text = "Yearly"
            self.repeatLabel.textColor = self.convertColor(self.newToDoTheme)
        }))
        
        repeatAlert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: { action in
            self.resetRepeat()
        }))
        self.present(repeatAlert, animated: true)
        
    }
    
    @objc func prioritizedTap(_ gesture: UITapGestureRecognizer) {
        if self.isPrioritized == false {
            self.prioritizedButton.tintColor = self.convertColor(newToDoTheme)
            self.prioritizedButton.image = UIImage(named: "star-fill")!.tinted(with: self.convertColor(newToDoTheme))
            self.isPrioritized = true
        } else {
            self.resetPrioritized()
        }
    }
    
    @objc func enterTap(_ gesture: UITapGestureRecognizer) {
        
        
        guard let todoName = textField.text else {
            return
        }
        
        if todoName != "" {
            let newTodo = Todo()
            newTodo.id = UUID().uuidString
            
            newTodo.toDoName = todoName
            
            newTodo.listName = newToDoList.listName
            newTodo.listID = newToDoList.listID
            
            newTodo.dueDate = newToDoDueDate
            newTodo.remindTime = newToDoRemind
            newTodo.repeatToDo = newToDoRepeat
            newTodo.isComplete = false
            newTodo.isPrioritized = self.isPrioritized
            
            if newTodo.repeatToDo != "none" {
                if let _ = newToDoDueDate {
                    newTodo.originalDueDate = newToDoDueDate
                } else {
                    newTodo.originalDueDate = "\(Date())"
                    newTodo.dueDate = "\(Date())"
                }
            } else {
                if let _ = newToDoDueDate {
                    newTodo.originalDueDate = newToDoDueDate
                }
            }
            
            newTodo.originalRemind = newToDoRemind
            newTodo.repeatTimes = 0
            
            guard let user = Auth.auth().currentUser else {
                return
            }
            userDocument = db.document(user.uid)
            todoCollection = userDocument.collection("ToDoData")
            
            let newToDoDocument = todoCollection.document(newTodo.id)
            newToDoDocument.setData(["toDoName": newTodo.toDoName, "listID" : newTodo.listID,"listName": newTodo.listName, "description" : "", "createDate": "\(Date())", "dueDate": newTodo.dueDate, "remindTime" : newTodo.remindTime, "repeatToDo" :  newTodo.repeatToDo, "isComplete" :  newTodo.isComplete, "isPrioritized" : newTodo.isPrioritized, "originalDueDate" : newTodo.originalDueDate, "originalRemind" : newTodo.originalRemind, "repeatTimes" : newTodo.repeatTimes])
                 
            // reset new todo
            
            if self.canResetList == true {
                self.resetList()
            }
            
            if self.canResetDate == true {
                self.resetDueDate()
            }
            
            self.resetRemind()
            self.resetRepeat()
            self.resetPrioritized()
            self.textField.text = nil
            
        } else { return }
    }
    
    func resetList() {
        self.newToDoList = defaultTaskList
        self.listIcon.tintColor = .lightGray
        self.listLabel.text = "List"
        self.listLabel.textColor = .lightGray
    }
    
    func resetDueDate() {
        self.newToDoDueDate = nil
        self.dueDateIcon.tintColor = .lightGray
        self.dueDateLabel.text = "Due"
        self.dueDateLabel.textColor = .lightGray
    }
    
    func resetRemind() {
        self.newToDoRemind = nil
        self.remindIcon.tintColor = .lightGray
        self.remindLabel.text = "Remind"
        self.remindLabel.textColor = .lightGray
    }
    
    func resetRepeat() {
        self.newToDoRepeat = "none"
        self.repeatIcon.tintColor = .lightGray
        self.repeatLabel.text = "Repeat"
        self.repeatLabel.textColor = .lightGray
    }
    
    func resetPrioritized() {
        self.prioritizedButton.image = UIImage(named: "star")!.tinted(with: .lightGray)
    
    }
    
    func pushViewAboveKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(NewToDoViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NewToDoViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        // move the root view up by the distance of keyboard height
        self.view.frame.origin.y = 0 - keyboardSize.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
}
