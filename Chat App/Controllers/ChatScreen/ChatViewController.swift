//
//  ChatViewController.swift
//  Chat App
//
//  Created by Developer on 14/02/2023.
//

import UIKit
import FirebaseAuth
import SDWebImage
class ChatViewController: UIViewController {

    @IBOutlet weak var tbvMessages: UITableView!
    @IBOutlet weak var tfMessageInput: UITextField!
    
    var receiveEmail: String?
    var isContactExist: Bool?
    var conversationID: String?
    
    var messages = [Message]()
    var contactAvatar: String?
    var myAvatar: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        tbvMessages.delegate = self
        tbvMessages.dataSource = self
        tfMessageInput.delegate = self
        self.tabBarController?.tabBar.isHidden = true
        let nib = UINib(nibName: "MessageTableViewCell", bundle: .main)
        tbvMessages.register(nib, forCellReuseIdentifier: "cell")
        if let conversationID = conversationID {
            loadMessages()
        }
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        print("button sent pressed")
        tfMessageInput.endEditing(true)
    }
    
    func loadMessages() {
        guard let conversationID = self.conversationID else {
            print("Chưa có conversation nên không thể load messages")
            return
        }
        
        DatabaseManager.shared.fetchMessage(conversationID: conversationID) {[weak self] querySnapshot, error in
            guard let `self` = self else {
                return
            }
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                print("Không lấy được documents")
                return
            }
            self.messages = []
            
            for document in documents {
                let data = document.data()
                if  let fromUser = data["fromUser"] as? String,
                    //let type = data["type"] as? String,
                    let content = data["content"] as? String,
                    let isSeen = data["isSeen"] as? Bool
                    //let createdAt = data["createdAt"] as? Date
                {
                    self.messages.append(Message(conversationID: conversationID, fromUser: fromUser, type: "", content: content, isSeen: isSeen, createdAt: Date()))
                    DispatchQueue.main.async {
                        self.tbvMessages.reloadData()
                        let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                        self.tbvMessages.scrollToRow(at: indexPath, at: .top, animated: false)
                    }
                }
            }
        }
    }
    
    deinit {
        print("ChatViewController deinit")
    }
}

extension ChatViewController:UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("textFieldDidEndEditing: Sent messages")
        if let message = textField.text, message.isEmpty == false {
            handleSendMessage(textContent: message)
        }
                
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
    
    func handleSendMessage(textContent: String) {
        guard let isContactExist = isContactExist, let receiveEmail = receiveEmail, let userEmail = Auth.auth().currentUser?.email else {
            print("Không thể kiểm tra liên hệ đã tồn tại")
            return
        }
        
        // Nếu chưa tồn tại tin nhắn giữa 2 người
        if(isContactExist == false) {
            // Tạo mới đoạn hội thoại
            let conversation = Conversation(createdAt: Date())
            self.conversationID = DatabaseManager.shared.createConversattion(conversation: conversation)
            guard let conversationID = self.conversationID else {
                print("Tạo cuộc trò chuyện thất bại")
                return
            }
            var newContact = Contact(email: userEmail, conversationID: conversationID, contactEmail: receiveEmail)
            // Tạo mới liên hệ vào tài khoản của cả 2 người
            DatabaseManager.shared.createContact(contact: newContact)
            newContact = Contact(email: receiveEmail, conversationID: conversationID, contactEmail: userEmail)
            DatabaseManager.shared.createContact(contact: newContact)
            // Tạo message
            self.isContactExist = true
            loadMessages()
        }
        
        Task {
            if(self.conversationID == nil) {
                self.conversationID = await DatabaseManager.shared.getConversationID(fromEmail: userEmail, toEmail: receiveEmail)
            }
            
            guard let conversationID = self.conversationID else {
                print("Lỗi không lấy được conversationID")
                return
            }
            
            let message = Message(conversationID: conversationID, fromUser: userEmail, type: "text", content: textContent, isSeen: false, createdAt: Date())
            DatabaseManager.shared.createMessage(message: message)
            
            tfMessageInput.text = ""
        }
        
        
    }
    
}

extension ChatViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let vc = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MessageTableViewCell
        let message = self.messages[indexPath.row]
        let currentUser = Auth.auth().currentUser?.email
        // Nếu là tin nhắn của mình
        if(currentUser == message.fromUser) {
            vc.ivLeftAvatar.isHidden = true
            vc.ivRightAvatar.isHidden = false
            vc.messageBubble.backgroundColor = UIColor(named: "BrandPurple")
            vc.messageContent.textColor = UIColor(named: "BrandLightPurple")
            if let myAvatar = self.myAvatar, myAvatar.isEmpty == false {
                vc.ivRightAvatar.sd_setImage(with: URL(string: myAvatar), placeholderImage: UIImage(named: "user_avatar.png"))
            }
           
        } else {
            vc.ivLeftAvatar.isHidden = false
            vc.ivRightAvatar.isHidden = true
            vc.messageBubble.backgroundColor = UIColor(named: "BrandBlue")
            vc.messageContent.textColor = UIColor(named: "BrandLightBlue")
            if let contactAvatar = self.contactAvatar, contactAvatar.isEmpty == false {
                vc.ivLeftAvatar.sd_setImage(with: URL(string: contactAvatar), placeholderImage: UIImage(named: "user_avatar.png"))
            }
        }
        
        vc.messageContent.text = message.content
        
        return vc
    }
    
    
}


