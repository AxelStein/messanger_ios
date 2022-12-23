//
//  ChatVideoCell.swift
//  Messenger
//
//  Created by Александр Шерий on 22.12.2022.
//

import UIKit
import AVFoundation

class VideoPlayer {
    let player: AVQueuePlayer
    let layer: AVPlayerLayer
    let looper: AVPlayerLooper
    
    init(url: URL) {
        let token = UserDefaults.standard.string(forKey: DefaultsKeys.authToken) ?? ""
        let headers = ["Authorization" : "Bearer \(token)"]
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey" : headers])
        let item = AVPlayerItem(asset: asset)
        
        self.player = AVQueuePlayer(playerItem: item)
        self.player.isMuted = true
        
        self.layer = AVPlayerLayer(player: player)
        self.looper = AVPlayerLooper(player: player, templateItem: item)
    }
    
    deinit {
        print("VideoPlayer deinit")
        player.replaceCurrentItem(with: nil)
        layer.removeFromSuperlayer()
    }
}

class ChatVideoCell: UITableViewCell, ChatCell {
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var playTimeLabel: UILabel!
    @IBOutlet weak var placeholderView: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var readStatusView: UIImageView?
    @IBOutlet weak var playView: UIImageView!
    
    private var message: Message.Data? = nil
    private var videoPlayer: VideoPlayer? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        videoView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onVideoClick)))
    }
    
    @objc func onVideoClick(_ sender: Any) {
        if let message = message {
            self.playView.isHidden = true
            playVideo(message)
        }
    }
    
    func setMessage(_ message: Message.Data) {
        self.message = message
        self.placeholderView.image = nil
        self.playView.isHidden = false
        
        var width = -1
        var height = -1
        if let resolution = message.content.file?.metadata?.resolution {
            var frame = self.videoView.frame
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
            
            self.videoView.translatesAutoresizingMaskIntoConstraints = true
            self.videoView.frame = frame
            
            self.placeholderView.translatesAutoresizingMaskIntoConstraints = true
            self.placeholderView.frame = frame
        }
        
        timeLabel.text = message.time
        
        let iconName = message.isRead ? "baseline_done_all_black_18pt" : "baseline_done_black_18pt"
        readStatusView?.image = UIImage(named: iconName)?.withRenderingMode(.alwaysTemplate)
        
        if let thumbURL = message.content.thumbBigURL, imageLoader.contains(url: thumbURL, conversion: "thumb_big") {
            self.loadImage(message, key: "thumb_big", width: width, height: height) {}
        } else {
            loadImage(message, key: "tiny_placeholder", width: width, height: height) {
                self.loadImage(message, key: "thumb_big", width: width, height: height) {}
            }
        }
        set(visible: false)
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
        guard let cellId = self.message?.id else { return }
        imageLoader.load(url: url, id: cellId, conversion: key, width: width, height: height) { id, image in
            if self.message?.id == id {
                self.placeholderView.image = image
                completion()
            }
        }
    }
    
    func set(visible: Bool) {
        if !visible {
            self.playView.isHidden = false
            if videoPlayer != nil {
                videoPlayer = nil
            }
        }
        /*
        if let message = message {
            if visible {
                // playVideo(message)
            } else if videoPlayer != nil {
                videoPlayer = nil
            }
        }
        */
    }
    
    private func playVideo(_ message: Message.Data) {
        guard let path = message.content.file?.urlForDownload else { return }
        guard let url = URL(string: path) else { return }
        if videoPlayer != nil {
            return
        }
        let vp = VideoPlayer(url: url)
        vp.layer.frame = self.videoView.bounds
        vp.layer.videoGravity = .resizeAspect
        self.videoView.layer.addSublayer(vp.layer)
        vp.player.play()
        videoPlayer = vp
    }
    
    deinit {
        videoPlayer = nil
    }
}
