import Quick
import Nimble
@testable import NarGarNasta

class NarGarNastaClientSpec: QuickSpec { override func spec() {

describe("NarGarNastaClient") {
  describe("request(resourceName:queryItems:completion:)") {
    struct TestResponse: Decodable {
      let test: String
      let date: Date?
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
      let client = NarGarNastaClient(urlSession: urlSession)

      var response: TestResponse?
      waitUntil { done in
        client.request(resourceName: "", queryItems: []) { (returnedResponse: TestResponse?, _) in
          response = returnedResponse
          done()
        }
      }

      expect(response?.test).to(equal("hello"))
    }

    it("decodes dates as ISO8601 strings") {
      let responseData = """
        {
          "test": "hello",
          "date": "2017-02-14T14:00:00Z"
        }
      """.data(using: .utf8)

      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((responseData, URLResponse(), nil))
      let client = NarGarNastaClient(urlSession: urlSession)

      var response: TestResponse?
      waitUntil { done in
        client.request(resourceName: "", queryItems: []) { (returnedResponse: TestResponse?, _) in
          response = returnedResponse
          done()
        }
      }

      expect(response?.date).to(equal(ISO8601DateFormatter().date(from: "2017-02-14T14:00:00Z")))
    }

    it("generates correct request URL") {
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append((responseData, URLResponse(), nil))
      let client = NarGarNastaClient(urlSession: urlSession)

      client.request(
        resourceName: "test",
        queryItems: [URLQueryItem(name: "test", value: "hello")]
      ) { (_: TestResponse?, _) in }

      expect(urlSession.lastDataTask?.url.absoluteString)
        .to(equal("https://nargarnasta.herokuapp.com/api/v1/test?test=hello"))
    }

    it("completes with requestError when request fails") {
      let urlSession = URLSessionDouble()
      urlSession.queuedResponses.append(
        (nil, URLResponse(), NSError(domain: "", code: 0, userInfo: [:]) )
      )
      let client = NarGarNastaClient(urlSession: urlSession)

      var error: NarGarNastaClientError?
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
      let client = NarGarNastaClient(urlSession: urlSession)

      var error: NarGarNastaClientError?
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
