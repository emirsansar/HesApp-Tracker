import Foundation
import SwiftData

@Model
class UserSubscription {
    
    var serviceName: String
    var planName: String
    var planPrice: Double
    var personCount: Int
    
    init (serviceName: String, planName: String, planPrice: Double, personCount: Int) {
        self.serviceName = serviceName
        self.planName = planName
        self.planPrice = planPrice
        self.personCount = personCount
    }
}
