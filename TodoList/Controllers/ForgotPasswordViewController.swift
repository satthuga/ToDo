//
//  ForgotPasswordViewController.swift
//  TodoList
//
//  Created by Apple on 10/09/2021.
//

import UIKit
import Firebase
import ProgressHUD

class ForgotPasswordViewController: UIViewController {
    
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
        label.text = "Sign In"
        label.textColor = #colorLiteral(red: 0.2117647059, green: 0.6901960784, blue: 0.9568627451, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        return label
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Forgot password?"
        label.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = "Please enter your email address to request a password reset."
        label.textColor = .lightGray
        label.font = UIFont.systemFont(ofSize: 17, weight: .light)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailTextField : UITextField = {
        let text = UITextField()
        text.placeholder = "Email"
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    let continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let messageLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        continueButton.addTarget(self, action: #selector(didTapContinueButton), for: .touchUpInside)
        
        let onTapBackGesture = UITapGestureRecognizer(target: self, action: #selector(self.backTap(_:)))
        backView.addGestureRecognizer(onTapBackGesture)
        
        setUpElements()
        setUpConstraints()
        hideKeyboardWhenTappedAround()
        
    }
    
    // MARK: setUpElements
    func setUpElements() {
        
        // Hide the error label
        self.messageLabel.alpha = 0
        
        // Style the elements
        Utilities.styleTextField(emailTextField)
        Utilities.styleFilledButton(continueButton)
        
    }
    
    // MARK: - setUpConstraints
    func setUpConstraints() {
        self.view.addSubview(backView)
        self.view.addSubview(titleLabel)
        self.view.addSubview(descriptionLabel)
        self.view.addSubview(emailTextField)
        self.view.addSubview(messageLabel)
        self.view.addSubview(continueButton)
        
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
        
        titleLabel.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 40).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -35).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 35).isActive = true
        titleLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -30).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 30).isActive = true
        descriptionLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        emailTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30).isActive = true
        emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        messageLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 15).isActive = true
        messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        messageLabel.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        continueButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -86).isActive = true
        continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
    }
    
    @objc func backTap(_ gesture: UITapGestureRecognizer) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func didTapContinueButton (){
        ProgressHUD.show()
        Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { error in
            if error != nil {
                self.messageLabel.alpha = 1
                self.messageLabel.text = error!.localizedDescription
                ProgressHUD.dismiss()
            } else {
                self.messageLabel.alpha = 1
                self.messageLabel.text = "A reset password link has been sent to your email."
                ProgressHUD.dismiss()
            }
        }
            
            }
   

}
