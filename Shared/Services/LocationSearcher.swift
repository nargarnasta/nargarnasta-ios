import Foundation

class LocationSearcher {
  func search(query: String, completion: @escaping ([Location]) -> Void) {
    let dataTask = URLSession.shared.dataTask(
      with: endpointURL(query: query)
    ) { data, response, error in
      guard let data = data, error == nil else {
        NSLog("Resrobot location search failed: \(error), \(response)")
        return
      }

      let jsonObject: [String: Any]?
      do {
        jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
          as? [String: Any]
      } catch {
        NSLog("Deserialization error: \(error)")
        return
      }

      guard
        let locationJsonObjects = jsonObject?["StopLocation"]
          as? [[String: Any]]
      else {
        NSLog("Malformed JSON: \(data)")
        return
      }

      let locations: [Location]
      do {
        locations = try locationJsonObjects.map { try Location(jsonObject: $0) }
      } catch {
        NSLog("Error: \(error)")
        return
      }

      completion(locations)
    }

    dataTask.resume()
  }

  private func endpointURL(query: String) -> URL {
    if
      let encodedQuery = query.addingPercentEncoding(
        withAllowedCharacters: .urlQueryAllowed
      ),
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
