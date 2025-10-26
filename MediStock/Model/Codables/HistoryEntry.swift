import Foundation
import FirebaseFirestore

struct HistoryEntry: Identifiable, Codable {
    @DocumentID var id: String?
    var medicineId: String
    var aisle: String?
    var user: String
    var userName: String?
    var userEmail: String?
    var action: String
    var details: String
    var timestamp: Date

    init(
        id: String? = nil,
        medicineId: String,
        aisle: String,
        user: AuthUser,
        action: String,
        details: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.medicineId = medicineId
        self.aisle = aisle
        self.user = user.uid
        self.userName = user.displayName
        self.userEmail = user.email
        self.action = action
        self.details = details
        self.timestamp = timestamp
    }
}
