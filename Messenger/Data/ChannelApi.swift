//
//  ChannelApi.swift
//  Messenger
//
//  Created by Александр Шерий on 19.12.2022.
//

import Foundation

class ChannelApi: Api {
    private let host = "https://api.udimi.com/"
    
    func getChannels() async throws -> [Channel] {
        let res: ResponseChannels = try await fetch(
            buildRequest(
                host: host,
                endpoint: "v1/memberarea/chat/channels/list",
                method: "GET",
                body: nil
            )
        )
        let channels = res.data
        return channels.map {
            var it = $0
            it.created = it.messageLast?.dtaCreate.asDate ?? Date()
            it.time = it.created.timeText
            if Calendar.current.isDateInToday(it.created) {
                it.time = it.created.timeText
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM d"
                it.time = formatter.string(from: it.created)
            }
            return it
        }
    }
}
