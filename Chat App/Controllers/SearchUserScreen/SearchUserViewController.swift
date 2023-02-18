//
//  SearchUserViewController.swift
//  Chat App
//
//  Created by Developer on 13/02/2023.
//

import UIKit
import SDWebImage
import FirebaseAuth
import JGProgressHUD

class SearchUserViewController: UIViewController {
 
    @IBOutlet weak var tbvSearchResult: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchDelayTimer: Timer?
    var filterList: [User]?
    weak var parentSelf: UIViewController?
    private let spinner = JGProgressHUD(style: .dark)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tbvSearchResult.delegate = self
        tbvSearchResult.dataSource = self
        let nib = UINib(nibName: "SearchUserTableViewCell", bundle: .main)
        tbvSearchResult.register(nib, forCellReuseIdentifier: "search_user_cell")
    }
    
    deinit {
        print("SearchUserViewController deint")
    }
}

extension SearchUserViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "search_user_cell", for: indexPath) as? SearchUserTableViewCell
        else {
            return UITableViewCell()
            
        }
        
        if let row = self.filterList {
            let user = row[indexPath.row]
            cell.usernameLabel.text = user.firstname + " " + user.lastname
            
            if let photoUrl = user.photoUrl, user.photoUrl?.isEmpty == false {
                cell.userAvatar.sd_setImage(with: URL(string: photoUrl), placeholderImage: UIImage(named: user.email))
            }
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let userData = filterList?[indexPath.row] else {
            print("didSelectRowAt Khong lay duoc thong tin user")
            return
        }
        
        DatabaseManager.shared.checkContactsExist(with: userData.email) {[weak self] result in
            guard let `self` = self else {
                return
            }
            switch result {
            case .success(let value):
                Task {
                    let vc = ChatViewController()
                    vc.isContactExist = value
                    vc.receiveEmail = userData.email
                    let userEmail = Auth.auth().currentUser?.email
                    if(value == true) {
                        let conversationID = await DatabaseManager.shared.getConversationID(fromEmail: userEmail!, toEmail: userData.email)
                        vc.conversationID = conversationID
                    }
                    let contactAvatar = await DatabaseManager.shared.getPhotoUser(userEmail: userData.email)
                    var myAvatar = ""
                    if( UserDefaults.standard.string(forKey: "profile_picture_url") == nil ) {
                        myAvatar = await DatabaseManager.shared.getPhotoUser(userEmail: userEmail!)
                    } else {
                        myAvatar = UserDefaults.standard.string(forKey: "profile_picture_url") ?? ""
                    }
                    
                    vc.title = userData.firstname + " " + userData.lastname
                    vc.myAvatar = myAvatar
                    vc.contactAvatar = contactAvatar
                    self.dismiss(animated: true) {
                        self.parentSelf?.navigationController?.pushViewController(vc, animated: true)
                    }
                }
              
                break
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
        
    }
    
}

extension SearchUserViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchDelayTimer?.invalidate()
        if(searchText.count <= 0) {
            self.filterList?.removeAll()
            DispatchQueue.main.async {
                self.tbvSearchResult.reloadData()
            }
            return
        }
        
        self.spinner.show(in: self.view)
        
        self.searchDelayTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] (_) in
            guard let `self` = self else { return }
            DatabaseManager.shared.searchUser(with: searchText) { [weak self] (result) in
                guard let `self` = self else { return }
                self.filterList = result
                DispatchQueue.main.async {
                    self.tbvSearchResult.reloadData()
                    self.spinner.dismiss(animated: true)
                }
                
            }
           
        })
    }
    
}
