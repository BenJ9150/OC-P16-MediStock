//
//  PreviewAuthUser.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 08/08/2025.
//

import Foundation

class PreviewAuthUser: AuthUser {

    static let user: AuthUser = {
        AppFlags.isUITests ? PreviewAuthUser() : PreviewAuthUser(displayName: "Firstname Lastname")
    }()

    var uid: String
    var email: String?
    var displayName: String?

    init(email: String? = "preview@medistock.com", displayName: String? = nil) {
        self.uid = "user_id_mock"
        self.email = email
        self.displayName = displayName
    }
}
