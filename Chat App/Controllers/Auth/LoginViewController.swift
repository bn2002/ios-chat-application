//
//  LoginViewController.swift
//  Chat App
//
//  Created by Developer on 31/01/2023.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
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
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty else {
            loginAlertError()
            return
        }
        

    }
    
    
    func loginAlertError() {
        let alert = UIAlertController(title: "Thông báo", message: "Hãy nhập đầy đủ thông tin", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Đóng", style: .cancel))
        present(alert, animated: true)
    }
}
