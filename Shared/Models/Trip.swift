import Foundation

enum TripError: Error {
    case parametersMissing
}

struct Trip {
    let departureTime: Date
    let arrivalTime: Date
    
    init(jsonObject: [String: Any]) throws {
        guard let departureTimeString = jsonObject["departure_time"] as? String, let arrivalTimeString = jsonObject["arrival_time"] as? String else {
            throw LocationError.parametersMissing
        }
        
        
        
        self.departureTime = ISO8601DateFormatter().date(from: departureTimeString)!
        self.arrivalTime = ISO8601DateFormatter().date(from: arrivalTimeString)!
    }
}
