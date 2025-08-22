//
//  Environment+dbRepo.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 09/08/2025.
//

import SwiftUI

extension EnvironmentValues {

    var dbRepo: DatabaseRepository {
        get { self[DatabaseRepoKey.self] }
        set { self[DatabaseRepoKey.self] = newValue }
    }
}

struct DatabaseRepoKey: EnvironmentKey {
    static let defaultValue: any DatabaseRepository = FirestoreRepo()
}

