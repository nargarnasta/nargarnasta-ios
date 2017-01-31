import Foundation

class UpcomingTrips {
    let itinerary: Itinerary
    let tripSearcher = TripSearcher()
    var trips: [Trip]?
    
    init(itinerary: Itinerary, searchCompleted: @escaping () -> ()) {
        self.itinerary = itinerary
        
        populateFromSearch(completed: searchCompleted)
    }
    
    func removePassedTrips() {
        guard let trips = self.trips else {
            return
        }
        
        let firstUpcomingIndex: Int
        if let index = trips.index(where: { $0.departureTime >= Date() }) {
            firstUpcomingIndex = index
        } else {
            firstUpcomingIndex = 0
        }
        
        self.trips = Array(trips.suffix(from: firstUpcomingIndex))
    }
    
    func populateFromSearch(completed: @escaping () -> ()) {
        tripSearcher.search(originLocation: itinerary.location1, destinationLocation: itinerary.location2) { trips in
            self.trips = trips
            
            completed()
        }
    }
}
