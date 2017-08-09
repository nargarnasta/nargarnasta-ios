import Foundation
import CoreLocation

enum LocationError: Error {
  case parametersMissing
}

struct Location: Equatable {
  // MARK: - Properties

  let id: String
  let name: String
  let geolocation: CLLocation

  // MARK: - Initializers

  init(id: String, name: String, geolocation: CLLocation) {
    self.id = id
    self.name = name
    self.geolocation = geolocation
  }

  init(resrobotLocation: ResrobotLocation) {
    self.id = resrobotLocation.id
    self.name = resrobotLocation.name
    self.geolocation = Location.clLocationFrom(
      latitude: resrobotLocation.latitude,
      longitude: resrobotLocation.longitude
    )
  }

  // MARK: - Dictionary coding

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
    self.geolocation = Location.clLocationFrom(
      latitude: latitude.doubleValue,
      longitude: longitude.doubleValue
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

  // MARK: - Internal translation

  private static func clLocationFrom(latitude: Double, longitude: Double) -> CLLocation {
    return CLLocation(
      latitude: CLLocationDegrees(exactly: latitude) ?? 0,
      longitude: CLLocationDegrees(exactly: longitude) ?? 0
    )
  }

  // MARK: - Equatable

  static func ==(lhs: Location, rhs: Location) -> Bool {
    return lhs.id == rhs.id
  }
}
