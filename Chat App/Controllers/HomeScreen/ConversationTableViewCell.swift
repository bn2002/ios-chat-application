//
//  ConversationTableViewCell.swift
//  Chat App
//
//  Created by Developer on 17/02/2023.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var lContactName: UILabel!
    @IBOutlet weak var ivUserAvatar: UIImageView!
    @IBOutlet weak var lContentMessage: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
