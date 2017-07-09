// swiftlint:disable force_unwrapping
import Quick
import Nimble
@testable import NarGarNasta

class ResrobotLocationSpec: QuickSpec { override func spec() {

describe("ResrobotLocation") {
  describe("search") {
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

    it("completes with locations") {
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((resrobotResponseData, URLResponse(), nil))
      ResrobotClient.shared = ResrobotClient(urlSession: urlSession)

      var locations: [ResrobotLocation]?
      waitUntil { done in
        ResrobotLocation.search(query: "") { returnedLocations in
          locations = returnedLocations
          done()
        }
      }

      expect(locations).to(haveCount(2))
    }

    it("uses correct resource name") {
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((resrobotResponseData, URLResponse(), nil))
      ResrobotClient.shared = ResrobotClient(urlSession: urlSession)

      ResrobotLocation.search(query: "") { _ in }

      expect(urlSession.lastDataTask?.url.absoluteString).to(contain("v2/location.name?"))
    }

    it("adds search query to the query string") {
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((resrobotResponseData, URLResponse(), nil))
      ResrobotClient.shared = ResrobotClient(urlSession: urlSession)

      ResrobotLocation.search(query: "testquery") { _ in }

      expect(urlSession.lastDataTask?.url.absoluteString).to(contain("input=testquery"))
    }
  }

  describe("Decodable") {
    it("decodes from JSON") {
      let jsonData = """
        {
          "id" : "740020749",
          "name" : "T-Centralen T-bana  (Stockholm kn)",
          "lon" : 18.059266,
          "lat" : 59.330945
        }
      """.data(using: .utf8)!

      var location: ResrobotLocation?
      expect {
        location = try JSONDecoder().decode(ResrobotLocation.self, from: jsonData)
      }.toNot(throwError())

      expect(location?.id).to(equal("740020749"))
      expect(location?.name).to(equal("T-Centralen T-bana  (Stockholm kn)"))
      expect(location?.latitude).to(equal(59.330_945))
      expect(location?.longitude).to(equal(18.059_266))
    }
  }
}

} }
