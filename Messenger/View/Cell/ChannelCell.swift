//
//  ChannelCell.swift
//  Messenger
//
//  Created by Александр Шерий on 15.12.2022.
//

import UIKit

class ChannelCell: UITableViewCell {
    @IBOutlet weak var avatar: UIImageView!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var readStatus: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageThumb: UIImageView!
    
    var channelId: Int64 = 0
    
    func setChannel(_ item: Channel) {
        channelId = item.id
        
        name.text = item.partner.fullname
        
        var messageText = ""
        if let message = item.messageLast {
            switch message.content.mimeType {
                case .image:
                    messageText = "Image"
                    
                case .video:
                    messageText = "Video"
                    
                case .audio:
                    messageText = "Audio"
                    
                case .text:
                    messageText = message.content.text ?? ""
                    
                case .file:
                    messageText = message.content.file?.clientOriginalName ?? ""
            }
        }
        messageLabel.text = messageText
        
        time.text = item.time
        
        let isOwn = item.messageLast?.isOwn ?? false
        readStatus.isHidden = !isOwn
        
        let isRead = item.messageLast?.isRead ?? false
        let icon = isRead ? "baseline_done_all_black_18pt" : "baseline_done_black_18pt"
        readStatus?.image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate)
        
        avatar.image = nil
        
        if let url = URL(string: item.partner.avatarUrl) {
            imageLoader.load(url: url, id: item.id) { id, image in
                if self.channelId == id {
                    self.avatar.image = image
                }
            }
        } else {
            let partnerName = item.partner.fullname.prefix(2)
            avatar.image = imageWith(name: partnerName.uppercased())
        }
    }
}
