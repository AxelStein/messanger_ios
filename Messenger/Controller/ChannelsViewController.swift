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
                channels = try await api.getChannels()
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
        cell.setChannel(channels[indexPath.item])
        return cell
    }
}
