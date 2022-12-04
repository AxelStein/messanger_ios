//
//  Api.swift
//  Messenger
//
//  Created by Александр Шерий on 17.12.2022.
//

import Foundation

class Api {
    
    internal let decoder = JSONDecoder()
    
    init() {
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    private func getAuthToken() -> String? {
        return UserDefaults.standard.string(forKey: DefaultsKeys.authToken)
    }
    
    func action(_ request: URLRequest) async throws {
        try await URLSession.shared.data(for: request)
    }
    
    func fetch<T: Codable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        // print(data.asString)
        return try decoder.decode(T.self, from: data)
    }
    
    func buildRequest(
        path: String,
        method: String,
        body: [String: Any?]? = nil
    ) -> URLRequest {
        let url = URL(string: path)
        let token = getAuthToken()
        
        var request = URLRequest(url: url!)
        if let token = token {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("*/*", forHTTPHeaderField: "Accept")
        request.addValue("android", forHTTPHeaderField: "Client-App")
        request.addValue("1", forHTTPHeaderField: "New-Messenger")
        request.addValue("xKhD0cZj0MnQ7KEmIiCE", forHTTPHeaderField: "Api-Key")
        request.addValue("3.2.91_08", forHTTPHeaderField: "App-version")
        
        if let body = body {
            let bodyData = try? JSONSerialization.data(
                withJSONObject: body
            )
            request.httpBody = bodyData
        }
        request.httpMethod = method
        return request
    }
    
    func buildRequest(
        host: String,
        endpoint: String,
        method: String,
        body: [String: Any?]? = nil
    ) -> URLRequest {
        return buildRequest(path: "\(host)\(endpoint)", method: method, body: body)
    }
}

extension URLResponse {
    var isSuccessful: Bool {
        let code = (self as! HTTPURLResponse).statusCode
        return code >= 200 && code < 300
    }
    
    var code: Int {
        return (self as! HTTPURLResponse).statusCode
    }
}

extension Data {
    var asString: String {
        return String(decoding: self, as: UTF8.self)
    }
}
