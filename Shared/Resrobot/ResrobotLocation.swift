struct ResrobotLocation: Decodable {
  let id: String
  let name: String
  let latitude: Double
  let longitude: Double

  // MARK: - Codable

  enum CodingKeys: String, CodingKey {
    case id
    case name
    case latitude = "lat"
    case longitude = "lon"
  }
}
