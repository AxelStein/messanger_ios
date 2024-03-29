//
//  ChatViewController.swift
//  Messenger
//
//  Created by Александр Шерий on 15.12.2022.
//

import UIKit
import ReverseExtension
import AVFoundation

class ChatViewController: UIViewController {    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var messageInputContainer: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var fabScrollDown: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeholder: UILabel!
    @IBOutlet weak var unreadCount: UILabel!
    @IBOutlet weak var sendMessageButton: UIImageView!
    @IBOutlet weak var messageInputContainerBottom: NSLayoutConstraint!
    @IBOutlet weak var audioPlayerContainer: AudioPlayerContainer!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var audioPlayerContainerHeight: NSLayoutConstraint!
    
    var channel: Channel!
    var items = [Item]()
    var links = ChatHistory.Links(first: nil, last: nil, prev: nil, next: nil)
    private let api = ChatApi()
    private var audioPlayer: AVPlayer? = nil
    private var isLoadingHistory = false
    
    override func viewDidLoad() {
        let title = UILabel()
        title.text = channel.partner.fullname
        title.font = .systemFont(ofSize: 16, weight: .semibold)
        title.sizeToFit()
        
        let subtitle = UILabel()
        if channel.partner.isOnline {
            subtitle.text = "online"
            subtitle.textColor = .systemBlue
        } else {
            subtitle.text = "last seen \(formatPartnerLastSeenDate(dateStr: channel.partner.dtaLastSeen))"
            subtitle.textColor = .secondaryLabel
        }
        subtitle.font = .systemFont(ofSize: 14, weight: .regular)
        subtitle.sizeToFit()
        
        let stack = UIStackView(arrangedSubviews: [title, subtitle])
        stack.axis = .vertical
        stack.alignment = .center
        stack.sizeToFit()
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationItem.scrollEdgeAppearance = appearance
        /*
        navigationController?.navigationBar.scrollEdgeAppearance = UINavigationBarAppearance(barAppearance: UIBarAppearance(idiom: .phone))
        */
        // navigationController?.navigationBar.isTranslucent = true
        navigationItem.titleView = stack
        
        if let url = URL(string: channel.partner.avatarUrl) {
            imageLoader.load(url: url, id: channel.id) { id, image in
                self.setAvatartImage(image)
            }
        } else {
            let partnerName = channel.partner.fullname.prefix(2)
            self.setAvatartImage(imageWith(name: partnerName.uppercased(), size: CGSize(width: 56, height: 56)))
        }
        
        // tableView.backgroundColor = UIColor.init(named: "chat_bg")
        tableView.re.dataSource = self
        tableView.re.delegate = self
        tableView.prefetchDataSource = self
        tableView.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 6, right: 0)
        
        let cellNames = [
            "MessageCell",
            "ChatOwnFileCell",
            "ChatPartnerFileCell",
            "ChatOwnTextCell",
            "ChatPartnerTextCell",
            "ChatOwnImageCell",
            "ChatPartnerImageCell",
            "ChatOwnImageTextCell",
            "ChatPartnerImageTextCell",
            "ChatOwnAudioCell",
            "ChatPartnerAudioCell",
            "ChatOwnVideoCell",
            "ChatDateCell",
        ]
        cellNames.forEach {
            registerTableViewCell(name: $0)
        }
        
        messageTextView.adjustHeight()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        messageTextView.delegate = self
        
        sendMessageButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSendMessageClick)))
        fabScrollDown.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(scrollDown)))
        
        audioPlayerContainer.heightConstraint = audioPlayerContainerHeight
        initChat()
    }
    
    private func setAvatartImage(_ image: UIImage?) {
        let size = CGFloat(36)
        let resized = image?.resizedCircle(to: CGSize(width: size, height: size)).withRenderingMode(.alwaysOriginal)
        let item = UIBarButtonItem(image: resized, style: .plain, target: nil, action: nil)
        item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -8)
        self.navigationItem.rightBarButtonItem = item
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioPlayerContainer.release()
    }
    
    private func registerTableViewCell(name: String) {
        tableView.register(UINib(nibName: name, bundle: nil), forCellReuseIdentifier: name)
    }
    
    private func initChat() {
        activityIndicator.startAnimating()
        
        Task {
            do {
                let chatInfo = try await api.initChat(partnerUid: channel.partner.uid)
                if let channelId = chatInfo.data.channel?.id {
                    fetchHistory(channelId: channelId)
                }
            } catch {
                print(error)
                activityIndicator.stopAnimating()
            }
        }
    }
    
    func fetchHistory(channelId: Int64, cursor: String? = nil) {
        if isLoadingHistory {
            return
        }

        isLoadingHistory = true
        activityIndicator.startAnimating()
        
        Task {
            do {
                let history = try await api.getChatHistory(channelId: channelId, cursor: cursor)
                links = history.links
                
                processHistoryItems(items: items, history: history, cursor: cursor) { it in
                    self.items = it
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.isLoadingHistory = false
                }
            } catch {
                print(error)
                isLoadingHistory = false
                activityIndicator.stopAnimating()
            }
        }
    }
    
    private func processHistoryItems(items: [Item], history: ChatHistory, cursor: String?, completion: @escaping ([Item]) -> Void) {
        DispatchQueue.global().async {
            var newItems = items.filter { !($0 is DateItem) }
            if cursor != nil {
                newItems.insert(contentsOf: history.data.map { MessageItem(data: $0) }, at: 0)
            } else {
                newItems = history.data.map { MessageItem(data: $0) }
            }
            newItems.sort { a, b in
                if let a = a as? MessageItem, let b = b as? MessageItem {
                    return a.data.created < b.data.created
                }
                return false
            }
            let groupedItems = self.groupMessages(items: newItems)
            DispatchQueue.main.async {
                completion(groupedItems)
            }
        }
    }
    
    private func lastItemIndexPath() -> IndexPath {
        return IndexPath(item: items.count - 1, section: 0)
    }
    
    private func formatPartnerLastSeenDate(dateStr: String) -> String {
        guard let date = dateStr.asDate else { return "" }
        if Calendar.current.isDateInToday(date) {
            return "at \(date.timeText)"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM"
            let dayMonth = formatter.string(from: date)
            return "\(dayMonth) at \(date.timeText)"
        }
    }
    
    private func groupMessages(items: [Item]) -> [Item] {
        var key: Int64 = 0
        let interval: Int64 = 5 * 60 * 1000
        var isGroup = false
        let messages = items.filter {
            $0 is MessageItem
        }.map { ($0 as! MessageItem).data }
        
        var newItems = [Item]()
        var currentDate = ""
        
        for i in 0..<messages.count {
            var message = messages[i]
            let nextIndex = i + 1
            var nextMessage: Message.Data? = nil
            if nextIndex < messages.count {
                nextMessage = messages[nextIndex]
            }
            let date = message.created.millis
            let dateStr = message.created.monthDayText
            if currentDate != dateStr {
                currentDate = dateStr
                newItems.append(DateItem(data: dateStr))
            }
            
            let nextDate = nextMessage?.dtaCreate.asDate?.millis ?? Int64.max
            if key == 0 {
                key = date
            }
            if abs(key - date) <= interval {
                let nextIsOwn = nextMessage?.isOwn == message.isOwn
                let nextInInterval = nextIsOwn && abs(key - nextDate) <= interval
                if isGroup {
                    if nextInInterval {
                        message.group = .body
                    } else {
                        isGroup = false
                        key = nextDate
                        message.group = .end
                    }
                } else {
                    if nextInInterval {
                        isGroup = true
                        message.group = .start
                    } else {
                        key = nextDate
                        message.group = .none
                    }
                }
            } else {
                key = date
            }
            
            newItems.append(MessageItem(data: message))
        }
        
        return newItems
    }
    
    func appendMessage(_ message: Message.Data) -> UUID {
        let item = MessageItem(data: message)
        guard let date = message.dtaCreate.asDate?.monthDayText else { return item.id }
        if !items.contains(where: { ($0 as? DateItem)?.data == date }) {
            items.append(DateItem(data: date))
        }
        items.append(item)
        return item.id
    }
    
    @objc func onSendMessageClick(_ sender: Any) {
        guard var text = messageTextView.text else { return }
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty {
            return
        }
        /*
        let message = Message(text: text, isOwn: true)
        message.isPending = true
        let id = appendMessage(message)

        self.groupMessages()
        self.tableView.reloadData()
        updateTableContentInset()
        
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(2))) {
            DispatchQueue.main.async {
                let it = self.items.first {
                    ($0 as? MessageItem)?.id == id
                }
                if let it = it as? MessageItem {
                    it.data.isRead = true
                    it.data.isPending = false
                    self.groupMessages()
                    self.tableView.reloadData()
                }
            }
        }
        
        tableView.reloadData()
        messageTextView.text = ""
        placeholder.isHidden = false
        messageTextView.adjustHeight()
        
        scrollDown(sender)
        */
    }
    
    @objc func scrollDown(_ sender: Any) {
        if !items.isEmpty {
            tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .bottom, animated: true)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let keyboardFrame = keyboardSize.cgRectValue
        let keyboardHeight = keyboardFrame.height
        
        var bottomPadding = CGFloat(0)
        if let window = UIApplication.shared.windows.first {
            bottomPadding = window.safeAreaInsets.bottom
        }
        
        messageInputContainerBottom.constant = keyboardHeight - bottomPadding
        contentView.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        messageInputContainerBottom.constant = 0
        contentView.layoutIfNeeded()
    }
}

extension ChatViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        let text = textView.text ?? ""
        placeholder.isHidden = !text.isEmpty
        textView.adjustHeight()
    }
}

extension ChatViewController: ChatAudioCellDelegate {
    func onPlayClick(message: Message.Data) {
        audioPlayerContainer.setCurrent(message: message)
    }
}

protocol Item {}

struct MessageItem: Item {
    let id = UUID()
    var data: Message.Data
}

struct DateItem: Item {
    var data: String
}
