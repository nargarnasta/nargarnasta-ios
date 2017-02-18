import CoreLocation
@testable import NarGarNasta

extension Location {
  static var testLocationA: Location {
    return Location(id: "1", name: "A", geolocation: CLLocation(
      latitude: 59.356,
      longitude: 18.019
    ))
  }

  static var testLocationB: Location {
    return Location(id: "2", name: "B", geolocation: CLLocation(
      latitude: 59.366,
      longitude: 18.033
    ))
  }

  static var testLocationC: Location {
    return Location(id: "3", name: "C", geolocation: CLLocation(
      latitude: 59.376,
      longitude: 18.032
    ))
  }
}
