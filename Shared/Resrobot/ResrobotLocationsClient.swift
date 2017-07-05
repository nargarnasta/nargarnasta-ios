import Foundation

class ResrobotLocationsClient {
  let urlSession: URLSessionProtocol

  init(urlSession: URLSessionProtocol = URLSession.shared) {
    self.urlSession = urlSession
  }

  func search(query: String, completion: @escaping (ResrobotLocationsSearchResults) -> Void) {
    let dataTask = urlSession.dataTask(with: requestURL(query: query)) { data, response, error in
      guard let data = data, error == nil else {
        NSLog(
          "Resrobot location search failed: \(String(describing: error))," +
          "\(String(describing: response))"
        )
        return
      }

      guard
        let result = try? JSONDecoder().decode(ResrobotLocationsSearchResults.self, from: data)
      else {
        NSLog("Unable to decode Resrobot response")
        return
      }

      completion(result)
    }

    dataTask.resume()
  }

  private func requestURL(query: String) -> URL {
    if
      let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
      let url = URL(
        string: "https://api.resrobot.se/v2/location.name" +
          "?key=\(Settings.resrobotAPIKey)" +
          "&format=json" +
          "&input=\(encodedQuery)"
      )
    {
      return url
    } else {
      fatalError("Could not generate endpoint URL for location search")
    }
  }
}
