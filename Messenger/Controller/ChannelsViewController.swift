//
//  ChannelsViewController.swift
//  Messenger
//
//  Created by Александр Шерий on 15.12.2022.
//

import UIKit

class ChannelsViewController: UITableViewController {
    private let api = ChannelApi()
    private var channels = [Channel]()
    
    override func viewDidLoad() {
        Task {
            do {
                channels = try await api.getChannels().data
                tableView.reloadData()
            } catch {
                print(error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        channels.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let index = tableView.indexPathForSelectedRow?.item {
            let vc = segue.destination as! ChatViewController
            vc.channel = channels[index]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let item = channels[indexPath.item]
        if let url = URL(string: item.partner.avatarUrl) {
            imageLoader.cancel(for: url)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChannelCell", for: indexPath) as! ChannelCell
        let item = channels[indexPath.item]
        cell.name.text = item.partner.fullname
        cell.message.text = item.messageLast?.content.text
        cell.time.text = item.messageLast?.dtaCreate.asDate?.timeText
        let isOwn = item.messageLast?.isOwn ?? false
        cell.readStatus.isHidden = !isOwn
        
        let isRead = item.messageLast?.isRead ?? false
        let icon = isRead ? "baseline_done_all_black_18pt" : "baseline_done_black_18pt"
        cell.readStatus?.image = UIImage(named: icon)?.withRenderingMode(.alwaysTemplate)
        
        cell.avatar.image = nil
        cell.channelId = item.id
        
        if let url = URL(string: item.partner.avatarUrl) {
            imageLoader.load(url: url, id: item.id) { id, image in
                if cell.channelId == id {
                    cell.avatar.image = image
                }
            }
        }
        return cell
    }
}
