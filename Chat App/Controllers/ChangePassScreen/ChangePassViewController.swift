//
//  ChangePassViewController.swift
//  Chat App
//
//  Created by Doanh on 18/02/2023.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ChangePassViewController: UIViewController {

    @IBOutlet weak var confirmPass: UITextField!
    @IBOutlet weak var newPass: UITextField!
    @IBOutlet weak var currentPass: UITextField!
    
    private let spinner = JGProgressHUD(style: .dark)
    override func viewDidLoad() {
        super.viewDidLoad()
        confirmPass.delegate = self
        newPass.delegate = self
        currentPass.delegate = self
        
        currentPass.becomeFirstResponder()
    }

    
    @IBAction func changePassPressed(_ sender: UIButton) {
        guard  let currentPass = currentPass.text,
               let newPass = newPass.text,
               let confirmPass = confirmPass.text,
               currentPass.isEmpty == false,
               newPass.isEmpty == false,
               confirmPass.isEmpty == false
        else {
            alertError(message: "Vui lòng nhập đầy đủ thông tin")
            return
        }
        
        if newPass != confirmPass {
            alertError(message: "Mật khẩu xác nhận không chính xác")
            return
        }
        self.spinner.show(in: self.view)
        let user = Auth.auth().currentUser
        let currentEmail = user?.email
        
        let credential = EmailAuthProvider.credential(withEmail: currentEmail!, password: currentPass)
        user?.reauthenticate(with: credential) {[weak self] result, error  in
            guard let `self` = self else {
                return
            }
            
            if let error = error {
                self.alertError(message: "Mật khẩu hiện tại không chính xác.")
                return
            } else {
                user?.updatePassword(to: newPass)
                self.currentPass.text = ""
                self.confirmPass.text = ""
                self.newPass.text = ""
                self.alertError(message: "Đổi mật khẩu thành công")
            }
        }
        
        self.spinner.dismiss(animated: true)

    }
    
    func alertError(message: String) {
        let alert = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Đóng", style: .cancel))
        present(alert, animated: true)
    }
    
}

extension ChangePassViewController:UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switchBasedNextTextField(textField)
        return true
    }
    
    private func switchBasedNextTextField(_ textField: UITextField) {
        switch textField {
        case self.currentPass:
            self.newPass.becomeFirstResponder()
            break
        case self.newPass:
            self.confirmPass.becomeFirstResponder()
            break
        default:
            break
        }
        
    }
}
