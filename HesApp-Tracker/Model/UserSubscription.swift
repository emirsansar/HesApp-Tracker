import Foundation

struct UserSubscription: Identifiable {
    var id = UUID()
    var serviceName: String
    var plan: Plan
    var personCount: Int
}
