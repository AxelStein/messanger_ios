//
//  LoginApi.swift
//  Messenger
//
//  Created by Александр Шерий on 19.12.2022.
//

import Foundation

class LoginApi: Api {
    func login(email: String, password: String) async throws -> ResponseAuth {
        try await fetch(
            buildRequest(
                host: "https://udimi.com/api/",
                endpoint: "login",
                method: "POST",
                body: ["login": email, "password": password]
            )
        )
    }
}
