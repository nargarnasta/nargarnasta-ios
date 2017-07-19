import Foundation

protocol TripSearcherProtocol: class {
  func search(
    origin: Location,
    destination: Location,
    completion: @escaping ([Trip]) -> Void
  )
}

class TripSearcher: TripSearcherProtocol {
  func search(
    origin: Location,
    destination: Location,
    completion: @escaping ([Trip]) -> Void
  ) {
    Trip.search(from: origin, to: destination) { trips in
      completion(trips)
    }
  }
}
