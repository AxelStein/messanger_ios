//
//  ChatAudioCell.swift
//  Messenger
//
//  Created by Александр Шерий on 21.12.2022.
//

import UIKit

protocol ChatAudioCellDelegate {
    func onPlayClick(path: String)
}

class ChatAudioCell: UITableViewCell {
    @IBOutlet weak var bubbleView: BubbleView!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var fileInfoLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var readStatus: UIImageView?
    @IBOutlet weak var playButtonContainer: UIView!
    @IBOutlet weak var playButton: UIImageView!
    @IBOutlet weak var bubbleTopConstraint: NSLayoutConstraint!
    
    private var messageId: Int64 = 0
    private var path: String? = nil
    var delegate: ChatAudioCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()

        playButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onPlayButtonClick))
        )
        playButtonContainer.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onPlayButtonClick))
        )
    }
    
    @objc func onPlayButtonClick(_ sender: Any) {
        if let path = path {
            delegate?.onPlayClick(path: path)
        }
    }
    
    func setMessage(_ message: Message.Data) {
        messageId = message.id
        path = message.content.file?.urlForDownload
        
        fileNameLabel.text = message.content.file?.clientOriginalName
        if let duration = message.content.file?.metadata?.duration {
            var seconds = duration / 1000
            let hours = seconds / 3600
            seconds -= hours * 3600
            let minutes = seconds / 60
            seconds -= minutes * 60
            
            if hours > 0 {
                let m = NSString(format:"%.2d", minutes)
                let s = NSString(format: "%.2d", seconds)
                fileInfoLabel.text = "\(hours):\(m):\(s)"
            } else {
                let s = NSString(format: "%.2d", seconds)
                fileInfoLabel.text = "\(minutes):\(s)"
            }
        } else {
            fileInfoLabel.text = " "
        }
        
        let offset = message.isOwn ? "            \u{200c}" : "         \u{200c}"
        let text = message.content.text ?? ""
        if !text.isEmpty {
            messageLabel.text = text.trimmingCharacters(in: .init(charactersIn: "\"")) + offset
        } else {
            messageLabel.text = nil
        }
        
        timeLabel.text = message.time
        bubbleView.setMessageGroup(message.group)
        
        bubbleTopConstraint.constant = message.group == .start || message.group == .none ? 6 : 3
        contentView.layoutIfNeeded()
        
        let icon = message.isRead ? "baseline_done_all_black_18pt" : "baseline_done_black_18pt"
        readStatus?.image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate)
    }
}
