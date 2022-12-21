//
//  ChatFileCell.swift
//  Messenger
//
//  Created by Александр Шерий on 20.12.2022.
//

import UIKit

let byteCountFormatter = ByteCountFormatter()

class ChatFileCell: UITableViewCell {
    @IBOutlet weak var bubbleView: BubbleView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileInfoLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var readStatusView: UIImageView?
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bubbleTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setMessage(_ message: Message.Data) {
        fileNameLabel.text = message.content.file?.clientOriginalName
        fileInfoLabel.text = byteCountFormatter.string(fromByteCount: message.content.file?.size ?? 0)
        timeLabel.text = message.time
        
        let offset = message.isOwn ? "            \u{200c}" : "         \u{200c}"
        let text = message.content.text ?? ""
        if !text.isEmpty {
            messageLabel.text = text.trimmingCharacters(in: .init(charactersIn: "\"")) + offset
        } else {
            messageLabel.text = nil
        }
        
        let iconName = message.isRead ? "baseline_done_all_black_18pt" : "baseline_done_black_18pt"
        readStatusView?.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        bubbleView.setMessageGroup(message.group)
        
        bubbleTopConstraint.constant = message.group == .start || message.group == .none ? 6 : 3
        contentView.layoutIfNeeded()
    }
    
}
