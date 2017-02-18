import CoreLocation

struct Itinerary: Equatable {
  let location1: Location
  let location2: Location

  init(location1: Location, location2: Location) {
    self.location1 = location1
    self.location2 = location2
  }

  init?(dictionaryRepresentation dictionary: [String: Any]) {
    guard
      let location1Dictionary = dictionary["location1"] as? [String: Any],
      let location2Dictionary = dictionary["location2"] as? [String: Any],
      let location1 = Location(dictionaryRepresentation: location1Dictionary),
      let location2 = Location(dictionaryRepresentation: location2Dictionary)
    else {
      return nil
    }

    self.location1 = location1
    self.location2 = location2
  }

  func dictionaryRepresentation() -> [String: Any] {
    return [
      "location1": location1.dictionaryRepresentation(),
      "location2": location2.dictionaryRepresentation()
    ]
  }

  static func ==(lhs: Itinerary, rhs: Itinerary) -> Bool {
    return lhs.location1 == rhs.location1 && lhs.location2 == rhs.location2
  }
}
