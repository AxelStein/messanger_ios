//
//  ChannelApi.swift
//  Messenger
//
//  Created by Александр Шерий on 19.12.2022.
//

import Foundation

class ChannelApi: Api {
    private let host = "https://api.udimi.com/"
    
    func getChannels() async throws -> ResponseChannels {
        return try await fetch(
            buildRequest(
                host: host,
                endpoint: "v1/memberarea/chat/channels/list",
                method: "GET",
                body: nil
            )
        )
    }
}
