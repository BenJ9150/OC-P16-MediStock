//
//  AuthUserMock.swift
//  MediStockTests
//
//  Created by Benjamin LEFRANCOIS on 22/08/2025.
//

import Foundation
@testable import MediStock

class AuthUserMock: AuthUser {

    var uid: String
    var email: String?
    var displayName: String?

    init(uid: String, email: String?, displayName: String?) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
    }
}
