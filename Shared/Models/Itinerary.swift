struct Itinerary: Equatable {
  let location1: Location
  let location2: Location

  init(location1: Location, location2: Location) {
    self.location1 = location1
    self.location2 = location2
  }

  init?(dictionaryRepresentation dictionary: [String: Any]) {
    guard
      let location1ID = dictionary["location1ID"] as? String,
      let location1Name = dictionary["location1Name"] as? String,
      let location2ID = dictionary["location2ID"] as? String,
      let location2Name = dictionary["location2Name"] as? String
    else {
      return nil
    }

    self.location1 = Location(id: location1ID, name: location1Name)
    self.location2 = Location(id: location2ID, name: location2Name)
  }

  func dictionaryRepresentation() -> [String: Any] {
    return [
      "location1ID": location1.id,
      "location1Name": location1.name,
      "location2ID": location2.id,
      "location2Name": location2.name
    ]
  }

  static func ==(lhs: Itinerary, rhs: Itinerary) -> Bool {
    return lhs.location1 == rhs.location1 && lhs.location2 == rhs.location2
  }
}
