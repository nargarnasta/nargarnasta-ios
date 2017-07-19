import Quick
import Nimble
@testable import NarGarNasta

class UpcomingTripsSpec: QuickSpec { override func spec() {

func buildTrip(departure: Date, arrival: Date) -> Trip {
  return Trip(departureTime: departure, arrivalTime: arrival)
}

describe("UpcomingTrips") {
  describe("init(origin:destination:tripSearcher:tripsUpdatedHandler:)") {
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

      let trips = [
        buildTrip(departure: Date(), arrival: Date().addingTimeInterval(60))
      ]
      tripSearcher.nextResult = trips

      var subject: UpcomingTrips?
      waitUntil { done in
        subject = UpcomingTrips(
          origin: origin,
          destination: destination,
          tripSearcher: tripSearcher
        ) {
          done()
        }
      }

      expect(subject?.trips).to(equal(trips))
    }
  }

  describe("update()") {
    it("updates trips to only include future ones") {
      let origin = Location.testLocationA
      let destination = Location.testLocationB
      let tripSearcher = TripSearcherDouble()

      let futureTrips = [
        buildTrip(
          departure: Date().addingTimeInterval(60),
          arrival: Date().addingTimeInterval(180)
        )
      ]
      let trips = [
        buildTrip(
          departure: Date().addingTimeInterval(-180),
          arrival: Date().addingTimeInterval(-60)
        )
      ] + futureTrips
      tripSearcher.nextResult = trips
      var subject: UpcomingTrips?
      waitUntil { done in
        subject = UpcomingTrips(
          origin: origin,
          destination: destination,
          tripSearcher: tripSearcher
        ) {
          subject?.tripsUpdatedHandler = {}
          done()
        }
      }

      subject?.update()

      expect(subject?.trips).to(equal(futureTrips))
    }

    it("populates new trips from search when trips are passed and removed") {
      let origin = Location.testLocationA
      let destination = Location.testLocationB
      let tripSearcher = TripSearcherDouble()

      tripSearcher.nextResult = [
        buildTrip(
          departure: Date().addingTimeInterval(-180),
          arrival: Date().addingTimeInterval(-60)
        ),
        buildTrip(
          departure: Date().addingTimeInterval(60),
          arrival: Date().addingTimeInterval(180)
        )
      ]
      var subject: UpcomingTrips?
      waitUntil { done in
        subject = UpcomingTrips(
          origin: origin,
          destination: destination,
          tripSearcher: tripSearcher
        ) {
          subject?.tripsUpdatedHandler = {}
          done()
        }
      }
      let trips = [
        buildTrip(
          departure: Date().addingTimeInterval(60),
          arrival: Date().addingTimeInterval(180)
        ),
        buildTrip(
          departure: Date().addingTimeInterval(180),
          arrival: Date().addingTimeInterval(300)
        )
      ]
      tripSearcher.nextResult = trips

      subject?.update()

      waitUntil { done in
        if let updatedTrips = subject?.trips, updatedTrips == trips {
          done ()
        }
      }

      expect(subject?.trips).to(equal(trips))
    }
  }
}

} }
