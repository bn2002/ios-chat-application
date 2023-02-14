//
//  MessageTableViewCell.swift
//  Chat App
//
//  Created by Developer on 14/02/2023.
//

import UIKit

class MessageTableViewCell: UITableViewCell {

    @IBOutlet weak var ivRightAvatar: UIImageView!
    @IBOutlet weak var ivLeftAvatar: UIImageView!
    @IBOutlet weak var messageContent: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
