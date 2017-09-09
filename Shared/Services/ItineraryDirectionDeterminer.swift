import CoreLocation

enum ItineraryDirectionDeterminerError: Error {
  case locationUsageDenied, locationUnknown
}

class ItineraryDirectionDeterminer: NSObject, CLLocationManagerDelegate {
  let locationManager: CLLocationManagerProtocol
  let itinerary: Itinerary
  private var completionHandler: ((_ origin: Location, _ destination: Location) -> Void)?
  private var errorHandler: ((_ error: ItineraryDirectionDeterminerError) -> Void)?

  init(
    itinerary: Itinerary,
    locationManager: CLLocationManagerProtocol = CLLocationManager()
  ) {
    self.itinerary = itinerary
    self.locationManager = locationManager

    super.init()

    self.locationManager.delegate = self
    self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
  }

  func determineBestDirection(
    completion: @escaping (_ origin: Location, _ destination: Location) -> Void,
    error: @escaping (_ error: ItineraryDirectionDeterminerError) -> Void
  ) {
    self.completionHandler = completion
    self.errorHandler = error
    switch locationManager.authorizationStatus {
    case .authorizedWhenInUse:
      locationManager.requestLocation()
    case .notDetermined:
      locationManager.requestWhenInUseAuthorization()
    default:
      errorHandler?(.locationUsageDenied)
    }
  }

  private func completeBestDirectionDetermination(location: CLLocation) {
    let distanceToLocation1 =
      location.distance(from: itinerary.destinationA.geolocation)
    let distanceToLocation2 =
      location.distance(from: itinerary.destinationB.geolocation)

    if distanceToLocation1 < distanceToLocation2 {
      completionHandler?(itinerary.destinationA, itinerary.destinationB)
    } else {
      completionHandler?(itinerary.destinationB, itinerary.destinationA)
    }
  }

  // MARK: - CLLocationManagerDelegate

  func locationManager(
    _ manager: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    guard let location = locations.last else { return }
    completeBestDirectionDetermination(location: location)
  }

  func locationManager(
    _ manager: CLLocationManager,
    didFailWithError error: Error
  ) {
    if error._code == CLError.locationUnknown.rawValue {
      errorHandler?(.locationUnknown)
    }
  }

  func locationManager(
    _ manager: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    if status == .authorizedWhenInUse {
      locationManager.requestLocation()
    } else {
      errorHandler?(.locationUsageDenied)
    }
  }
}
