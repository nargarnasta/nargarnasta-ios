struct ResrobotLocationsSearchResults: Decodable {
  let locations: [ResrobotLocation]

  // MARK: - Decodable

  enum CodingKeys: String, CodingKey {
    case locations = "StopLocation"
  }
}
