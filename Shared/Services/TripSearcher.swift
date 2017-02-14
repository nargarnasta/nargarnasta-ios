import Foundation

protocol TripSearcherProtocol: class {
  func search(
    origin: Location,
    destination: Location,
    completion: @escaping ([Trip]) -> Void
  )
}

class TripSearcher: TripSearcherProtocol {
  func search(
    origin: Location,
    destination: Location,
    completion: @escaping ([Trip]) -> Void
  ) {
    let url = endpointURL(origin: origin, destination: destination)

    NSLog("Fetching trips (\(url))")

    let dataTask = URLSession.shared.dataTask(
      with: url
    ) { data, response, error in
      guard let data = data, error == nil else {
        NSLog("Trip search failed: \(error), \(response)")
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
        let tripJsonObjects = jsonObject?["trips"] as? [[String: Any]]
      else {
        NSLog("Malformed JSON: \(jsonObject)")
        return
      }

      let trips: [Trip]
      do {
        trips = try tripJsonObjects.map { try Trip(jsonObject: $0) }
      } catch {
        NSLog("Error: \(error)")
        return
      }

      completion(trips)
    }

    dataTask.resume()
  }

  private func endpointURL(origin: Location, destination: Location) -> URL {
    if
      let url = URL(
        string: "https://nargarnasta.herokuapp.com/api/v1/fetch_trips/" +
          "index.json?originId=\(origin.id)" +
          "&destinationId=\(destination.id)"
      )
    {
      return url
    } else {
      fatalError("Error while creating endpoint URL for trip search")
    }
  }
}
