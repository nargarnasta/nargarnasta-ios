// swiftlint:disable force_unwrapping
import CoreLocation
@testable import NarGarNasta

extension CLError.Code: Error {}

class CLLocationManagerDouble: CLLocationManagerProtocol {
  weak var delegate: CLLocationManagerDelegate?
  var authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
  var desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest
  var willAuthorizeForWhenInUseUsage = true
  var nextLocation: CLLocation?
  private(set) var didRequestLocationWhenNotAuthorized = false

  func requestWhenInUseAuthorization() {
    guard authorizationStatus == .notDetermined else {
      return
    }

    DispatchQueue.main.async {
      if self.willAuthorizeForWhenInUseUsage {
        self.authorizationStatus = .authorizedWhenInUse
        self.delegate?.locationManager!(
          CLLocationManager(),
          didChangeAuthorization: .authorizedWhenInUse
        )
      } else {
        self.authorizationStatus = .denied
        self.delegate?.locationManager!(
          CLLocationManager(),
          didChangeAuthorization: .denied
        )
      }
    }
  }

  func requestLocation() {
    guard authorizationStatus == .authorizedWhenInUse else {
      didRequestLocationWhenNotAuthorized = true
      return
    }

    DispatchQueue.main.async {
      if let nextLocation = self.nextLocation {
        self.delegate?.locationManager!(
          CLLocationManager(),
          didUpdateLocations: [nextLocation]
        )
      } else {
        self.delegate?.locationManager!(
          CLLocationManager(),
          didFailWithError: CLError.locationUnknown
        )
      }
    }
  }
}
