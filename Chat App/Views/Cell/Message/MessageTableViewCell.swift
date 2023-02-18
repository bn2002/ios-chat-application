//
//  MessageTableViewCell.swift
//  Chat App
//
//  Created by Developer on 14/02/2023.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageBubble: UIView!
    @IBOutlet weak var ivRightAvatar: UIImageView!
    @IBOutlet weak var ivLeftAvatar: UIImageView!
    @IBOutlet weak var messageContent: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        messageBubble.layer.cornerRadius = 10
        ivRightAvatar.layer.cornerRadius = CGRectGetWidth(ivRightAvatar.frame)/2.0
        self.ivRightAvatar.layer.masksToBounds = true
        ivLeftAvatar.layer.cornerRadius = CGRectGetWidth(ivLeftAvatar.frame)/2.0
        self.ivLeftAvatar.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
