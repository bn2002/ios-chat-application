//
//  LoginViewController.swift
//  Chat App
//
//  Created by Developer on 31/01/2023.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Đăng nhập"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Đăng ký", style: .done, target: self, action: #selector(didTapRegister))
        
        // Email Text Field
        emailTextField.layer.cornerRadius = 12
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = UIColor.lightGray.cgColor
        // Password Text Field
        passwordTextField.layer.cornerRadius = 12
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = UIColor.lightGray.cgColor
        // Login Button
        loginButton.layer.cornerRadius = 12
    }


    @objc func didTapRegister() {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty else {
            loginAlertError(message: "Hãy nhập đầy đủ thông tin")
            return
        }
        
        spinner.show(in: view)
        // Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss(animated: true)
            }
            
            guard let result = authResult, error == nil else {
                print("Fail to login to user: \(email)")
                strongSelf.loginAlertError(message: "Tài khoản hoặc mật khẩu không chính xác.")
                return
            }
            
            DatabaseManager.shared.getDataFor(path: email) { result in
               
                switch result {
                case .success(let data):
                    guard
                        let userData = data as? [String: Any],
                        let firstName = userData["firstname"] as? String,
                        let lastName = userData["lastname"] as? String,
                        let photoUrl = userData["photoUrl"] as? String
                    else {
                        print("Decode error")
                        return
                    }
                    
                    break
                case .failure(let error):
                    print("Login error \(error)")
                    break
                }
            }

            UserDefaults.standard.set(email, forKey: "email")
            strongSelf.navigationController?.dismiss(animated: true)
            
        }
        
        

    }
    
    
    func loginAlertError(message: String) {
        let alert = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Đóng", style: .cancel))
        present(alert, animated: true)
    }
}
