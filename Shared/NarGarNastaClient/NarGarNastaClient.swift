import Foundation

enum NarGarNastaClientError: Error {
  case requestError(underlyingError: Error)
  case decodingError(underlyingError: DecodingError)
}

class NarGarNastaClient {
  static var shared = NarGarNastaClient()
  let urlSession: URLSessionProtocol

  init(urlSession: URLSessionProtocol = URLSession.shared) {
    self.urlSession = urlSession
  }

  func request<Response: Decodable>(
    resourceName: String,
    queryItems: [URLQueryItem],
    completion: @escaping (Response?, NarGarNastaClientError?) -> Void
  ) {
    let dataTask = urlSession.dataTask(
      with: requestURL(resourceName: resourceName, queryItems: queryItems)
    ) { data, _, error in
      if let error = error {
        NSLog("Request failed: \(String(describing: error))")
        completion(nil, .requestError(underlyingError: error))
        return
      }
      guard let data = data, error == nil else { fatalError() }

      let jsonDecoder = JSONDecoder()
      jsonDecoder.dateDecodingStrategy = .iso8601
      let result: Response
      do {
        result = try jsonDecoder.decode(Response.self, from: data)
      } catch let error as DecodingError {
        NSLog("Unable to decode response: \(error)")
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
    var urlComponents = URLComponents(
      string: "https://nargarnasta.herokuapp.com/api/v1/\(resourceName)"
    )
    urlComponents?.queryItems = queryItems
    guard let url = urlComponents?.url else { fatalError() }
    return url
  }
}
