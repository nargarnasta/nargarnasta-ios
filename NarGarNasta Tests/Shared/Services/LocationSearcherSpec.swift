import Quick
import Nimble
@testable import NarGarNasta

class LocationSearcherSpec: QuickSpec { override func spec() {

describe("LocationSearcher") {
  describe("search") {
    it("completes with locations") {
      let resrobotResponseData = """
        {
          "StopLocation" : [ {
            "id" : "740020749",
            "name" : "T-Centralen T-bana  (Stockholm kn)",
            "lon" : 18.059266,
            "lat" : 59.330945
          }, {
            "id" : "740001360",
            "name" : "Töcksfors Centralen (Årjäng kn)",
            "lon" : 11.841409,
            "lat" : 59.508572
          } ]
        }
      """.data(using: .utf8)
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((resrobotResponseData, URLResponse(), nil))
      ResrobotClient.shared = ResrobotClient(urlSession: urlSession)
      let locationSearcher = LocationSearcher()

      var locations: [Location]?
      waitUntil { done in
        locationSearcher.search(query: "") { returnedLocations in
          locations = returnedLocations
          done()
        }
      }

      expect(locations).to(haveCount(2))
    }
  }
}

} }
