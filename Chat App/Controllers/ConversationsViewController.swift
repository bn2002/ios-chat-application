//
//  ViewController.swift
//  Chat App
//
//  Created by Developer on 31/01/2023.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var searchBar: UISearchBar {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Nhập tên hoặc địa chỉ email cần tìm"
        return searchBar
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        initNavigationItem()
        DatabaseManager.shared.setPhotoUser(with: "Cdbqtn8q2aK8j6TkdoG3", photoURL: "http://localhost")
    }
    
    
    @IBAction func didLogoutPressed(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            validateIsLogin()
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    private func validateIsLogin() {
        if Auth.auth().currentUser == nil {
            let loginVC = LoginViewController()
            let nav = UINavigationController(rootViewController: loginVC)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    private func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateIsLogin()
        
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
        present(vc, animated: true)
    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Hello World"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatViewController()
        vc.title = "BN2002"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

