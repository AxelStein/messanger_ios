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
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var messageThumb: UIImageView!
    
    var channelId: Int64 = 0
    
    func setChannel(_ item: Channel) {
        channelId = item.id
        
        name.text = item.partner.fullname
        message.text = item.messageLast?.content.text
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
        }
    }
}
