//
//  EditViewController.swift
//  TodoList
//
//  Created by Apple on 17/09/2021.
//

import UIKit
import Firebase
import FirebaseFirestore
import AVFoundation

class EditViewController: UIViewController {
    let db = Firestore.firestore().collection("users")
    var userDocument: DocumentReference!
    var listCollection: CollectionReference!
    var todoCollection: CollectionReference!
    var completedTodoCollection: CollectionReference!
    
    var todo :Todo = Todo()
    
    var listData = [List]()
    var editTheme = "defaultBlue"
    var pushedFromCompletedSection = false

    
    // Initiate titleView
    let titleView :UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
     }()
    
    let backView :UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
     }()
    
    let backIcon: UIImageView = {
        let image = UIImageView()
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.tintColor = .darkGray
        image.image = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .light))
        
        return image
    }()
    
    let backLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Back"
        label.font = UIFont.systemFont(ofSize: 20, weight: .light)
        return label
    }()
    
    let textField :UITextField = {
        let text = UITextField()
        text.font = UIFont.systemFont(ofSize: 26, weight: .regular)
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
     }()
    
    let completeButtonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let configuration = UIImage.SymbolConfiguration(weight: .light)
        imageView.image = UIImage(named: "circle")
        imageView.isUserInteractionEnabled = true
        
       return imageView
    }()
    
    let productivityLabel : UILabel = {
        let label = UILabel()
        label.text = "PRODUCTIVITY"
        label.font = UIFont.systemFont(ofSize: 13,weight: .ultraLight)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let buttonsStackView : UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .fillEqually
        stack.spacing = 1.5
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
        image.tintColor = .darkGray
        image.image = UIImage(systemName: "list.dash", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .light))
        
        return image
    }()
    
    let listLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "List"
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    // Initiate dueDate button
    let dueDateView :UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
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
        image.tintColor = .darkGray
        image.image = UIImage(systemName: "calendar.badge.plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .light))
        image.isUserInteractionEnabled = true
        return image
    }()
    
    let dueDateLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Due"
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    // Initiate remind button
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
        image.tintColor = .darkGray
        image.image = UIImage(systemName: "bell", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .light))
        image.isUserInteractionEnabled = true
        return image
    }()
    
    let remindLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Remind"
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    // Initiate repeat button
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
        image.tintColor = .darkGray
        image.image = UIImage(systemName: "repeat", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .light))
        return image
    }()
    
    let repeatLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Repeat"
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        return label
    }()

    
    let prioritizedButton: UIImageView = {
        let image = UIImageView()
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.isUserInteractionEnabled = true
        image.image = UIImage(systemName: "star")
        return image
        }()
    
    let descriptionLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "DESCRIPTION"
        label.font = UIFont.systemFont(ofSize: 13,weight: .ultraLight)
        return label
    }()
    
    let descriptionView : UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let descriptionCoverLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Enter description..."
        label.textColor = .lightGray
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        return label
    }()

    
    let pianoSound = URL(fileURLWithPath: Bundle.main.path(forResource: "prist", ofType: "mp3")!)
      var audioPlayer = AVAudioPlayer()

    // MARK: - ViewdidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        backIcon.tintColor = convertColor(editTheme)
        backLabel.textColor = convertColor(editTheme)
        
        setupConstraint()

        let onTapBackGesture = UITapGestureRecognizer(target: self, action: #selector(self.backTap(_:)))
        backView.addGestureRecognizer(onTapBackGesture)
        
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
        
        // Complete Action
        let onTapCompleteGesture = UITapGestureRecognizer(target: self, action: #selector(self.completeTap(_:)))
        completeButtonImageView.addGestureRecognizer(onTapCompleteGesture)
        
        // de Action
        let onTapDescriptionGesture = UITapGestureRecognizer(target: self, action: #selector(self.descriptionTap(_:)))
        descriptionView.addGestureRecognizer(onTapDescriptionGesture)
        
        textField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
        
        setDataValueToLabel()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
        fetchData()
       
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - fetchData
 func fetchData() {
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
        }
        
        userDocument = db.document(user.uid)
        todoCollection = userDocument.collection("ToDoData")
        completedTodoCollection = userDocument.collection("CompletedToDoData")
    }
    
    
    //MARK: - Constraints
   
    func setupConstraint() {
        self.view.backgroundColor =  #colorLiteral(red: 0.9517593214, green: 0.9585454946, blue: 0.9789040142, alpha: 1)
        self.view.addSubview(titleView)
        self.view.addSubview(buttonsStackView)
        self.view.addSubview(productivityLabel)
        self.view.addSubview(descriptionLabel)
        self.view.addSubview(descriptionView)
        
        titleView.addSubview(completeButtonImageView)
        titleView.addSubview(textField)
        titleView.addSubview(prioritizedButton)
        titleView.addSubview(backView)
        
        titleView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        titleView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.2).isActive = true
        titleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        titleView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        
        backView.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 30).isActive = true
        backView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 8).isActive = true
        backView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        backView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        backView.addSubview(backIcon)
        backView.addSubview(backLabel)
        
        backIcon.centerYAnchor.constraint(equalTo: backView.centerYAnchor).isActive = true
        backIcon.leadingAnchor.constraint(equalTo: backView.leadingAnchor).isActive = true
        backIcon.heightAnchor.constraint(equalToConstant: 18).isActive = true
        backIcon.widthAnchor.constraint(equalToConstant: 18).isActive = true
        
        backLabel.centerYAnchor.constraint(equalTo: backView.centerYAnchor).isActive = true
        backLabel.leadingAnchor.constraint(equalTo: backIcon.trailingAnchor, constant: 6).isActive = true
        backLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        backLabel.trailingAnchor.constraint(equalTo: backView.trailingAnchor).isActive = true
        
        completeButtonImageView.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 10).isActive = true
        completeButtonImageView.leadingAnchor.constraint(equalTo: titleView.leadingAnchor, constant: 12).isActive = true
        completeButtonImageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        completeButtonImageView.widthAnchor.constraint(equalToConstant: 22).isActive = true
        
        prioritizedButton.centerYAnchor.constraint(equalTo: completeButtonImageView.centerYAnchor).isActive = true
        prioritizedButton.trailingAnchor.constraint(equalTo: titleView.trailingAnchor, constant: -30).isActive = true
        prioritizedButton.heightAnchor.constraint(equalToConstant: 24).isActive = true
        prioritizedButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        
        textField.centerYAnchor.constraint(equalTo: prioritizedButton.centerYAnchor, constant: 0).isActive = true
        textField.trailingAnchor.constraint(equalTo: prioritizedButton.leadingAnchor, constant: -15).isActive = true
        textField.leadingAnchor.constraint(equalTo: completeButtonImageView.trailingAnchor,constant: 10 ).isActive = true
        textField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        productivityLabel.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 13).isActive = true
        productivityLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 15).isActive = true
        productivityLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 18).isActive = true
        productivityLabel.heightAnchor.constraint(equalToConstant: 13).isActive = true
        
        buttonsStackView.topAnchor.constraint(equalTo: productivityLabel.bottomAnchor, constant: 13).isActive = true
        buttonsStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        buttonsStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        buttonsStackView.heightAnchor.constraint(equalTo: self.view.heightAnchor, multiplier: 0.3).isActive = true
               
        buttonsStackView.addArrangedSubview(listView)
        buttonsStackView.addArrangedSubview(dueDateView)
        buttonsStackView.addArrangedSubview(remindView)
        buttonsStackView.addArrangedSubview(repeatView)
        
        listView.addSubview(listIcon)
        listView.addSubview(listLabel)
        
        listIcon.centerYAnchor.constraint(equalTo: listView.centerYAnchor).isActive = true
        listIcon.leadingAnchor.constraint(equalTo: listView.leadingAnchor, constant: 18).isActive = true
        listIcon.heightAnchor.constraint(equalToConstant: 18).isActive = true
        listIcon.widthAnchor.constraint(equalToConstant: 18).isActive = true
        
        listLabel.centerYAnchor.constraint(equalTo: listIcon.centerYAnchor).isActive = true
        listLabel.leadingAnchor.constraint(equalTo: listIcon.trailingAnchor, constant: 9).isActive = true
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
        
        dueDateIcon.centerYAnchor.constraint(equalTo: dueDateView.centerYAnchor).isActive = true
        dueDateIcon.leadingAnchor.constraint(equalTo: dueDateView.leadingAnchor, constant: 18).isActive = true
        dueDateIcon.heightAnchor.constraint(equalToConstant: 18).isActive = true
        dueDateIcon.widthAnchor.constraint(equalToConstant: 18).isActive = true

        dueDateLabel.centerYAnchor.constraint(equalTo: dueDateIcon.centerYAnchor).isActive = true
        dueDateLabel.leadingAnchor.constraint(equalTo: dueDateIcon.trailingAnchor, constant: 9).isActive = true
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
        
        remindIcon.centerYAnchor.constraint(equalTo: remindView.centerYAnchor).isActive = true
        remindIcon.leadingAnchor.constraint(equalTo: remindView.leadingAnchor, constant: 18).isActive = true
        remindIcon.heightAnchor.constraint(equalToConstant: 18).isActive = true
        remindIcon.widthAnchor.constraint(equalToConstant: 18).isActive = true
        
        remindLabel.centerYAnchor.constraint(equalTo: remindIcon.centerYAnchor).isActive = true
        remindLabel.leadingAnchor.constraint(equalTo: remindIcon.trailingAnchor, constant: 9).isActive = true
        remindLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        remindLabel.trailingAnchor.constraint(equalTo: remindView.trailingAnchor).isActive = true
        
        repeatView.addSubview(repeatIcon)
        repeatView.addSubview(repeatLabel)
        
        repeatIcon.centerYAnchor.constraint(equalTo: repeatView.centerYAnchor).isActive = true
        repeatIcon.leadingAnchor.constraint(equalTo: repeatView.leadingAnchor, constant: 18).isActive = true
        repeatIcon.heightAnchor.constraint(equalToConstant: 18).isActive = true
        repeatIcon.widthAnchor.constraint(equalToConstant: 18).isActive = true
        
        repeatLabel.centerYAnchor.constraint(equalTo: repeatIcon.centerYAnchor).isActive = true
        repeatLabel.leadingAnchor.constraint(equalTo: repeatIcon.trailingAnchor, constant: 9).isActive = true
        repeatLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        repeatLabel.trailingAnchor.constraint(equalTo: repeatView.trailingAnchor).isActive = true
        
        descriptionLabel.topAnchor.constraint(equalTo: buttonsStackView.bottomAnchor, constant: 13).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: 13).isActive = true
        
        descriptionView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 13).isActive = true
        descriptionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        descriptionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        descriptionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        descriptionView.addSubview(descriptionCoverLabel)
        
        descriptionCoverLabel.topAnchor.constraint(equalTo: descriptionView.topAnchor, constant: 10).isActive = true
        descriptionCoverLabel.leadingAnchor.constraint(equalTo: descriptionView.leadingAnchor, constant: 15).isActive = true
        descriptionCoverLabel.trailingAnchor.constraint(equalTo: descriptionView.trailingAnchor).isActive = true
        
    }
    
    // setDataValueToLabel
    func setDataValueToLabel() {
        
        self.textField.text = todo.toDoName
        
        if todo.description != "" {
            self.descriptionCoverLabel.text = todo.description
            self.descriptionCoverLabel.textColor = .black
        } else {
            self.descriptionCoverLabel.text = "Enter description..."
            self.descriptionCoverLabel.textColor = .lightGray
        }
        
        self.listIcon.tintColor = self.convertColor(getListTheme(listID: todo.listID))
        self.listLabel.text = todo.listName
        self.listLabel.textColor = self.convertColor(getListTheme(listID: todo.listID))
        
        if let toDoDueDate = todo.dueDate {
            self.dueDateLabel.text = Date().relativeDate(getDate(toDoDueDate))
            if getDate(toDoDueDate) > Date() {
                self.dueDateLabel.textColor = self.convertColor(editTheme)
                self.dueDateIcon.tintColor = self.convertColor(editTheme)
            } else {
                self.dueDateLabel.textColor = .red
                self.dueDateIcon.tintColor = .red
            }
        }
        
        if let toDoRemind = todo.remindTime {
            self.remindLabel.text = Date().relativeDate(getDate(toDoRemind))
            
            print(todo.remindTime)
            print(Date().relativeDate(getDate(toDoRemind))
            )
            if getDate(toDoRemind) > Date() {
                self.remindLabel.textColor = self.convertColor(editTheme)
                self.remindIcon.tintColor = self.convertColor(editTheme)
            } else {
                self.remindLabel.textColor = .red
                self.remindIcon.tintColor = .red
            }
        }
        
        if todo.repeatToDo != "none" {
            self.repeatIcon.tintColor = self.convertColor(self.editTheme)
            self.repeatLabel.textColor = self.convertColor(self.editTheme)
        }
        
        switch todo.repeatToDo {
        case "daily":
            self.repeatLabel.text = "Daily"
        case "weekly":
            self.repeatLabel.text = "Weekly"
        case "monthly":
            self.repeatLabel.text = "Monthly"
        case "yearly":
            self.repeatLabel.text = "Yearly"
        default:
            self.repeatLabel.text = "None"
        }
        
        if todo.isPrioritized == true {
            self.prioritizedButton.image = UIImage(named: "star-fill")!.tinted(with: self.convertColor(self.editTheme))
        } else {
            self.prioritizedButton.image = UIImage(named: "star")!.tinted(with: .gray)
        }
        
        if todo.isComplete == true {
            self.completeButtonImageView.image = UIImage(named: "check")!.tinted(with: .gray)
        } else {
            self.completeButtonImageView.image = UIImage(named: "circle")
        }
        
    }
    
    // get list name from listID
    func getListTheme(listID : String) -> String {
       
        var listTheme = defaultTaskList.listTheme
        
        for i in self.listData {
            if listID == i.listID {
                listTheme = i.listTheme
                break
            }
            print(i.listTheme)
        }
        print(listTheme)
        return listTheme
        
    }
    
    // update todo name
    @objc func textFieldDidChange(_ textField: UITextField) {
        var todoDocument : DocumentReference
        if pushedFromCompletedSection == true {
            self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
            todoDocument = self.completedTodoCollection.document(self.todo.id)
        } else {
            self.todoCollection = self.userDocument.collection("ToDoData")
            todoDocument = self.todoCollection.document(self.todo.id)
        }
        
        todoDocument.updateData(["toDoName": self.textField.text])
        
    }
    
    @objc func backTap(_ gesture: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
   
    
    //  MARK: listTap
    @objc func listTap(_ gesture: UITapGestureRecognizer) {
        let listAlert = UIAlertController(title: nil, message: "Choose List", preferredStyle: .alert)
        listAlert.view.backgroundColor = .white
        listAlert.view.layer.cornerRadius = 18
        listAlert.view.tintColor = .systemBlue
        
        switch listData.count {
        case 0:
            print("0")
        case 1:
            listAlert.addAction(UIAlertAction(title: listData[0].listName, style: .default, handler: { action in

                self.listIcon.tintColor = self.convertColor(self.listData[0].listTheme)
                self.listLabel.text = self.listData[0].listName
                self.listLabel.textColor = self.convertColor(self.listData[0].listTheme)
                self.todo.listID = self.listData[0].listID
                self.todo.listName = self.listData[0].listName
                
                var todoDocument : DocumentReference
                if self.pushedFromCompletedSection == true {
                    self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
                    todoDocument = self.completedTodoCollection.document(self.todo.id)
                } else {
                    self.todoCollection = self.userDocument.collection("ToDoData")
                    todoDocument = self.todoCollection.document(self.todo.id)
                }
                
                todoDocument.updateData(["listID": self.listData[0].listID,"listName" : self.listData[0].listName])
            }))
        default:
            for i in listData[0...listData.count-1] {
                listAlert.addAction(UIAlertAction(title: i.listName, style: .default, handler: { action in
                    self.listIcon.tintColor = self.convertColor(i.listTheme)
                    self.listLabel.text = i.listName
                    self.listLabel.textColor = self.convertColor(i.listTheme)
                    self.todo.listID = i.listID
                    self.todo.listName = i.listName
                    
                    var todoDocument : DocumentReference
                    if self.pushedFromCompletedSection == true {
                        self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
                        todoDocument = self.completedTodoCollection.document(self.todo.id)
                    } else {
                        self.todoCollection = self.userDocument.collection("ToDoData")
                        todoDocument = self.todoCollection.document(self.todo.id)
                    }
                    
                    todoDocument.updateData(["listID": i.listID,"listName" : i.listName])
                }))
            }
        }
        
        listAlert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: { action in
            var todoDocument : DocumentReference
            if self.pushedFromCompletedSection == true {
                self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
                todoDocument = self.completedTodoCollection.document(self.todo.id)
            } else {
                self.todoCollection = self.userDocument.collection("ToDoData")
                todoDocument = self.todoCollection.document(self.todo.id)
            }
            
            todoDocument.updateData(["listID": defaultTaskList.listID,"listName" : defaultTaskList.listName])
            
            self.todo.listID = defaultTaskList.listID
            self.todo.listName = defaultTaskList.listName
            self.listIcon.tintColor = .darkGray
            self.listLabel.text = "List"
            self.listLabel.textColor = .black
        }))
        
        self.present(listAlert, animated: true)
    }
    
    //  MARK: dueDateIconTap
    @objc func dueDateIconTap(_ gesture: UITapGestureRecognizer) {
        var todoDocument : DocumentReference
        if self.pushedFromCompletedSection == true {
            self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
            todoDocument = self.completedTodoCollection.document(self.todo.id)
        } else {
            self.todoCollection = self.userDocument.collection("ToDoData")
            todoDocument = self.todoCollection.document(self.todo.id)
        }
        
        todoDocument.updateData(["dueDate": nil as String?])
        
        self.todo.dueDate = nil
        
        self.dueDateIcon.tintColor = .darkGray
        self.dueDateLabel.text = "Due"
        self.dueDateLabel.textColor = .black
    }
    
    //  MARK: dueDatePicker
    @objc func dueDatePickerValueChanged(_ sender: UIDatePicker) {
        var todoDocument : DocumentReference
        if self.pushedFromCompletedSection == true {
            self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
            todoDocument = self.completedTodoCollection.document(self.todo.id)
        } else {
            self.todoCollection = self.userDocument.collection("ToDoData")
            todoDocument = self.todoCollection.document(self.todo.id)
        }
        
        todoDocument.updateData(["dueDate": "\(sender.date)", "originalDueDate" : "\(sender.date)","originalRemind" : self.todo.remindTime , "repeatTimes" : 0])
        
        self.todo.dueDate = "\(sender.date)"
        self.dueDateLabel.text = Date().relativeDate(sender.date)
        if sender.date > Date() {
            self.dueDateLabel.textColor = self.convertColor(editTheme)
            self.dueDateIcon.tintColor = self.convertColor(editTheme)
        } else {
            self.dueDateLabel.textColor = .red
            self.dueDateIcon.tintColor = .red
        }
        
    }
    
    //  MARK: remindPicker
    @objc func remindPickerValueChanged(_ sender: UIDatePicker) {
        var todoDocument : DocumentReference
        if self.pushedFromCompletedSection == true {
            self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
            todoDocument = self.completedTodoCollection.document(self.todo.id)
        } else {
            self.todoCollection = self.userDocument.collection("ToDoData")
            todoDocument = self.todoCollection.document(self.todo.id)
        }
        
        todoDocument.updateData(["remindTime": "\(sender.date)", "originalRemind" : "\(sender.date)","originalDueDate" : self.todo.dueDate , "repeatTimes" : 0])
        
        self.todo.remindTime = "\(sender.date)"
        self.remindLabel.text = Date().relativeDate(sender.date)
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [ self.todo.id])
        
        notiManager.notifications.append(Notification(id: self.todo.id, title: self.todo.toDoName, datetime: sender.date))
        
        notiManager.schedule()
        
        if sender.date > Date() {
            self.remindIcon.tintColor = self.convertColor(editTheme)
            self.remindLabel.textColor = self.convertColor(editTheme)
        } else {
            self.remindIcon.tintColor = .red
            self.remindLabel.textColor = .red
        }
    }
    
    //  MARK: remindIconTap
    @objc func remindIconTap(_ gesture: UITapGestureRecognizer) {
        self.todo.remindTime = nil
        var todoDocument : DocumentReference
        if self.pushedFromCompletedSection == true {
            self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
            todoDocument = self.completedTodoCollection.document(self.todo.id)
        } else {
            self.todoCollection = self.userDocument.collection("ToDoData")
            todoDocument = self.todoCollection.document(self.todo.id)
        }
        
        todoDocument.updateData(["remindTime": self.todo.remindTime, "originalRemind" : self.todo.remindTime,"originalDueDate" : self.todo.dueDate , "repeatTimes" : 0])
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [ self.todo.id])
        
        self.remindIcon.tintColor = .darkGray
        self.remindLabel.text = "Remind"
        self.remindLabel.textColor = .black
        
    }
    
    //  MARK: repeatTap
    @objc func repeatTap(_ gesture: UITapGestureRecognizer) {
        let repeatAlert = UIAlertController(title: nil, message: "Repeat", preferredStyle: .alert)
        repeatAlert.view.backgroundColor = .white
        repeatAlert.view.layer.cornerRadius = 18
        repeatAlert.view.tintColor = .systemBlue
        repeatAlert.addAction(UIAlertAction(title: "Daily", style: .default, handler: { action in
            var todoDocument : DocumentReference
            if self.pushedFromCompletedSection == true {
                self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
                todoDocument = self.completedTodoCollection.document(self.todo.id)
            } else {
                self.todoCollection = self.userDocument.collection("ToDoData")
                todoDocument = self.todoCollection.document(self.todo.id)
            }
            
            todoDocument.updateData(["repeatToDo": "daily"])
            
            self.repeatIcon.tintColor = self.convertColor(self.editTheme)
            self.repeatLabel.text = "Daily"
            self.repeatLabel.textColor = self.convertColor(self.editTheme)
            }))
        
        repeatAlert.addAction(UIAlertAction(title: "Weekly", style: .default, handler: { action in
            var todoDocument : DocumentReference
            if self.pushedFromCompletedSection == true {
                self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
                todoDocument = self.completedTodoCollection.document(self.todo.id)
            } else {
                self.todoCollection = self.userDocument.collection("ToDoData")
                todoDocument = self.todoCollection.document(self.todo.id)
            }
            
            todoDocument.updateData(["repeatToDo": "weekly"])
            
            self.repeatIcon.tintColor = self.convertColor(self.editTheme)
            self.repeatLabel.text = "Weekly"
            self.repeatLabel.textColor = self.convertColor(self.editTheme)
            }))
        
        repeatAlert.addAction(UIAlertAction(title: "Monthly", style: .default, handler: { action in
            var todoDocument : DocumentReference
            if self.pushedFromCompletedSection == true {
                self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
                todoDocument = self.completedTodoCollection.document(self.todo.id)
            } else {
                self.todoCollection = self.userDocument.collection("ToDoData")
                todoDocument = self.todoCollection.document(self.todo.id)
            }
            
            todoDocument.updateData(["repeatToDo": "monthly"])
            
            self.repeatIcon.tintColor = self.convertColor(self.editTheme)
            self.repeatLabel.text = "Monthly"
            self.repeatLabel.textColor = self.convertColor(self.editTheme)
            }))
        
        repeatAlert.addAction(UIAlertAction(title: "Yearly", style: .default, handler: { action in
            var todoDocument : DocumentReference
            if self.pushedFromCompletedSection == true {
                self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
                todoDocument = self.completedTodoCollection.document(self.todo.id)
            } else {
                self.todoCollection = self.userDocument.collection("ToDoData")
                todoDocument = self.todoCollection.document(self.todo.id)
            }
            
            todoDocument.updateData(["repeatToDo": "yearly"])
            
            self.repeatIcon.tintColor = self.convertColor(self.editTheme)
            self.repeatLabel.text = "Yearly"
            self.repeatLabel.textColor = self.convertColor(self.editTheme)
            }))
        
        repeatAlert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: { action in
            var todoDocument : DocumentReference
            if self.pushedFromCompletedSection == true {
                self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
                todoDocument = self.completedTodoCollection.document(self.todo.id)
            } else {
                self.todoCollection = self.userDocument.collection("ToDoData")
                todoDocument = self.todoCollection.document(self.todo.id)
            }
            
            todoDocument.updateData(["repeatToDo": "none"])
            
            self.todo.repeatToDo = "none"
            self.repeatIcon.tintColor = .darkGray
            self.repeatLabel.text = "None"
            self.repeatLabel.textColor = .black
            }))
        self.present(repeatAlert, animated: true)
        
    }
    //  MARK: prioritizedTap
    @objc func prioritizedTap(_ gesture: UITapGestureRecognizer) {
        if self.todo.isPrioritized == false {
            var todoDocument : DocumentReference
            if self.pushedFromCompletedSection == true {
                self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
                todoDocument = self.completedTodoCollection.document(self.todo.id)
            } else {
                self.todoCollection = self.userDocument.collection("ToDoData")
                todoDocument = self.todoCollection.document(self.todo.id)
            }
            
            todoDocument.updateData(["isPrioritized": true])
            
            self.prioritizedButton.image = UIImage(named: "star-fill")!.tinted(with: self.convertColor(self.editTheme))
            self.todo.isPrioritized = true
        } else {
            var todoDocument : DocumentReference
            if self.pushedFromCompletedSection == true {
                self.completedTodoCollection = self.userDocument.collection("CompletedToDoData")
                todoDocument = self.completedTodoCollection.document(self.todo.id)
            } else {
                self.todoCollection = self.userDocument.collection("ToDoData")
                todoDocument = self.todoCollection.document(self.todo.id)
            }
            
            todoDocument.updateData(["isPrioritized": false])
            
            self.prioritizedButton.image = UIImage(named: "star")!.tinted(with: .darkGray)
            self.todo.isPrioritized  = false
        }
    }
    //  MARK: completeTap
    @objc func completeTap(_ gesture: UITapGestureRecognizer) {
        if self.todo.isComplete == false {
            
            do {
                        audioPlayer = try AVAudioPlayer(contentsOf: pianoSound)
                        audioPlayer.play()
                   } catch {
                      // error handle
                   }
            
            self.completedTodoCollection = userDocument.collection("CompletedToDoData")
            let completedTodoDocument = completedTodoCollection.document(todo.id)
            
            completedTodoDocument.setData(["toDoName": todo.toDoName, "listID" : todo.listID,"listName": todo.listName, "description" : todo.description, "createDate": "\(Date())", "dueDate": todo.dueDate, "remindTime" : todo.remindTime, "repeatToDo" :  "none", "isComplete" : true, "isPrioritized" : todo.isPrioritized, "originalDueDate" : todo.originalDueDate, "originalRemind" : todo.originalRemind, "repeatTimes" : todo.repeatTimes])
            
            self.todoCollection = self.userDocument.collection("ToDoData")
            let todoDocument = self.todoCollection.document(self.todo.id)
            todoDocument.delete()
            self.pushedFromCompletedSection = true
            self.completeButtonImageView.image = UIImage(named: "check")!.tinted(with: .gray)
            self.todo.isComplete = true
        } else {
            self.todoCollection = self.userDocument.collection("ToDoData")
            let todoDocument = self.todoCollection.document(self.todo.id)
    
            todoDocument.setData(["toDoName": todo.toDoName, "listID" : todo.listID,"listName": todo.listName, "description" : todo.description, "createDate": "\(Date())", "dueDate": todo.dueDate, "remindTime" : todo.remindTime, "repeatToDo" :  todo.repeatToDo, "isComplete" : false, "isPrioritized" : todo.isPrioritized, "originalDueDate" : todo.originalDueDate, "originalRemind" : todo.originalRemind, "repeatTimes" : todo.repeatTimes])
            
            completedTodoCollection = userDocument.collection("CompletedToDoData")
            let document = completedTodoCollection.document(self.todo.id)
            document.delete()
            self.pushedFromCompletedSection = false
            self.completeButtonImageView.image = UIImage(named: "circle")
            self.todo.isComplete = false
        }
    }
    
    @objc func descriptionTap(_ gesture: UITapGestureRecognizer) {
        let vc = DescriptionViewController()
        vc.todo = self.todo
        vc.pushedFromCompletedSection = self.pushedFromCompletedSection
        vc.passDescription = { todo in
//            self.descriptionCoverLabel.text = todo.description
            self.todo = todo
            
            if todo.description != "" {
                self.descriptionCoverLabel.text = todo.description
                self.descriptionCoverLabel.textColor = .black
            } else {
                self.descriptionCoverLabel.text = "Enter description..."
                self.descriptionCoverLabel.textColor = .lightGray
            }
            
        }
        
        vc.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
    
}


