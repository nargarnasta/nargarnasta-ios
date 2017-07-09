import Foundation

class LocationSearcher {
  func search(query: String, completion: @escaping ([Location]) -> Void) {
    ResrobotLocation.search(query: query) { locations in
      completion(locations.map { Location(resrobotLocation: $0) })
    }
  }
}
