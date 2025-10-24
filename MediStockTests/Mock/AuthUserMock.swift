//
//  AuthUserMock.swift
//  MediStockTests
//
//  Created by Benjamin LEFRANCOIS on 22/08/2025.
//

import Foundation
@testable import MediStock

class AuthUserMock: AuthUser {

    static let user = AuthUserMock()

    var uid: String
    var email: String?
    var displayName: String?

    init(email: String? = nil, displayName: String? = "user_display_name_mock") {
        self.uid = "user_1"
        self.email = email
        self.displayName = displayName
    }
}
