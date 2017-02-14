import Foundation

class UpcomingTrips {
  let itinerary: Itinerary
  let tripSearcher: TripSearcherProtocol
  var trips: [Trip]?

  convenience init(
    itinerary: Itinerary,
    searchCompleted: @escaping () -> Void
  ) {
    self.init(
      itinerary: itinerary,
      tripSearcher: TripSearcher(),
      searchCompleted: searchCompleted
    )
  }

  init(
    itinerary: Itinerary,
    tripSearcher: TripSearcherProtocol,
    searchCompleted: @escaping () -> Void
  ) {
    self.itinerary = itinerary
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
      origin: itinerary.location1,
      destination: itinerary.location2
    ) { trips in
      self.trips = trips

      completed()
    }
  }
}
