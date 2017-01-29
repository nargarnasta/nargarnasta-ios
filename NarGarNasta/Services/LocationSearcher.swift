import Foundation

class LocationSearcher {
    func search(query: String, completion: @escaping ([Location]) -> ()) {
        let dataTask = URLSession.shared.dataTask(with: endpointURL(query: query)) { data, response, error in
            guard let data = data, error == nil else {
                NSLog("Resrobot location search failed: \(error), \(response)")
                return
            }
            
            guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let locationJsonObjects = jsonObject?["StopLocation"] as? [[String: Any]] else {
                NSLog("Malformed JSON: \(data)")
                return
            }
            
            let locations: [Location]
            do {
                locations = try locationJsonObjects.map { try Location(jsonObject: $0) }
            } catch {
                NSLog("Error: \(error)")
                return
            }
            
            completion(locations)
        }
            
        dataTask.resume()
    }
    
    private func endpointURL(query: String) -> URL {
        return URL(string: "https://api.resrobot.se/v2/location.name?key=\(apiKey())&format=json&input=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)")!
    }
    
    private func apiKey() -> String {
        return ""
    }
}
