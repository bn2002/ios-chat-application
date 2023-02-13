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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        userAvatar.image = nil
        usernameLabel.text = ""
    }
    
}
