//
//  ChatOwnCell.swift
//  Messenger
//
//  Created by Александр Шерий on 11.12.2022.
//

import UIKit

class ChatTextCell: UITableViewCell {
    @IBOutlet weak var bubbleView: BubbleView!
    @IBOutlet weak var readStatus: UIImageView?
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var bubbleTopConstraint: NSLayoutConstraint!
    
    func setMessage(_ message: Message.Data) {
        let offset = message.isOwn ? "            \u{200c}" : "         \u{200c}"
        
        if let text = message.content.text {
            messageLabel.text = text.trimmingCharacters(in: .init(charactersIn: "\"")) + offset
        } else {
            messageLabel.text = nil
        }
        timeLabel.text = message.time
        bubbleView.setMessageGroup(message.group)
        
        bubbleTopConstraint.constant = message.group == .start || message.group == .none ? 6 : 3
        contentView.layoutIfNeeded()
        
        // let icon = message.isPending ? "clock" : message.isRead ? "checkmark.circle.fill" : "checkmark.circle"
        let icon = message.isRead ? "baseline_done_all_black_18pt" : "baseline_done_black_18pt"
        readStatus?.image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate)
    }
}
