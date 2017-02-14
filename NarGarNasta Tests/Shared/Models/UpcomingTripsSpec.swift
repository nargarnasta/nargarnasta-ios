import Quick
import Nimble
@testable import NarGarNasta

class UpcomingTripsSpec: QuickSpec { override func spec() {

describe("UpcomingTrips") {
  describe("init(itinerary:searchCompleted:tripSearcher:)") {
    it("sets itinerary") {
      let itinerary = Itinerary(
        location1: Location(id: "1", name: "A"),
        location2: Location(id: "2", name: "B")
      )

      let subject = UpcomingTrips(
        itinerary: itinerary,
        tripSearcher: TripSearcherDouble()
      ) { }

      expect(subject.itinerary).to(equal(itinerary))
    }

    it("searches for trips with location 1 as origin & 2 as destination") {
      let location1 = Location(id: "1", name: "A")
      let location2 = Location(id: "2", name: "B")
      let itinerary = Itinerary(location1: location1, location2: location2)
      let tripSearcher = TripSearcherDouble()

      let _ = UpcomingTrips(
        itinerary: itinerary,
        tripSearcher: tripSearcher
      ) { }

      expect(tripSearcher.lastSearch?.origin).to(equal(location1))
      expect(tripSearcher.lastSearch?.destination).to(equal(location2))
    }

    it("sets result from trip searcher") {
      let itinerary = Itinerary(
        location1: Location(id: "1", name: "A"),
        location2: Location(id: "2", name: "B")
      )
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
        itinerary: itinerary,
        tripSearcher: tripSearcher
      ) { }

      expect(subject.trips).to(equal(trips))
    }
  }
}

} }
