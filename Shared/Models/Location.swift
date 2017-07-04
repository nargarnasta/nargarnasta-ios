import Foundation
import CoreLocation

enum LocationError: Error {
  case parametersMissing
}

struct Location: Equatable {
  let id: String
  let name: String
  let geolocation: CLLocation

  init(id: String, name: String, geolocation: CLLocation) {
    self.id = id
    self.name = name
    self.geolocation = geolocation
  }

  init?(dictionaryRepresentation: [String: Any]) {
    guard
      let id = dictionaryRepresentation["id"] as? String,
      let name = dictionaryRepresentation["name"] as? String,
      let latitude = dictionaryRepresentation["latitude"] as? NSNumber,
      let longitude = dictionaryRepresentation["longitude"] as? NSNumber
    else {
      return nil
    }

    self.id = id
    self.name = name
    self.geolocation = CLLocation(
      latitude: CLLocationDegrees(exactly: latitude) ?? 0,
      longitude: CLLocationDegrees(exactly: longitude) ?? 0
    )
  }

  init(jsonObject: [String: Any]) throws {
    guard
      let id = jsonObject["id"] as? String,
      let name = jsonObject["name"] as? String,
      let latitude = jsonObject["lat"] as? NSNumber,
      let longitude = jsonObject["lon"] as? NSNumber
    else {
      throw LocationError.parametersMissing
    }

    self.id = id
    self.name = name
    self.geolocation = CLLocation(
      latitude: CLLocationDegrees(exactly: latitude) ?? 0,
      longitude: CLLocationDegrees(exactly: longitude) ?? 0
    )
  }

  func dictionaryRepresentation() -> [String: Any] {
    return [
      "id": id,
      "name": name,
      "latitude": NSNumber(value: geolocation.coordinate.latitude),
      "longitude": NSNumber(value: geolocation.coordinate.longitude)
    ]
  }

  static func ==(lhs: Location, rhs: Location) -> Bool {
    return lhs.id == rhs.id
  }
}
