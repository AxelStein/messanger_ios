//
//  ChatImageCell.swift
//  Messenger
//
//  Created by Александр Шерий on 19.12.2022.
//

import UIKit

class ChatImageCell: UITableViewCell {
    @IBOutlet weak var photo: UIImageView!
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
            
            let minImageWidth = CGFloat(150)
            let maxImageWidth = self.contentView.frame.width - 64 - 12
            let maxImageHeight = maxImageWidth * 3
            
            width = max(min(resolution.width, Int(maxImageWidth)), Int(minImageWidth))
            height = width * resolution.height / resolution.width
            
            if height > Int(maxImageHeight) {
                height = Int(maxImageHeight)
            }
            
            frame.size = CGSize(width: width, height: height)
            
            self.photo.translatesAutoresizingMaskIntoConstraints = true
            self.photo.frame = frame
        }
        
        if let thumbURL = message.content.thumbBigURL, imageLoader.contains(url: thumbURL, conversion: "thumb_big") {
            self.loadImage(message, key: "thumb_big", width: width, height: height) {}
        } else {
            loadImage(message, key: "tiny_placeholder", width: width, height: height) {
                self.loadImage(message, key: "thumb_big", width: width, height: height) {}
            }
        }
        
        timeLabel.text = message.time
        
        // let icon = message.isPending ? "clock" : message.isRead ? "checkmark.circle.fill" : "checkmark.circle"
        let iconName = message.isRead ? "baseline_done_all_black_18pt" : "baseline_done_black_18pt"
        readStatus?.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
    }
    
    private func loadImage(
        _ message: Message.Data,
        key: String,
        width: Int,
        height: Int,
        completion: @escaping () -> Void
    ) {
        guard let path = message.content.file?.conversionsImages?[key] else { return }
        guard let url = URL(string: path) else { return }
        imageLoader.load(url: url, id: cellId, conversion: key, width: width, height: height) { id, image in
            if self.cellId == id {
                self.photo.image = image
                completion()
            }
        }
    }
}
