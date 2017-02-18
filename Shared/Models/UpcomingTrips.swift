import Foundation

class UpcomingTrips {
  let origin: Location
  let destination: Location
  let tripSearcher: TripSearcherProtocol
  var trips: [Trip]?

  init(
    origin: Location,
    destination: Location,
    tripSearcher: TripSearcherProtocol = TripSearcher(),
    searchCompleted: @escaping () -> Void
  ) {
    self.origin = origin
    self.destination = destination
    self.tripSearcher = tripSearcher

    populateFromSearch(completed: searchCompleted)
  }

  func removePassedTrips() {
    guard let trips = self.trips else {
      return
    }

    let firstUpcomingIndex: Int
    if let index = trips.index(where: { $0.departureTime >= Date() }) {
      firstUpcomingIndex = index
    } else {
      firstUpcomingIndex = 0
    }

    self.trips = Array(trips.suffix(from: firstUpcomingIndex))
  }

  func populateFromSearch(completed: @escaping () -> Void) {
    tripSearcher.search(
      origin: origin,
      destination: destination
    ) { trips in
      self.trips = trips

      completed()
    }
  }
}
