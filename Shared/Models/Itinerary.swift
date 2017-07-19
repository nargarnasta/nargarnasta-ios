struct Itinerary: Equatable {
  // MARK: - Properties

  let destinationA: Location
  let destinationB: Location

  // MARK: - Initializers

  init(destinationA: Location, destinationB: Location) {
    self.destinationA = destinationA
    self.destinationB = destinationB
  }

  // MARK: - Dictionary coding

  init?(dictionaryRepresentation dictionary: [String: Any]) {
    guard
      let destinationADictionary = dictionary["destinationA"] as? [String: Any],
      let destinationBDictionary = dictionary["destinationB"] as? [String: Any],
      let destinationA = Location(dictionaryRepresentation: destinationADictionary),
      let destinationB = Location(dictionaryRepresentation: destinationBDictionary)
    else {
      return nil
    }

    self.destinationA = destinationA
    self.destinationB = destinationB
  }

  func dictionaryRepresentation() -> [String: Any] {
    return [
      "destinationA": destinationA.dictionaryRepresentation(),
      "destinationB": destinationB.dictionaryRepresentation()
    ]
  }

  // MARK: - Equatable

  static func ==(lhs: Itinerary, rhs: Itinerary) -> Bool {
    return lhs.destinationA == rhs.destinationA && lhs.destinationB == rhs.destinationB
  }
}
