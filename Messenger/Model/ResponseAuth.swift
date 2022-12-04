//
//  ResponseAuth.swift
//  Messenger
//
//  Created by Александр Шерий on 19.12.2022.
//

import Foundation

struct ResponseAuth: Codable {
    let error: ApiError
    let data: Data
    
    struct Data: Codable {
        let id: String?
        let name: String?
        let code: String?
        let avatar: String?
    }
}

struct ApiError: Codable {
    let type: String?
    let message: String?
    let code: Int
}
