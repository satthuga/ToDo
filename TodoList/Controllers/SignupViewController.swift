//
//  SignupViewController.swift
//  TodoList
//
//  Created by Apple on 10/09/2021.
//

import UIKit
import Firebase
import ProgressHUD
import FirebaseFirestore

class SignupViewController: UIViewController {
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo2")
        return imageView
    }()
    
    
    let textFieldStackView : UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let firstNameTextField : UITextField = {
        let text = UITextField()
        text.placeholder = "First name"
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    
    let lastNameTextField : UITextField = {
        let text = UITextField()
        text.placeholder = "Last name"
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    
    let emailTextField : UITextField = {
        let text = UITextField()
        text.placeholder = "Email"
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    let passwordTextField : UITextField = {
        let text = UITextField()
        text.placeholder = "Password"
        text.isSecureTextEntry = true
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create account", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let termsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let signInLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let termsCheckbox: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "square"), for: .normal)
        button.tintColor = #colorLiteral(red: 0.2117647059, green: 0.6901960784, blue: 0.9568627451, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var argeedTerms = false
  
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        termsLabel.numberOfLines = 0
        let termsTextArray = ["I agree with our", "Terms & Conditions"]
        let termsColorArray = [#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1),#colorLiteral(red: 0.2117647059, green: 0.6901960784, blue: 0.9568627451, alpha: 1)]
        var termsFontArray = [UIFont]()
        
        termsFontArray.append(UIFont.systemFont(ofSize: 15, weight: .light))
        termsFontArray.append(UIFont.systemFont(ofSize: 15, weight: .semibold))
        
        termsLabel.attributedText = getAttributedString(arrayText: termsTextArray, arrayColors: termsColorArray, arrayFonts: termsFontArray)
        
        signInLabel.numberOfLines = 0
        let signInTextArray = ["Already have an account?", "Sign In"]
        let signInColorArray = [#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1),#colorLiteral(red: 0.2117647059, green: 0.6901960784, blue: 0.9568627451, alpha: 1)]
        var signInFontArray = [UIFont]()
        
        signInFontArray.append(UIFont.systemFont(ofSize: 15, weight: .light))
        signInFontArray.append(UIFont.systemFont(ofSize: 15, weight: .semibold))
        
        signInLabel.attributedText = getAttributedString(arrayText: signInTextArray, arrayColors: signInColorArray, arrayFonts: signInFontArray)
        
        let termsTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapTerms(_ :)))
        termsTapGesture.numberOfTapsRequired = 1
        termsLabel.addGestureRecognizer(termsTapGesture)
        
        let signInTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSignInButton(_ :)))
        signInTapGesture.numberOfTapsRequired = 1
        signInLabel.addGestureRecognizer(signInTapGesture)
        
        signUpButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
        
        termsCheckbox.addTarget(self, action: #selector(didTapArgeedTerms), for: .touchUpInside)
        
        setUpElements()
        setUpConstraints()
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: setUpElements
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the elements
        Utilities.styleTextField(firstNameTextField)
        Utilities.styleTextField(lastNameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)
    }
    
    // MARK: - setUpConstraints
    func setUpConstraints() {
        self.view.backgroundColor = .white
        self.view.addSubview(logoImageView)
        self.view.addSubview(textFieldStackView)
        self.view.addSubview(errorLabel)
        self.view.addSubview(termsLabel)
        self.view.addSubview(signUpButton)
        self.view.addSubview(signInLabel)
        self.view.addSubview(termsCheckbox)
        
        textFieldStackView.addArrangedSubview(firstNameTextField)
        textFieldStackView.addArrangedSubview(lastNameTextField)
        textFieldStackView.addArrangedSubview(emailTextField)
        textFieldStackView.addArrangedSubview(passwordTextField)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            logoImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
            
            textFieldStackView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -20),
            textFieldStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
            textFieldStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            textFieldStackView.heightAnchor.constraint(equalToConstant: 185),
            
            firstNameTextField.heightAnchor.constraint(equalToConstant: 35),
            lastNameTextField.heightAnchor.constraint(equalToConstant: 35),
            emailTextField.heightAnchor.constraint(equalToConstant: 35),
            passwordTextField.heightAnchor.constraint(equalToConstant: 35),
            
            termsCheckbox.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 10),
            termsCheckbox.leadingAnchor.constraint(equalTo: textFieldStackView.leadingAnchor, constant: -5),
            termsCheckbox.heightAnchor.constraint(equalToConstant: 40),
            termsCheckbox.widthAnchor.constraint(equalToConstant: 40),
            
            termsLabel.centerYAnchor.constraint(equalTo: termsCheckbox.centerYAnchor, constant: -1),
            termsLabel.leadingAnchor.constraint(equalTo: termsCheckbox.trailingAnchor, constant: 0),
            termsLabel.heightAnchor.constraint(equalToConstant: 20),
            termsLabel.widthAnchor.constraint(equalToConstant: 250),
            
            errorLabel.topAnchor.constraint(equalTo: termsCheckbox.bottomAnchor, constant: 0),
            errorLabel.leadingAnchor.constraint(equalTo: textFieldStackView.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: textFieldStackView.trailingAnchor),
            errorLabel.heightAnchor.constraint(equalToConstant: 60),
            
            signUpButton.bottomAnchor.constraint(equalTo: signInLabel.topAnchor, constant: -15),
            signUpButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            signUpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            signInLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40),
            signInLabel.centerXAnchor.constraint(equalTo: signUpButton.centerXAnchor),
            signInLabel.heightAnchor.constraint(equalToConstant: 30),
            signInLabel.widthAnchor.constraint(equalToConstant: 250),
            
        ])
    }
    
    func validateFields() -> String? {
        
        // Check that all fields are filled in
        if firstNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields."
        }
        
        // Check if the password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            // Password isn't secure enough
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        
        if self.argeedTerms == false {
            // Password isn't secure enough
            return "Please agree with our Terms and Conditions."
        }
        
        return nil
    }
    
    func getAttributedString(arrayText:[String]?, arrayColors:[UIColor]?, arrayFonts:[UIFont]?) -> NSMutableAttributedString {
        let finalAttributedString = NSMutableAttributedString()
        for i in 0 ..< (arrayText?.count)! {
            var attributes: [NSAttributedString.Key : Any]?
            
            attributes = [NSAttributedString.Key.foregroundColor: arrayColors?[i] as Any, NSAttributedString.Key.font: arrayFonts?[i] as Any] as [NSAttributedString.Key : Any]
            
            let attributedStr = (NSAttributedString.init(string: arrayText?[i] ?? "", attributes: attributes))
            if i != 0 {
                finalAttributedString.append(NSAttributedString.init(string: " "))
            }
            
            finalAttributedString.append(attributedStr)
        }
        return finalAttributedString
    }
    
    @objc func didTapTerms (_ gesture: UITapGestureRecognizer){
        guard let text = self.termsLabel.text else { return }
        let conditionsRange = (text as NSString).range(of: "Terms & Conditions")
        
        if gesture.didTapAttributedTextInLabel(label: self.termsLabel, inRange: conditionsRange) {
            
            print("Terms and Conditions")
        }
    }
    
    @objc func didTapArgeedTerms() {
        if argeedTerms == false {
            termsCheckbox.setImage(UIImage(systemName: "checkmark.square.fill"), for: .normal)
            argeedTerms = true
        }
        else {
            termsCheckbox.setImage(UIImage(systemName: "square"), for: .normal)
            argeedTerms = false
        }
        
    }
    
    @objc func didTapSignInButton (_ gesture: UITapGestureRecognizer){
        guard let text = self.signInLabel.text else { return }
        let conditionsRange = (text as NSString).range(of: "Sign In")
        
        if gesture.didTapAttributedTextInLabel(label: self.signInLabel, inRange: conditionsRange) {
            
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func didTapSignUpButton() {
        // Validate the fields
        let error = validateFields()
        
        if error != nil {
            
            // There's something wrong with the fields, show error message
            showError(error!)
            
        }
        else {
            ProgressHUD.show()
            // Create cleaned versions of the data
            let firstName = firstNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                // Check for errors
                if err != nil {
                    
                    // There was an error creating the user
                    self.showError(err!.localizedDescription)
                    ProgressHUD.dismiss()
                }
                else {
                    
                    // User was created successfully, now store the first name and last name
                    if let user = result?.user {
                        let collection = Firestore.firestore().collection("users")
                        let userRef = collection.document(user.uid)
                        userRef.setData( ["firstName":firstName, "lastName":lastName,"email":email, "uid": result!.user.uid, "password" : password]) { (error) in
                            
                            if error != nil {
                                // Show error message
                                self.showError("Error saving user data")
                            }
                        }
                        ProgressHUD.dismiss()
                    }
                    
                    // Transition to the Login
                    self.transitionToLogin()
                    ProgressHUD.dismiss()
                }
            }
        }
    }
   
    
    func showError(_ message:String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToLogin() {
        try? Auth.auth().signOut()
        navigationController?.popViewController(animated: true)
    }
}
