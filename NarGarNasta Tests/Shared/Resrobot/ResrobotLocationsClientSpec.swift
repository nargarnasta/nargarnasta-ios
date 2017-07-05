import Quick
import Nimble
@testable import NarGarNasta

class ResrobotLocationsClientSpec: QuickSpec { override func spec() {

  describe("ResrobotLocationsClient") {
    describe("search") {
      let responseData = """
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

      it("completes with search results from Resrobot") {
        let urlSession = URLSessionDouble()
        urlSession.queuedResponses.append((responseData, URLResponse(), nil))
        let client = ResrobotLocationsClient(urlSession: urlSession)

        var results: ResrobotLocationsSearchResults?
        waitUntil { done in
          client.search(query: "") { returnedResults in
            results = returnedResults
            done()
          }
        }

        expect(results?.locations).to(haveCount(2))
      }

      it("generates correct request URL") {
        let urlSession = URLSessionDouble()
        urlSession.queuedResponses.append((responseData, URLResponse(), nil))
        let client = ResrobotLocationsClient(urlSession: urlSession)

        client.search(query: "query") { _ in }

        expect(urlSession.lastDataTask?.url.absoluteString).to(
          equal("https://api.resrobot.se/v2/location.name" +
            "?key=\(Settings.resrobotAPIKey)" +
            "&format=json" +
            "&input=query")
        )
      }

      it("percent encodes non-query string characters for the URL") {
        let urlSession = URLSessionDouble()
        urlSession.queuedResponses.append((responseData, URLResponse(), nil))
        let client = ResrobotLocationsClient(urlSession: urlSession)

        client.search(query: "hötorget") { _ in }

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
