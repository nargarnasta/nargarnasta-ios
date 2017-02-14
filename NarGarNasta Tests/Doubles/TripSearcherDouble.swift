@testable import NarGarNasta

class TripSearcherDouble: TripSearcherProtocol {
  private(set) var lastSearch: (origin: Location, destination: Location)?
  var nextResult: [Trip]?

  func search(
    origin: Location,
    destination: Location,
    completion: @escaping ([Trip]) -> Void
  ) {
    lastSearch = (origin: origin, destination: destination)
    completion(nextResult ?? [])
    nextResult = nil
  }
}
