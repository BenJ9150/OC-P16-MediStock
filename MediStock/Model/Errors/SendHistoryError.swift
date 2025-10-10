//
//  SendHistoryError.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 10/10/2025.
//

import Foundation

struct SendHistoryError {

    let userId: String
    let medicineId: String
    let medicineName: String
    let error: String
    let action: String
    let details: String

    init(error: String, action: String, details: String) {
        self.userId = ""
        self.medicineId = ""
        self.medicineName = ""
        self.error = error
        self.action = action
        self.details = details
    }

    init(userId: String, medicineId: String, medicineName: String, error: String) {
        self.userId = userId
        self.medicineId = medicineId
        self.medicineName = medicineName
        self.error = error
        self.action = ""
        self.details = ""
    }
}
