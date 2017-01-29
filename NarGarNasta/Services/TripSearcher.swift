import Foundation

class TripSearcher {
    func search(originLocation: Location, destinationLocation: Location, completion: @escaping ([Trip]) -> ()) {
        let dataTask = URLSession.shared.dataTask(with: endpointURL(originLocation: originLocation, destinationLocation: destinationLocation)) { data, response, error in
            guard let data = data, error == nil else {
                NSLog("Trip search failed: \(error), \(response)")
                return
            }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let tripJsonObjects = jsonObject?["trips"] as? [[String: Any]] else {
                NSLog("Malformed JSON: \(data)")
                return
            }
            
            let trips: [Trip]
            do {
                trips = try tripJsonObjects.map { try Trip(jsonObject: $0) }
            } catch {
                NSLog("Error: \(error)")
                return
            }
            
            completion(trips)
        }
        
        dataTask.resume()
    }
    
    private func endpointURL(originLocation: Location, destinationLocation: Location) -> URL {
        return URL(string: "https://nargarnasta.herokuapp.com/api/v1/fetch_trips/index.json?originId=\(originLocation.id)&destinationId=\(destinationLocation.id)")!
    }
}
