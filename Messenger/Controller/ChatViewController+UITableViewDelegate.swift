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
        
        if indexPath.item == items.count - 30 {
            if let nextLink = links.next {
                fetchHistory(channelId: channel.id, cursor: nextLink)
            }
        }
        /*
        if indexPath.item == 0 {
            if let nextLink = links.next {
                fetchHistory(channelId: channel.id, cursor: nextLink)
            }
        }
        */
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let item = items[indexPath.item] as? MessageItem {
            let message = item.data
            if message.content.isImageFile || message.content.isVideoFile {
                if let path = message.content.file?.conversionsImages?["thumb_big"], let url = URL(string: path) {
                    imageLoader.cancel(for: url)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = items[indexPath.item]
        
        if let item = item as? MessageItem {
            let message = item.data
            if message.content.isImageFile || message.content.isVideoFile {
                let text = message.content.text
                if let text = text, !text.isEmpty {
                    let id = message.isOwn ? "ChatOwnImageTextCell" : "ChatPartnerImageTextCell"
                    let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ChatImageTextCell
                    cell.setMessage(message)
                    return cell
                }
                
                let id = message.isOwn ? "ChatOwnImageCell" : "ChatPartnerImageCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ChatImageCell
                cell.setMessage(message)
                return cell
            } else if message.content.isAudioFile {
                let id = message.isOwn ? "ChatOwnAudioCell" : "ChatPartnerAudioCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ChatAudioCell
                cell.setMessage(message)
                cell.delegate = self
                return cell
            } else if message.content.file != nil {
                let id = message.isOwn ? "ChatOwnFileCell" : "ChatPartnerFileCell"
                let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ChatFileCell
                cell.setMessage(message)
                return cell
            } else {
                let id = message.isOwn ? "ChatOwnTextCell" : "ChatPartnerTextCell"
                
                let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! ChatTextCell
                cell.setMessage(message)
                return cell
            }
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
