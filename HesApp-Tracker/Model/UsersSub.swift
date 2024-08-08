import Foundation

struct UsersSub: Identifiable {
    var id = UUID()
    var serviceName: String
    var plan: Plan
    var personCount: Int
}
