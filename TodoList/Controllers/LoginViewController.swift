//
//  LoginViewController.swift
//  TodoList
//
//  Created by Apple on 10/09/2021.
//

import UIKit
import Firebase
import ProgressHUD

class LoginViewController: UIViewController {
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "logo2")
        return imageView
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
    
    let logInButton: UIButton = {
        let button = UIButton()
        button.setTitle("Sign In", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let forgotPasswordButton: UIButton = {
        let button = UIButton()
        button.setTitle("Forgot Password?", for: .normal)
        button.setTitleColor(#colorLiteral(red: 0.2117647059, green: 0.6901960784, blue: 0.9568627451, alpha: 1), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    let signUpLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
   
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        signUpLabel.numberOfLines = 0
        var textArray = ["Don't have an account?", "Create account"]
        var colorArray = [#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1),#colorLiteral(red: 0.2117647059, green: 0.6901960784, blue: 0.9568627451, alpha: 1)]
        var fontArray = [UIFont]()
        
        fontArray.append(UIFont.systemFont(ofSize: 15, weight: .light))
        fontArray.append(UIFont.systemFont(ofSize: 15, weight: .semibold))

        forgotPasswordButton.addTarget(self, action: #selector(didTapForgotPassword), for: .touchUpInside)
        
        signUpLabel.attributedText = getAttributedString(arrayText: textArray, arrayColors: colorArray, arrayFonts: fontArray)
        
        logInButton.addTarget(self, action: #selector(didTapLogInButton), for: .touchUpInside)
        
        let tapgesture = UITapGestureRecognizer(target: self, action: #selector(didTapSignUpButton(_ :)))
        tapgesture.numberOfTapsRequired = 1
        signUpLabel.addGestureRecognizer(tapgesture)
        
        setUpElements()
        setUpConstraints()
        hideKeyboardWhenTappedAround()
    }
    
    // MARK: setUpElements
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the elements
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(logInButton)
        
    }
   
    // MARK: - setUpConstraints
    func setUpConstraints() {
        self.view.backgroundColor = .white
        self.view.addSubview(logoImageView)
        self.view.addSubview(emailTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(errorLabel)
        self.view.addSubview(logInButton)
        self.view.addSubview(signUpLabel)
        self.view.addSubview(forgotPasswordButton)
        
        NSLayoutConstraint.activate([
            logoImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            logoImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            logoImageView.widthAnchor.constraint(equalToConstant: 100),
            logoImageView.heightAnchor.constraint(equalToConstant: 100),
           
            emailTextField.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: -20),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            
            passwordTextField.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            
            forgotPasswordButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: 0),
            forgotPasswordButton.bottomAnchor.constraint(equalTo: passwordTextField.topAnchor, constant: 24),
            forgotPasswordButton.heightAnchor.constraint(equalToConstant: 20),
            forgotPasswordButton.widthAnchor.constraint(equalToConstant: 140),
            
            errorLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            errorLabel.heightAnchor.constraint(equalToConstant: 80),
            
            logInButton.bottomAnchor.constraint(equalTo: signUpLabel.topAnchor, constant: -15),
            logInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            logInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            logInButton.heightAnchor.constraint(equalToConstant: 50),
            
            signUpLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -40),
            signUpLabel.centerXAnchor.constraint(equalTo: logInButton.centerXAnchor),
            signUpLabel.heightAnchor.constraint(equalToConstant: 30),
            signUpLabel.widthAnchor.constraint(equalToConstant: 300)
            
        ])
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
    
    @objc func didTapForgotPassword (){
        let vc = ForgotPasswordViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapLogInButton (){
        ProgressHUD.show()
        Auth.auth().signIn(withEmail: self.emailTextField.text!, password: self.passwordTextField.text!) { authDataResult, error in
            ProgressHUD.dismiss()
            if authDataResult != nil {
                let vc = TodayViewController.init()
                self.navigationController?.pushViewController(vc, animated: true)    
                
            } else {
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            }
        }
    }
    
    @objc func didTapSignUpButton (_ gesture: UITapGestureRecognizer){
        guard let text = self.signUpLabel.text else { return }
        let conditionsRange = (text as NSString).range(of: "Create account")
        
        if gesture.didTapAttributedTextInLabel(label: self.signUpLabel, inRange: conditionsRange) {
            let vc = SignupViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
}

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = NSLineBreakMode.byWordWrapping
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
                                          y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y);
        var indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        indexOfCharacter = indexOfCharacter + 4
        
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}
