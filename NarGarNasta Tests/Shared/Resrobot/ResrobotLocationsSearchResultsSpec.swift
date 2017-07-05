// swiftlint:disable force_unwrapping
import Quick
import Nimble
@testable import NarGarNasta

class ResrobotLocationsSearchResultsSpec: QuickSpec { override func spec() {

describe("ResrobotLocationsSearchResults") {
  describe("Decodable") {
    it("decodes from JSON") {
      let jsonData = """
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
      """.data(using: .utf8)!

      var results: ResrobotLocationsSearchResults?
      expect {
        results = try JSONDecoder().decode(ResrobotLocationsSearchResults.self, from: jsonData)
      }.toNot(throwError())

      expect(results?.locations.count).to(equal(2))
    }
  }
}

} }
