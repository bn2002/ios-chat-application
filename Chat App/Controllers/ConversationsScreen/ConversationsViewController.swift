//
//  ViewController.swift
//  Chat App
//
//  Created by Developer on 31/01/2023.
//

import UIKit
import FirebaseAuth
import SDWebImage
import JGProgressHUD

class ConversationsViewController: UIViewController {

    @IBOutlet weak var noConversation: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    var contacts = [[String:Any]]()
    private let spinner = JGProgressHUD(style: .dark)
    private var searchBar: UISearchBar {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Nhập tên hoặc địa chỉ email cần tìm"
        return searchBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Chat"
        validateIsLogin()
        initNavigationItem()
        setUpTableView()
    }
    
    private func validateIsLogin() {
        if Auth.auth().currentUser == nil {
            print("Chưa login, vui lòng đăng nhập")
            let loginVC = LoginViewController()
            let nav = UINavigationController(rootViewController: loginVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        let nib = UINib(nibName: "ConversationTableViewCell", bundle: .main)
        tableView.register(nib, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        if Auth.auth().currentUser != nil {
            spinner.show(in: view)
            loadContacts()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        
    }
    
    func loadContacts() {
        Task {
            let userEmail = Auth.auth().currentUser?.email
            self.contacts = await DatabaseManager.shared.fetchContact(email: userEmail!)
            if self.contacts.count <= 0 {
                DispatchQueue.main.async {
                    self.noConversation.isHidden = false
                    self.tableView.isHidden = true
                }
            } else {
                DispatchQueue.main.async {
                    self.tableView.isHidden = false
                    self.noConversation.isHidden = true
                    self.tableView.reloadData()
                    
                }
            }
            self.spinner.dismiss(animated: true)
        }
    }
    
}

extension ConversationsViewController {
    
    func initNavigationItem() {
        let newConversationIcon = UIImage(systemName: "plus.message")
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(
                image: newConversationIcon,
                style: .plain,
                target: self,
                action: #selector(didNewConversationPressed)
            )
        
    }
    @objc func didNewConversationPressed() {
        let vc = SearchUserViewController()
        vc.parentSelf = self
        present(vc, animated: true)
    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ConversationTableViewCell
        let contact = contacts[indexPath.row]
        let photoURL = contact["contactAvatar"] as? String ?? ""
        cell.ivUserAvatar.sd_setImage(with: URL(string: photoURL))
        cell.lContactName.text = contact["fullname"] as? String ?? ""
        let lastMessage = contact["lastMessage"] as? Message
        if let lastMessage = lastMessage {
            if(lastMessage.content.count > 30) {
                let message = String(lastMessage.content.prefix(29))
                cell.lContentMessage.text = ("\(message)...")
            } else {
                cell.lContentMessage.text = lastMessage.content
            }
            
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        Task {
            let vc = ChatViewController()
            let contact = contacts[indexPath.row]
            vc.title = contact["fullname"] as? String ?? ""
            vc.contactAvatar = contact["contactAvatar"] as? String ?? ""
            vc.conversationID = contact["conversationID"] as? String ?? ""
            var myAvatar = ""
            let userEmail = Auth.auth().currentUser?.email
            if( UserDefaults.standard.string(forKey: "profile_picture_url") == nil ) {
                myAvatar = await DatabaseManager.shared.getPhotoUser(userEmail: userEmail!)
            } else {
                myAvatar = UserDefaults.standard.string(forKey: "profile_picture_url") ?? ""
            }
            vc.myAvatar = myAvatar
            vc.isContactExist = true
            vc.receiveEmail = contact["email"] as? String ?? ""
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        }
       
    }
    
    
}

