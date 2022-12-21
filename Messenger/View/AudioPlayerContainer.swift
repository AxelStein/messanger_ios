//
//  AudioPlayerContainer.swift
//  Messenger
//
//  Created by Александр Шерий on 21.12.2022.
//

import UIKit
import AVFoundation

class AudioPlayerContainer: UIView {
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var playButton: UIImageView!
    @IBOutlet weak var closeButton: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    var heightConstraint: NSLayoutConstraint? = nil
    private var audioPlayer: AVPlayer? = nil
    private var timeObserver: Any? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        Bundle.main.loadNibNamed("AudioPlayerContainer", owner: self)
        addSubview(contentView)
        
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.translatesAutoresizingMaskIntoConstraints = true
        
        playButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(togglePlay))
        )
        closeButton.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onCloseClick))
        )
    }
    
    @objc func togglePlay(_ sender: Any) {
        guard let audioPlayer = audioPlayer else {
            return
        }
        
        switch audioPlayer.timeControlStatus {
            case .playing:
                playButton.image = UIImage(systemName: "play.fill")
                audioPlayer.pause()
            case .paused:
                playButton.image = UIImage(systemName: "pause.fill")
                audioPlayer.play()
            case .waitingToPlayAtSpecifiedRate: break
            default: break
        }
    }
    
    @objc func onCloseClick(_ sender: Any) {
        release()
        heightConstraint?.constant = 0
        layoutIfNeeded()
    }
    
    func setCurrent(message: Message.Data) {
        guard let path = message.content.file?.urlForDownload else { return }
        guard let url = URL(string: path) else { return }
        guard let file = message.content.file else { return }
        
        heightConstraint?.constant = 56
        layoutIfNeeded()
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        
        let token = UserDefaults.standard.string(forKey: DefaultsKeys.authToken) ?? ""
        let headers = ["Authorization" : "Bearer \(token)"]
        let asset = AVURLAsset(url: url, options: ["AVURLAssetHTTPHeaderFieldsKey" : headers])
        let item = AVPlayerItem(asset: asset)
        
        if let timeObserver = timeObserver {
            audioPlayer?.removeTimeObserver(timeObserver)
        }
        if let audioPlayer = audioPlayer {
            audioPlayer.pause()
            audioPlayer.replaceCurrentItem(with: item)
        } else {
            audioPlayer = AVPlayer(playerItem: item)
        }
        
        titleLabel.text = file.clientOriginalName
        
        let duration = file.metadata?.duration ?? 0
        let total = formatAudioDuration(millis: duration)
        progressLabel.text = "0:00 / \(total)"
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))

        timeObserver = audioPlayer?.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            let current = formatAudioDuration(seconds: Int(time.seconds))
            self?.progressLabel.text = "\(current) / \(total)"
            
            let totalSeconds = Double(duration / 1000)
            let progress = time.seconds / totalSeconds
            self?.progressView.progress = Float(progress)
        }

        audioPlayer?.volume = 1
        audioPlayer?.play()
        
        /*
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: item
        )
        */
        
        playButton.image = UIImage(systemName: "pause.fill")
        progressView.setProgress(0, animated: false)
    }
    
    /*
    @objc func playerDidFinishPlaying(sender: Notification) {
        
    }
    */
    
    func release() {
        /*
        if let item = audioPlayer?.currentItem {
            NotificationCenter.default.removeObserver(
                self,
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: item
            )
        }
        */
        
        if let timeObserver = timeObserver {
            audioPlayer?.removeTimeObserver(timeObserver)
        }
        audioPlayer?.pause()
        audioPlayer = nil
    }
}
