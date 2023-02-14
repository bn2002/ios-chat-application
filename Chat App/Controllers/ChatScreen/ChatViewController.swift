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
    let messages = [Message]()
    override func viewDidLoad() {
        super.viewDidLoad()
        tbvMessages.delegate = self
        tbvMessages.dataSource = self
        tfMessageInput.delegate = self
        let nib = UINib(nibName: "MessageTableViewCell", bundle: .main)
        tbvMessages.register(nib, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        tfMessageInput.endEditing(true)
    }
    
    deinit {
        print("ChatViewController deinit")
    }
}

extension ChatViewController:UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
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
        let conversation = Conversation(userOne: userEmail, userTwo: receiveEmail, createdAt: Date())
        let message = Message(conversationID: "", fromUser: userEmail, type: "text", content: textContent, isSeen: false, createdAt: Date())
        
        if(isContactExist == false) {
            DatabaseManager.shared.createConversattion(conversation: conversation, completion: { result in
                let newContact = Contact(email: userEmail, contactEmail: receiveEmail, lastMessage: message)
                DatabaseManager.shared.createContact(data: newContact)
            })
            
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
        vc.messageContent.text = "Noi dung"
        return vc
    }
    
    
}


