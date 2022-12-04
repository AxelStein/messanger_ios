//
//  ChatInfo.swift
//  Messenger
//
//  Created by Александр Шерий on 19.12.2022.
//

import Foundation

struct ChatInfo: Codable {
    let data: Data
    
    struct Data: Codable {
        let partner: Partner
        let channel: Channel?
    }
}

struct Partner: Codable {
    let id: Int64
    let uid: String
    let fullname: String
    let avatarUrl: String
    let isOnline: Bool
    let dtaLastSeen: String
}

struct Channel: Codable {
    let id: Int64
    let cntUnread: Int
    let partner: Partner
    let messageLast: Message.Data?
}

struct ResponseChannels: Codable {
    let data: [Channel]
}

struct Message: Codable {
    let data: Data

    struct Data: Codable {
        let id: Int64
        let idUserAuthor: Int64
        let idChannel: Int64
        let dtaCreate: String
        let isEdited: Bool
        let isRead: Bool
        let isOwn: Bool
        let content: Content
        var group: Group = .none
        var isPending: Bool = false
        var created: Date = Date()
        var time: String = ""
        
        private enum CodingKeys: String, CodingKey {
            case id, idUserAuthor, idChannel, dtaCreate, isEdited, isRead, isOwn, content
        }
    }
    
    enum Group {
        case start
        case body
        case end
        case none
    }
    
    struct Content: Codable {
        let text: String?
        let file: File?
        
        struct File: Codable {
            let urlForDownload: String
            let mimeType: String
            let clientExtension: String
            let clientOriginalName: String
            let conversionsImages: [String: String]?
            let size: Int64
            let metadata: Metadata?
        }
        
        struct Metadata: Codable {
            let resolution: Resolution?
            let duration: Int64?
            
            struct Resolution: Codable {
                let width: Int
                let height: Int
            }
        }
    }
}

extension Message.Content {
    var isImageFile: Bool {
        guard let file = file else { return false }
        return file.mimeType.starts(with: "image/")
    }
    
    var isVideoFile: Bool {
        guard let file = file else { return false }
        return file.mimeType.starts(with: "video/")
    }
}

struct ChatHistory: Codable {
    let data: [Message.Data]
    let links: Links
    
    struct Links: Codable {
        let first: String?
        let last: String?
        let prev: String?
        let next: String?
    }
}
