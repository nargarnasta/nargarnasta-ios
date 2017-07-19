// swiftlint:disable force_unwrapping
import Quick
import Nimble
@testable import NarGarNasta

class TripSpec: QuickSpec { override func spec() {

describe("Trip") {
  describe("search") {
    let responseData = """
      {
        "trips" : [ {
          "departure_time": "2017-02-14T14:00:00Z",
          "arrival_time": "2017-02-14T14:10:00Z"
        }, {
          "departure_time": "2017-02-14T14:05:00Z",
          "arrival_time": "2017-02-14T14:15:00Z"
        } ]
      }
    """.data(using: .utf8)

    it("completes with locations") {
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((responseData, URLResponse(), nil))
      NarGarNastaClient.shared = NarGarNastaClient(urlSession: urlSession)

      var trips: [Trip]?
      waitUntil { done in
        Trip.search(from: Location.testLocationA, to: Location.testLocationB) { returnedTrips in
          trips = returnedTrips
          done()
        }
      }

      expect(trips).to(haveCount(2))
    }

    it("uses correct resource name") {
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((responseData, URLResponse(), nil))
      NarGarNastaClient.shared = NarGarNastaClient(urlSession: urlSession)

      Trip.search(from: Location.testLocationA, to: Location.testLocationB) { _ in }

      expect(urlSession.lastDataTask?.url.absoluteString).to(contain("v1/fetch_trips/index.json?"))
    }

    it("adds search query to the query string") {
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((responseData, URLResponse(), nil))
      NarGarNastaClient.shared = NarGarNastaClient(urlSession: urlSession)

      Trip.search(from: Location.testLocationA, to: Location.testLocationB) { _ in }

      expect(urlSession.lastDataTask?.url.absoluteString)
        .to(contain(
          "originId=\(Location.testLocationA.id)&destinationId=\(Location.testLocationB.id)"
        ))
    }
  }

  describe("Decodable") {
    let dateFormatter = ISO8601DateFormatter()

    it("decodes from JSON") {
      let jsonData = """
        {
          "departure_time": "2017-02-14T14:00:00Z",
          "arrival_time": "2017-02-14T14:10:00Z"
        }
      """.data(using: .utf8)!
      let jsonDecoder = JSONDecoder()
      jsonDecoder.dateDecodingStrategy = .iso8601

      var trip: Trip?
      expect {
        trip = try jsonDecoder.decode(Trip.self, from: jsonData)
        }.toNot(throwError())

      expect(trip?.departureTime).to(equal(dateFormatter.date(from: "2017-02-14T14:00:00Z")))
      expect(trip?.arrivalTime).to(equal(dateFormatter.date(from: "2017-02-14T14:10:00Z")))
    }
  }

  describe("Equatable") {
    describe("==(lhs:rhs:)") {
      it("considers identical trips equal") {
        var lhs: Trip?
        expect {
          lhs = Trip(
            departureTime: ISO8601DateFormatter().date(from: "2017-02-14T14:00:00Z")!,
            arrivalTime: ISO8601DateFormatter().date(from: "2017-02-14T14:10:00Z")!
          )
        }.toNot(throwError())

        var rhs: Trip?
        expect {
          rhs = Trip(
            departureTime: ISO8601DateFormatter().date(from: "2017-02-14T14:00:00Z")!,
            arrivalTime: ISO8601DateFormatter().date(from: "2017-02-14T14:10:00Z")!
          )
        }.toNot(throwError())

        expect(lhs == rhs).to(beTrue())
      }

      it("considers differening departure times not equal") {
        var lhs: Trip?
        expect {
          lhs = Trip(
            departureTime: ISO8601DateFormatter().date(from: "2017-02-14T14:00:00Z")!,
            arrivalTime: ISO8601DateFormatter().date(from: "2017-02-14T14:10:00Z")!
          )
        }.toNot(throwError())

        var rhs: Trip?
        expect {
          rhs = Trip(
            departureTime: ISO8601DateFormatter().date(from: "2017-02-14T13:00:00Z")!,
            arrivalTime: ISO8601DateFormatter().date(from: "2017-02-14T14:10:00Z")!
          )
        }.toNot(throwError())

        expect(lhs == rhs).to(beFalse())
      }

      it("considers differening arrival times not equal") {
        var lhs: Trip?
        expect {
          lhs = Trip(
            departureTime: ISO8601DateFormatter().date(from: "2017-02-14T14:00:00Z")!,
            arrivalTime: ISO8601DateFormatter().date(from: "2017-02-14T14:10:00Z")!
          )
        }.toNot(throwError())

        var rhs: Trip?
        expect {
          rhs = Trip(
            departureTime: ISO8601DateFormatter().date(from: "2017-02-14T14:00:00Z")!,
            arrivalTime: ISO8601DateFormatter().date(from: "2017-02-14T15:00:00Z")!
          )
        }.toNot(throwError())

        expect(lhs == rhs).to(beFalse())
      }
    }
  }
}

} }
