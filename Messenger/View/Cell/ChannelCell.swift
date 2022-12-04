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
}
