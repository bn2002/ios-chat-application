//
//  RegisterViewController.swift
//  Chat App
//
//  Created by Developer on 31/01/2023.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class RegisterViewController: UIViewController {

    @IBOutlet weak var firstnameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var userAvatar: UIImageView!
    
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Đăng ký"
        firstnameTextField.delegate = self
        lastnameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        initTemplate()
        // Do any additional setup after loading the view.
    }
    
    private func initTemplate() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(didAvatarTap))
        
        userAvatar.addGestureRecognizer(tap)
        
        let listComponents = [firstnameTextField, lastnameTextField, passwordTextField, emailTextField, registerButton]
        
        for component in listComponents {
            component?.layer.cornerRadius = 12
            guard let _: UIButton = component as? UIButton else {
                component?.layer.borderWidth = 1
                component?.layer.borderColor = UIColor.lightGray.cgColor
                continue;
            }
           
         
        }
    }
    
    @objc func didAvatarTap() {
        presentPhotoAndActionSheet()
    }

    @IBAction func didRegisterPressed(_ sender: UIButton) {
        submitRegister()
    }
    
    
    
    func registerAlertError(message: String) {
        let alert = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Đóng", style: .cancel))
        present(alert, animated: true)
    }


}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let restorationIdentifier = textField.restorationIdentifier {
            if(restorationIdentifier == "submit") {
                submitRegister()
                return true;
            }
        }
        
        switchBasedNextTextField(textField)
        return true
    }
    
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case self.firstnameTextField:
            self.lastnameTextField.becomeFirstResponder()
            break
        case self.lastnameTextField:
            self.emailTextField.becomeFirstResponder()
            break
        case self.emailTextField:
            self.passwordTextField.becomeFirstResponder()
            break
        default:
            break
        }
        
    }
}

extension RegisterViewController {
    func submitRegister() {
        guard
            let firstname = firstnameTextField.text,
            let lastname = lastnameTextField.text,
            let email = emailTextField.text,
            let password = passwordTextField.text,
            !email.isEmpty,
            !password.isEmpty,
            !firstname.isEmpty,
            !lastname.isEmpty
        else {
            registerAlertError(message: "Vui lòng nhập đầy đủ thông tin")
            return
        }
        
        spinner.show(in: view)
        
        DatabaseManager.shared.isUserExist(email: email) { isSuccess in
            if(isSuccess) {
                self.registerAlertError(message: "Tài khoản này đã tồn tại trên hệ thống")
                self.spinner.dismiss(animated: true)
                return
            }
        }
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            guard let result = authResult, error == nil else {
                self.registerAlertError(message: error!.localizedDescription)
                return;
            }
            
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstname) \(lastname)", forKey: "name")
            let user = User(firstname: firstname, lastname: lastname, email: email, photoUrl: "")
            DatabaseManager.shared.insertUser(with: user) { isSuccess in
                if(!isSuccess) {
                    self.registerAlertError(message: "Có lỗi trong quá trình đăng ký")
                    return
                } else {
                    self.registerAlertError(message: "Đăng ký thành công, vui lòng đăng nhập")
                    self.passwordTextField.text = ""
                    self.emailTextField.text = ""
                    self.firstnameTextField.text = ""
                    self.lastnameTextField.text = ""
                }
                
            }
        }
        
        spinner.dismiss(animated: true)
        
        
        
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func presentPhotoAndActionSheet() {
        let actionSheet = UIAlertController(title: "Chọn Avatar", message: "Hãy lựa chọn avatar của bạn", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { [weak self] _ in
            self?.presentCamera();
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Thư viện ảnh", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker();
        }))
        
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        
    }
}
