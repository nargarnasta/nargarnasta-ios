import Quick
import Nimble
@testable import NarGarNasta

class TripSearcherSpec: QuickSpec { override func spec() {

describe("TripSearcher") {
  describe("search") {
    it("returns a list of trips fetched from backend") {
      let tripsResponseData = """
        {
          "trips": [
            {
              "departure_time": "2017-02-14T14:00:00Z",
              "arrival_time": "2017-02-14T14:10:00Z"
            },
            {
              "departure_time": "2017-02-14T14:05:00Z",
              "arrival_time": "2017-02-14T14:15:00Z"
            }
          ]
        }
      """.data(using: .utf8)
      let response = URLResponse()
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((tripsResponseData, response, nil))
      NarGarNastaClient.shared = NarGarNastaClient(urlSession: urlSession)
      let tripSearcher = TripSearcher()

      var trips: [Trip]?
      waitUntil { done in
        tripSearcher.search(
          origin: Location.testLocationA,
          destination: Location.testLocationB
        ) { returnedTrips in
          trips = returnedTrips
          done()
        }
      }

      expect(trips).to(haveCount(2))
    }
  }
}

} }
