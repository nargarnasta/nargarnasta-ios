import Quick
import Nimble
@testable import NarGarNasta

class ResrobotClientSpec: QuickSpec { override func spec() {

describe("ResrobotLocationsClient") {
  describe("request(resourceName:queryItems:completion:)") {
    struct TestResponse: Codable {
      let test: String
    }
    let responseData = """
        { "test": "hello" }
      """.data(using: .utf8)

    it("completes with successful response") {
      let responseData = """
        { "test": "hello" }
      """.data(using: .utf8)

      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((responseData, URLResponse(), nil))
      let client = ResrobotClient(urlSession: urlSession)

      var response: TestResponse?
      waitUntil { done in
        client.request(resourceName: "", queryItems: []) { (returnedResponse: TestResponse?, _) in
          response = returnedResponse
          done()
        }
      }

      expect(response?.test).to(equal("hello"))
    }

    it("generates correct request URL") {
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((responseData, URLResponse(), nil))
      let client = ResrobotClient(urlSession: urlSession)

      client.request(
        resourceName: "test",
        queryItems: [URLQueryItem(name: "test", value: "hello")]
      ) { (_: TestResponse?, _) in }

      expect(urlSession.lastDataTask?.url.absoluteString).to(
        equal("https://api.resrobot.se/v2/test" +
          "?key=\(Settings.resrobotAPIKey)" +
          "&format=json" +
          "&test=hello")
      )
    }

    it("percent encodes non-query string characters for the URL") {
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((responseData, URLResponse(), nil))
      let client = ResrobotClient(urlSession: urlSession)

      client.request(
        resourceName: "test",
        queryItems: [URLQueryItem(name: "test", value: "hö")]
      ) { (_: TestResponse?, _) in }

      expect(urlSession.lastDataTask?.url.absoluteString).to(
        equal("https://api.resrobot.se/v2/test" +
          "?key=\(Settings.resrobotAPIKey)" +
          "&format=json" +
          "&test=h%C3%B6")
      )
    }

    it("completes with requestError when request fails") {
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append(
        (nil, URLResponse(), NSError(domain: "", code: 0, userInfo: [:]) )
      )
      let client = ResrobotClient(urlSession: urlSession)

      var error: ResrobotClientError?
      waitUntil { done in
        client.request(resourceName: "", queryItems: []) { (_: TestResponse?, returnedError) in
          error = returnedError
          done()
        }
      }

      switch error {
      case .requestError(underlyingError: _)?:
        break
      default:
        fail("Expected .requestError, got something else")
      }
    }

    it("completes with decodingError when decoding fails") {
      let responseData = "{}".data(using: .utf8)

      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((responseData, URLResponse(), nil))
      let client = ResrobotClient(urlSession: urlSession)

      var error: ResrobotClientError?
      waitUntil { done in
        client.request(resourceName: "", queryItems: []) { (_: TestResponse?, returnedError) in
          error = returnedError
          done()
        }
      }

      switch error {
      case .decodingError(underlyingError: _)?:
        break
      default:
        fail("Expected .decodingError, got something else")
      }
    }
  }
}

} }
