import Foundation

class UpcomingTrips {
  let origin: Location
  let destination: Location
  let tripSearcher: TripSearcherProtocol
  var tripsUpdatedHandler: () -> Void
  var trips: [Trip]?

  init(
    origin: Location,
    destination: Location,
    tripSearcher: TripSearcherProtocol = TripSearcher(),
    tripsUpdatedHandler: @escaping () -> Void
  ) {
    self.origin = origin
    self.destination = destination
    self.tripSearcher = tripSearcher
    self.tripsUpdatedHandler = tripsUpdatedHandler

    populateFromSearch()
  }

  func update() {
    guard let trips = self.trips else { return }

    let previousTripCount = trips.count

    let firstUpcomingIndex: Int
    if let index = trips.index(where: { $0.departureTime >= Date() }) {
      firstUpcomingIndex = index
    } else {
      firstUpcomingIndex = 0
    }

    self.trips = Array(trips.suffix(from: firstUpcomingIndex))

    if let updatedTrips = self.trips, updatedTrips.count < previousTripCount {
      populateFromSearch()
    }
  }

  private func populateFromSearch() {
    tripSearcher.search(origin: origin, destination: destination) { trips in
      self.trips = trips

      self.tripsUpdatedHandler()
    }
  }
}
