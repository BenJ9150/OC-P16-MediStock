//
//  RepoSettings.swift
//  MediStock
//
//  Created by Benjamin LEFRANCOIS on 26/09/2025.
//

import Foundation

class RepoSettings {

    func getAuthRepo() -> AuthRepository {
#if DEBUG
        if NSClassFromString("XCTest") != nil {
            return PreviewAuthRepo(isConnected: false)
        }
        if AppFlags.isUITests {
            return PreviewAuthRepo(
                isConnected: !AppFlags.isTestingAuth,
                error: AppFlags.isTestingAuthError
            )
        }
        if ProcessInfo.isPreview {
            return PreviewAuthRepo()
        }
#endif
        return FirebaseAuthRepo()
    }

    func getDbRepo(
        listenError: AppError? = nil,
        updateError: AppError? = nil,
        sendHistoryError: AppError? = nil
    ) -> DatabaseRepository {
#if DEBUG
        if AppFlags.isUITests {
            return PreviewDatabaseRepo(
                listenMedicineError: AppFlags.isTestingListenMedicineError,
                listenHistoryError: AppFlags.isTestingListenHistoryError,
                updateError: AppFlags.isTestingUpdateError,
                sendHistoryError: AppFlags.isTestingSendHistoryError
            )
        }
        if ProcessInfo.isPreview {
            return PreviewDatabaseRepo(
                listenError: listenError,
                updateError: updateError,
                sendHistoryError: sendHistoryError
            )
        }
#endif
        return  FirestoreRepo()
    }
}
