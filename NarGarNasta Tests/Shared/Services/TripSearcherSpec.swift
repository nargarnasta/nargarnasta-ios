import Quick
import Nimble
@testable import NarGarNasta

class TripSearcherSpec: QuickSpec { override func spec() {

describe("TripSearcher") {
  describe("search") {
    func tripsData(jsonObject: [String: Any]? = nil) -> Data {
      do {
        return try JSONSerialization.data(
          withJSONObject: jsonObject ?? [
            "trips": [
              [
                "departure_time": "2017-02-14T14:00:00Z",
                "arrival_time": "2017-02-14T14:10:00Z"
              ],
              [
                "departure_time": "2017-02-14T14:05:00Z",
                "arrival_time": "2017-02-14T14:15:00Z"
              ]
            ]
          ],
          options: []
        )
      } catch {
        fatalError()
      }
    }

    it("returns a list of trips fetched from backend") {
      let data = tripsData(jsonObject: [
        "trips": [
          [
            "departure_time": "2017-02-14T14:00:00Z",
            "arrival_time": "2017-02-14T14:10:00Z"
          ],
          [
            "departure_time": "2017-02-14T14:05:00Z",
            "arrival_time": "2017-02-14T14:15:00Z"
          ]
        ]
      ])
      let response = URLResponse()
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((data, response, nil))
      let tripSearcher = TripSearcher(urlSession: urlSession)

      var trips: [Trip]?
      waitUntil { done in
        tripSearcher.search(
          origin: Location(id: "1", name: "A"),
          destination: Location(id: "2", name: "B")
        ) { returnedTrips in
          trips = returnedTrips
          done()
        }
      }

      expect(trips).to(haveCount(2))
    }

    it("generates correct request URL") {
      let response = URLResponse()
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((tripsData(), response, nil))
      let tripSearcher = TripSearcher(urlSession: urlSession)

      waitUntil { done in
        tripSearcher.search(
          origin: Location(id: "1", name: "A"),
          destination: Location(id: "2", name: "B")
        ) { _ in
          done()
        }
      }

      expect(urlSession.lastDataTask?.url.absoluteString).to(
        equal("https://nargarnasta.herokuapp.com/api/v1/fetch_trips/" +
          "index.json?originId=1" +
          "&destinationId=2")
      )
    }

    // TODO: Define behavior for failure cases:
    //       - Non-OK response codes
    //       - Missing trips object
    //       - Missing/invalid properties for trips
    //       - Malformatted JSON
  }
}

} }
