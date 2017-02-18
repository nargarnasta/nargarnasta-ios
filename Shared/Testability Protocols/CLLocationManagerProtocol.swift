import CoreLocation

protocol CLLocationManagerProtocol: class {
  weak var delegate: CLLocationManagerDelegate? { get set }
  var authorizationStatus: CLAuthorizationStatus { get }
  var desiredAccuracy: CLLocationAccuracy { get set }
  func requestWhenInUseAuthorization()
  func requestLocation()
}

extension CLLocationManager: CLLocationManagerProtocol {
  var authorizationStatus: CLAuthorizationStatus {
    return CLLocationManager.authorizationStatus()
  }
}
