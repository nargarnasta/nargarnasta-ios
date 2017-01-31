struct Itinerary {
    let location1: Location
    let location2: Location
    
    init(location1: Location, location2: Location) {
        self.location1 = location1
        self.location2 = location2
    }
    
    init?(dictionaryRepresentation: [String: Any]) {
        guard let location1ID = dictionaryRepresentation["location1ID"] as? String, let location1Name = dictionaryRepresentation["location1Name"] as? String, let location2ID = dictionaryRepresentation["location2ID"] as? String, let location2Name = dictionaryRepresentation["location2Name"] as? String else {
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
}
