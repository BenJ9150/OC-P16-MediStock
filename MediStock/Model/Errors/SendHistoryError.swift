//
//  SendHistoryError.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 10/10/2025.
//

import Foundation

protocol HistoryError {
    var error: String { get }
}

/// History error for medicine details
struct SendHistoryError: HistoryError {

    let error: String
    let action: String
    let details: String

    init(error: String, action: String, details: String) {
        self.error = error
        self.action = action
        self.details = details
    }
}

/// History error when add new medicine
struct NewMedicineHistoryError: HistoryError {

    let user: AuthUser
    let medicineId: String
    let medicineName: String
    let error: String

    init(user: AuthUser, medicineId: String, medicineName: String, error: String) {
        self.user = user
        self.medicineId = medicineId
        self.medicineName = medicineName
        self.error = error
    }
}
