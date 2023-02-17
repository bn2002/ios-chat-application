//
//  ChatViewController.swift
//  Chat App
//
//  Created by Developer on 14/02/2023.
//

import UIKit
import FirebaseAuth
class ChatViewController: UIViewController {

    @IBOutlet weak var tbvMessages: UITableView!
    @IBOutlet weak var tfMessageInput: UITextField!
    
    var receiveEmail: String?
    var isContactExist: Bool?
    var conversationID: String?
    
    var messages = [Message]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tbvMessages.delegate = self
        tbvMessages.dataSource = self
        tfMessageInput.delegate = self
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
                    print(self.messages.count)
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
        handleSendMessage(textContent: textField.text!)
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
            //loadMessages()
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
        vc.messageContent.text = message.content
        
        return vc
    }
    
    
}


