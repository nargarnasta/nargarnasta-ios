import Foundation

class LocationSearcher {
  let resrobotLocationsClient: ResrobotLocationsClient

  init(resrobotLocationsClient: ResrobotLocationsClient = ResrobotLocationsClient()) {
    self.resrobotLocationsClient = resrobotLocationsClient
  }

  func search(query: String, completion: @escaping ([Location]) -> Void) {
    resrobotLocationsClient.search(query: query) { results in
      completion(results.locations.map { Location(resrobotLocation: $0) })
    }
  }
}
