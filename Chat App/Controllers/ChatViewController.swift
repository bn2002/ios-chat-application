//
//  ChatViewController.swift
//  Chat App
//
//  Created by Developer on 10/02/2023.
//

import UIKit
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var senderId: String
    var photoURL: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    
    private var messages = [Message]()
    private let mySender = Sender(senderId: "1", photoURL: "", displayName: "Duy Doanh")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messages.append(Message(sender: mySender, messageId: "1", sentDate: Date(), kind: .text("Hello world")))
        
        messages.append(Message(sender: mySender, messageId: "1", sentDate: Date(), kind: .text("Hello world")))
        // Do any additional setup after loading the view.
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
    }
    
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> MessageKit.SenderType {
        return mySender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
