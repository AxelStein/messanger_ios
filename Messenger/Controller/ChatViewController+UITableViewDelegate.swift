//
//  ChatViewController+UITableViewDelegate.swift
//  Messenger
//
//  Created by Александр Шерий on 17.12.2022.
//

import UIKit

extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset
        let hideFab = offset.y <= 0
        fabScrollDown.isHidden = hideFab
        // print("offset=\(offset.y)")
        // unreadCount.isHidden = hideFab
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.clear
        
        if let cell = cell as? ChatVideoCell {
            cell.set(visible: true)
        }
        
        if indexPath.item == items.count - 30 {
            if let nextLink = links.next {
                fetchHistory(channelId: channel.id, cursor: nextLink)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let item = items[indexPath.item] as? MessageItem {
            let message = item.data
            if let cell = cell as? ChatVideoCell {
                cell.set(visible: false)
            }
            if message.content.mimeType == .image {
                if let url = message.content.thumbBigURL {
                    imageLoader.cancel(for: url)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.item]
        
        if let item = item as? MessageItem {
            let message = item.data
            
            var id = ""
            switch message.content.mimeType {
                case .video:
                    id = "ChatOwnVideoCell"
                    
                case .image:
                    let text = message.content.text
                    if let text = text, !text.isEmpty {
                        id = message.isOwn ? "ChatOwnImageTextCell" : "ChatPartnerImageTextCell"
                    } else {
                        id = message.isOwn ? "ChatOwnImageCell" : "ChatPartnerImageCell"
                    }
                    
                case .audio:
                    id = message.isOwn ? "ChatOwnAudioCell" : "ChatPartnerAudioCell"
                    
                case .text:
                    id = message.isOwn ? "ChatOwnTextCell" : "ChatPartnerTextCell"
                    
                case .file:
                    id = message.isOwn ? "ChatOwnFileCell" : "ChatPartnerFileCell"
            }
            
            let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath)
            if let cell = cell as? ChatAudioCell {
                cell.delegate = self
            }
            if let cell = cell as? ChatCell {
                cell.setMessage(message)
            }
            return cell
        }
        
        if let item = item as? DateItem {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChatDateCell") as! ChatDateCell
            cell.label.text = item.data
            return cell
        }
        
        fatalError()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
}
