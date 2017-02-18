import Quick
import Nimble
@testable import NarGarNasta

class LocationSearcherSpec: QuickSpec { override func spec() {

describe("LocationSearcher") {
  describe("search") {
    func locationsData(jsonObject: [String: Any]? = nil) -> Data {
      do {
        return try JSONSerialization.data(
          withJSONObject: jsonObject ?? [
            "StopLocation": [
              [
                "id": "1",
                "name": "A",
                "lat": NSNumber(value: 58.745),
                "lon": NSNumber(value: 59.125)
              ] as [String: Any],
              [
                "id": "2",
                "name": "B",
                "lat": NSNumber(value: 57.745),
                "lon": NSNumber(value: 58.125)
              ] as [String: Any]
            ]
          ],
          options: []
        )
      } catch {
        fatalError()
      }
    }

    it("returns a list of locations from Resrobot") {
      let data = locationsData(jsonObject: [
        "StopLocation": [
          [
            "id": "1",
            "name": "A",
            "lat": NSNumber(value: 58.745),
            "lon": NSNumber(value: 59.125)
          ] as [String: Any],
          [
            "id": "2",
            "name": "B",
            "lat": NSNumber(value: 57.745),
            "lon": NSNumber(value: 58.125)
          ] as [String: Any]
        ]
      ])
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((data, URLResponse(), nil))
      let locationSearcher = LocationSearcher(urlSession: urlSession)

      var locations: [Location]?
      waitUntil { done in
        locationSearcher.search(query: "") { returnedLocations in
          locations = returnedLocations
          done()
        }
      }

      expect(locations).to(haveCount(2))
    }

    it("generates correct request URL") {
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((locationsData(), URLResponse(), nil))
      let locationSearcher = LocationSearcher(urlSession: urlSession)

      waitUntil { done in
        locationSearcher.search(query: "query") { _ in
          done()
        }
      }

      expect(urlSession.lastDataTask?.url.absoluteString).to(
        equal("https://api.resrobot.se/v2/location.name" +
          "?key=\(Settings.resrobotAPIKey)" +
          "&format=json" +
          "&input=query")
      )
    }

    it("percent encodes non-query string characters for the URL") {
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((locationsData(), URLResponse(), nil))
      let locationSearcher = LocationSearcher(urlSession: urlSession)

      waitUntil { done in
        locationSearcher.search(query: "hötorget") { _ in
          done()
        }
      }

      expect(urlSession.lastDataTask?.url.absoluteString).to(
        equal("https://api.resrobot.se/v2/location.name" +
          "?key=\(Settings.resrobotAPIKey)" +
          "&format=json" +
          "&input=h%C3%B6torget")
      )
    }
  }
}

} }
