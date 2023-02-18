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
        ivUserAvatar.layer.cornerRadius = CGRectGetWidth(ivUserAvatar.frame)/2.0
        self.ivUserAvatar.layer.masksToBounds = true
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
