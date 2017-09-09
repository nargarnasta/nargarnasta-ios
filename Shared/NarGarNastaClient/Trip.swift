import Foundation

struct Trip: Equatable, Decodable {
  let departureTime: Date
  let arrivalTime: Date

  // MARK: - Searching

  static func search(
    from origin: Location,
    to destination: Location,
    completion: @escaping ([Trip]) -> Void
  ) {
    NarGarNastaClient.shared.request(
      resourceName: "fetch_trips/index.json",
      queryItems: [
        URLQueryItem(name: "originId", value: origin.id),
        URLQueryItem(name: "destinationId", value: destination.id)
      ]
    ) { (response: SearchResponse?, _) in
      guard let trips = response?.trips else { return }
      completion(trips)
    }
  }

  // MARK: - Decodable

  enum CodingKeys: String, CodingKey {
    case departureTime = "departure_time"
    case arrivalTime = "arrival_time"
  }

  // MARK: - Equatable

  static func ==(lhs: Trip, rhs: Trip) -> Bool {
    return (lhs.departureTime == rhs.departureTime && lhs.arrivalTime == rhs.arrivalTime)
  }
}

// MARK: - Responses

fileprivate struct SearchResponse: Decodable {
  let trips: [Trip]
}
