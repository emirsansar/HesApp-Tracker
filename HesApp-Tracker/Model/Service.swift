import Foundation
import SwiftData

@Model
final class Service: Identifiable {

    var serviceName: String
    var serviceType: String
    
    init(serviceName: String, serviceType: String) {
        self.serviceName = serviceName
        self.serviceType = serviceType
    }
    
}
