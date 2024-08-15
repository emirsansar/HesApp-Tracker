import Foundation
import SwiftData

@Model
class User {
    
    var email: String
    var fullName: String
    var subscriptionCount: Int
    var monthlySpend: Double

    init (email: String, fullName: String, subscriptionCount: Int, monthlySpend: Double) {
        self.email = email
        self.fullName = fullName
        self.subscriptionCount = subscriptionCount
        self.monthlySpend = monthlySpend
    }
    
}
