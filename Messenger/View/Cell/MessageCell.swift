//
//  MessageCell.swift
//  Messenger
//
//  Created by Александр Шерий on 09.07.2023.
//

import UIKit

class MessageCell: UITableViewCell {
    @IBOutlet weak var messageView: MessageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setMessage(_ message: Message.Data) {
        messageView.setMessage(message)
    }
}
