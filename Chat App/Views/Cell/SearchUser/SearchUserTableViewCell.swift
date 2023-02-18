//
//  SearchUserTableViewCell.swift
//  Chat App
//
//  Created by Developer on 13/02/2023.
//

import UIKit

class SearchUserTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userAvatar: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userAvatar.layer.cornerRadius = CGRectGetWidth(userAvatar.frame)/2.0
        self.userAvatar.layer.masksToBounds = true
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        userAvatar.image = UIImage(systemName: Constant.DEFAULT_AVATAR)
        usernameLabel.text = ""
    }
    
}
