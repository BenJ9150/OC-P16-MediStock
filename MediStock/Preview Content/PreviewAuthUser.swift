//
//  PreviewAuthUser.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 08/08/2025.
//

import Foundation

class PreviewAuthUser: AuthUser {

    var uid: String
    var email: String?
    var displayName: String?

    init(uid: String, email: String?, displayName: String?) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
    }
}
