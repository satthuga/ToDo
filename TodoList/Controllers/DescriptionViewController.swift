//
//  DescriptionViewController.swift
//  TodoList
//
//  Created by Apple on 08/10/2021.
//

import UIKit
import Firebase
import FirebaseFirestore

class DescriptionViewController: UIViewController {
    let db = Firestore.firestore().collection("users")
    var userDocument: DocumentReference!
    var todoCollection: CollectionReference!
    var completedTodoCollection: CollectionReference!
    var todo :Todo = Todo()
    
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
        image.tintColor = #colorLiteral(red: 0.2117647059, green: 0.6901960784, blue: 0.9568627451, alpha: 1)
        image.image = UIImage(systemName: "arrow.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 10, weight: .light))
        
        return image
    }()
    
    let backLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Back"
        label.textColor = #colorLiteral(red: 0.2117647059, green: 0.6901960784, blue: 0.9568627451, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    let lineView :UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
     }()
    
    let textView :UITextView = {
        let text = UITextView()
        text.backgroundColor = .white
        text.font = UIFont.systemFont(ofSize: 18, weight: .light)
        text.translatesAutoresizingMaskIntoConstraints = false
        text.text = ""
        text.isUserInteractionEnabled = true
        text.textContainerInset = UIEdgeInsets(top: 6, left: 9, bottom: 0, right: 10)
        return text
     }()
    
    
    var todoDescription: String = ""
    var pushedFromCompletedSection = false
    var passDescription: ((Todo) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationController?.isNavigationBarHidden = true
        
        if todo.description != "" {
            self.textView.text = todo.description
            self.textView.textColor = .black
        }
        
        
        let onTapBackGesture = UITapGestureRecognizer(target: self, action: #selector(self.backTap(_:)))
        backView.addGestureRecognizer(onTapBackGesture)
        
        setUpConstraints()
        hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.async {
            self.textView.becomeFirstResponder()
        }
    }
    
    func setUpConstraints() {
        self.view.addSubview(backView)
        self.view.addSubview(textView)
        self.view.addSubview(lineView)
        
        backView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 18).isActive = true
        backView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
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
        
        lineView.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 10).isActive = true
        lineView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        lineView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        lineView.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        textView.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 30).isActive = true
        textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20).isActive = true
        textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }
    
    @objc func backTap(_ gesture: UITapGestureRecognizer) {
        guard let user = Auth.auth().currentUser else {
                    return
                }
                let userDocument = db.document(user.uid)
                let todoCollection = userDocument.collection("ToDoData")
                let completedTodoCollection = userDocument.collection("CompletedToDoData")
        
                var todoDocument : DocumentReference
                if self.pushedFromCompletedSection == true {
                    todoDocument = completedTodoCollection.document(self.todo.id)
                } else {
                    todoDocument = todoCollection.document(self.todo.id)
                }
                todoDocument.updateData(["description": textView.text ?? ""])
        self.todo.description = textView.text ?? ""
        passDescription?(self.todo)
        self.dismiss(animated: true, completion: nil)
    }
    

}

//// textView placeholder and update description
//extension DescriptionViewController : UITextViewDelegate {
//    func textViewDidBeginEditing(_ textView: UITextView) {
//            if textView.textColor == UIColor.lightGray {
//                textView.text = nil
//                textView.textColor = UIColor.black
//            }
//        }
//
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.isEmpty {
//            textView.text = " Enter description..."
//            textView.textColor = UIColor.lightGray
//        }
//    }
//
//    func textViewDidChangeSelection(_ textView: UITextView) {
//
//        guard let user = Auth.auth().currentUser else {
//            return
//        }
//        let userDocument = db.document(user.uid)
//        let todoCollection = userDocument.collection("ToDoData")
//        let completedTodoCollection = userDocument.collection("CompletedToDoData")
//
//        var todoDocument : DocumentReference
//        if self.pushedFromCompletedSection == true {
//            todoDocument = completedTodoCollection.document(self.todo.id)
//        } else {
//            todoDocument = todoCollection.document(self.todo.id)
//        }
//        todoDocument.updateData(["description": textView.text])
////        self.todo.description = textView.text
//    }
//}
