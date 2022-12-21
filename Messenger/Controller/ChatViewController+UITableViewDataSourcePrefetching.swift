//
//  ChatViewController+UITableViewDataSourcePrefetching.swift
//  Messenger
//
//  Created by Александр Шерий on 21.12.2022.
//

import UIKit

extension ChatViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            if let item = items[$0.item] as? MessageItem,
                let url = item.data.content.tinyPlaceholderURL {
                imageLoader.load(url: url, id: item.data.id, conversion: "tiny_placeholder") { id, image in
                    
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            if let item = items[$0.item] as? MessageItem,
                let url = item.data.content.tinyPlaceholderURL {
                imageLoader.cancel(for: url)
            }
        }
    }
}
