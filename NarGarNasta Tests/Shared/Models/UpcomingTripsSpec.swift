import Quick
import Nimble
@testable import NarGarNasta

class UpcomingTripsSpec: QuickSpec { override func spec() {

describe("UpcomingTrips") {
  describe("init(itinerary:searchCompleted:tripSearcher:)") {
    it("sets locations") {
      let origin = Location.testLocationA
      let destination = Location.testLocationB

      let subject = UpcomingTrips(
        origin: origin,
        destination: destination,
        tripSearcher: TripSearcherDouble()
      ) { }

      expect(subject.origin).to(equal(origin))
      expect(subject.destination).to(equal(destination))
    }

    it("searches for trips with location 1 as origin & 2 as destination") {
      let origin = Location.testLocationA
      let destination = Location.testLocationB
      let tripSearcher = TripSearcherDouble()

      let _ = UpcomingTrips(
        origin: origin,
        destination: destination,
        tripSearcher: tripSearcher
      ) { }

      expect(tripSearcher.lastSearch?.origin).to(equal(origin))
      expect(tripSearcher.lastSearch?.destination).to(equal(destination))
    }

    it("sets result from trip searcher") {
      let origin = Location.testLocationA
      let destination = Location.testLocationB
      let tripSearcher = TripSearcherDouble()

      let trip: Trip
      do {
        trip = try Trip(jsonObject: [
          "departure_time": "2017-02-14T14:00:00Z",
          "arrival_time": "2017-02-14T14:10:00Z"
        ])
      } catch { fail(); return }
      let trips = [trip]
      tripSearcher.nextResult = trips

      let subject = UpcomingTrips(
        origin: origin,
        destination: destination,
        tripSearcher: tripSearcher
      ) { }

      expect(subject.trips).to(equal(trips))
    }
  }
}

} }
