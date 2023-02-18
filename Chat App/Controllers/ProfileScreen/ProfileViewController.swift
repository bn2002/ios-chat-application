//
//  ProfileViewController.swift
//  Chat App
//
//  Created by Doanh on 18/02/2023.
//

import UIKit
import FirebaseAuth
import SDWebImage
class ProfileViewController: UIViewController {

    @IBOutlet weak var userAvatar: UIImageView!
    @IBOutlet weak var userEmail: UILabel!
    @IBOutlet weak var fullname: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Profile"
        userAvatar.layer.cornerRadius = CGRectGetWidth(userAvatar.frame)/2.0
        self.userAvatar.layer.masksToBounds = true
        setUserInfo()
    }
    
    deinit {
        print("ProfileViewController deinit")
    }

    @IBAction func didLogoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let loginVC = LoginViewController()
            let nav = UINavigationController(rootViewController: loginVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func setUserInfo() {
        Task {
            let currentEmail = Auth.auth().currentUser?.email
       
            let userData = await DatabaseManager.shared.getUser(email: currentEmail!)
            guard let userData = userData else {
                print("Không lấy được thông tin user")
                return
            }
            
            DispatchQueue.main.async {
                self.fullname.text = "\(userData.firstname) \(userData.lastname)"
                self.userEmail.text = userData.email
            }
            
            if let avatarURL = userData.photoUrl {
                print(avatarURL)
                DispatchQueue.main.async {
                    self.userAvatar.sd_setImage(with: URL(string: avatarURL), placeholderImage: UIImage(named: "User"))
                }
            }
          
        }
    }
    

    @IBAction func changePassPressed(_ sender: UIButton) {
        let user = Auth.auth().currentUser
        let changePassVc = ChangePassViewController()
        present(changePassVc, animated: true)
    }
}
