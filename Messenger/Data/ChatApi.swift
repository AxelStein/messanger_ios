//
//  ChatApi.swift
//  Messenger
//
//  Created by Александр Шерий on 19.12.2022.
//

import Foundation

class ChatApi: Api {
    private let host = "https://api.udimi.com/"
    
    func initChat(partnerUid: String) async throws -> ChatInfo {
        return try await fetch(
            buildRequest(
                host: host,
                endpoint: "v1/memberarea/chat/general/init-pm-chat/\(partnerUid)",
                method: "GET",
                body: nil
            )
        )
    }
    
    func getChatHistory(channelId: Int64, cursor: String? = nil) async throws -> ChatHistory {
        let history: ChatHistory
        if cursor == nil {
            history = try await fetch(
                buildRequest(
                    host: host,
                    endpoint: "v1/memberarea/chat/messages/list/\(channelId)",
                    method: "GET",
                    body: nil
                )
            )
        } else {
            history = try await fetch(
                buildRequest(
                    path: cursor!,
                    method: "GET",
                    body: nil
                )
            )
        }
        return ChatHistory(
            data: history.data.map {
                var it = $0
                it.created = it.dtaCreate.asDate ?? Date()
                it.time = it.created.timeText
                return it
            },
            links: history.links
        )
    }
}
