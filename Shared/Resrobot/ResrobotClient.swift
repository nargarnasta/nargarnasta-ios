import Foundation

enum ResrobotClientError: Error {
  case requestError(underlyingError: Error)
  case decodingError(underlyingError: DecodingError)
}

class ResrobotClient {
  static let defaultQueryItems = [
    URLQueryItem(name: "key", value: Settings.resrobotAPIKey),
    URLQueryItem(name: "format", value: "json")
  ]
  static var shared = ResrobotClient()
  let urlSession: URLSessionProtocol

  init(urlSession: URLSessionProtocol = URLSession.shared) {
    self.urlSession = urlSession
  }

  func request<Response: Decodable>(
    resourceName: String,
    queryItems: [URLQueryItem],
    completion: @escaping (Response?, ResrobotClientError?) -> Void
  ) {
    let dataTask = urlSession.dataTask(
      with: requestURL(resourceName: resourceName, queryItems: queryItems)
    ) { data, _, error in
      if let error = error {
        NSLog("Resrobot request failed: \(String(describing: error))")
        completion(nil, .requestError(underlyingError: error))
        return
      }
      guard let data = data, error == nil else { fatalError() }

      let result: Response
      do {
        result = try JSONDecoder().decode(Response.self, from: data)
      } catch let error as DecodingError {
        NSLog("Unable to decode Resrobot response: \(error)")
        completion(nil, .decodingError(underlyingError: error))
        return
      } catch {
        fatalError()
      }

      completion(result, nil)
    }

    dataTask.resume()
  }

  private func requestURL(resourceName: String, queryItems: [URLQueryItem]) -> URL {
    var urlComponents = URLComponents(string: "https://api.resrobot.se/v2/\(resourceName)")
    urlComponents?.queryItems = ResrobotClient.defaultQueryItems + queryItems
    guard let url = urlComponents?.url else { fatalError() }
    return url
  }
}
