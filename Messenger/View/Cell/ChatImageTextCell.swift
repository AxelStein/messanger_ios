//
//  ChatImageTextCell.swift
//  Messenger
//
//  Created by Александр Шерий on 20.12.2022.
//

import UIKit

class ChatImageTextCell: UITableViewCell {
    @IBOutlet weak var bubbleView: BubbleView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var readStatus: UIImageView?
    @IBOutlet weak var timeLabel: UILabel!
    var cellId: Int64 = 0
    
    func setMessage(_ message: Message.Data) {
        cellId = message.id
        photo.image = nil
        
        var width = -1
        var height = -1
        if let resolution = message.content.file?.metadata?.resolution {
            var frame = self.photo.frame
            width = resolution.width
            height = resolution.height
            
            let maxImageWidth = self.contentView.frame.width - 64 - 12
            let maxImageHeight = maxImageWidth * 3
            
            width = max(min(resolution.width, Int(maxImageWidth)), Int(maxImageWidth))
            height = width * resolution.height / resolution.width
            
            if height > Int(maxImageHeight) {
                height = Int(maxImageHeight)
            }
            
            frame.size = CGSize(width: width, height: height)
            
            self.photo.translatesAutoresizingMaskIntoConstraints = true
            self.photo.frame = frame
        }
        
        photo.roundCorners(corners: [.topLeft, .topRight], radius: 16)
        
        if let path = message.content.file?.conversionsImages?["thumb_big"], let url = URL(string: path) {
            imageLoader.load(url: url, id: message.id, width: width, height: height) { id, image in
                if self.cellId == id {
                    self.photo.image = image
                }
            }
        }
        
        let offset = message.isOwn ? "            \u{200c}" : "         \u{200c}"
        if let text = message.content.text {
            messageLabel.text = text.trimmingCharacters(in: .init(charactersIn: "\"")) + offset
        } else {
            messageLabel.text = nil
        }
        timeLabel.text = message.time
        
        // let icon = message.isPending ? "clock" : message.isRead ? "checkmark.circle.fill" : "checkmark.circle"
        let iconName = message.isRead ? "baseline_done_all_black_18pt" : "baseline_done_black_18pt"
        readStatus?.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        
        bubbleView.setMessageGroup(.none)
    }
}
