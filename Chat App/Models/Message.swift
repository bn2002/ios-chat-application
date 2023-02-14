//
//  Message.swift
//  Chat App
//
//  Created by Developer on 14/02/2023.
//

import Foundation
struct Message {
    let conversationID: String
    let fromUser: String
    let type: String
    let content: String
    let isSeen: Bool
    let createdAt: Date
}
