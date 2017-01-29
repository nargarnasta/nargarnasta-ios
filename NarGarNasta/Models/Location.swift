import Foundation

enum LocationError: Error {
    case parametersMissing
}

struct Location {
    let id: String
    let name: String
    
    init(jsonObject: [String: Any]) throws {
        guard let id = jsonObject["id"] as? String, let name = jsonObject["name"] as? String else {
            throw LocationError.parametersMissing
        }
        
        self.id = id
        self.name = name
    }
}
