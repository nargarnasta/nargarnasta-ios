import Foundation

struct ResrobotLocation: Decodable {
  let id: String
  let name: String
  let latitude: Double
  let longitude: Double

  // MARK: - Searching

  static func search(query: String, completion: @escaping ([ResrobotLocation]) -> Void) {
    ResrobotClient.shared.request(
      resourceName: "location.name",
      queryItems: [URLQueryItem(name: "input", value: query)]
    ) { (results: SearchResponse?, _) in
      guard let locations = results?.locations else { return }
      completion(locations)
    }
  }

  // MARK: - Decodable

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case latitude = "lat"
    case longitude = "lon"
  }
}

// MARK: - Responses

fileprivate struct SearchResponse: Decodable {
  let locations: [ResrobotLocation]

  enum CodingKeys: String, CodingKey {
    case locations = "StopLocation"
  }
}
