import Quick
import Nimble
import CoreLocation
@testable import NarGarNasta

class ItinerarySpec: QuickSpec { override func spec() {

describe("Itinerary") {
  describe("init?(dictionaryRepresentation:)") {
    it("initializes from dictionary") {
      let dictionary: [String: Any] = [
        "location1": [
          "id": "1",
          "name": "A",
          "latitude": NSNumber(value: 58.745),
          "longitude": NSNumber(value: 59.125)
        ],
        "location2": [
          "id": "2",
          "name": "B",
          "latitude": NSNumber(value: 57.745),
          "longitude": NSNumber(value: 58.125)
        ]
      ]

      let itinerary = Itinerary(dictionaryRepresentation: dictionary)

      expect(itinerary?.location1.id).to(equal("1"))
      expect(itinerary?.location2.id).to(equal("2"))
    }

    context("with missing parameters") {
      it("returns nil") {
        let itinerary = Itinerary(dictionaryRepresentation: [:])

        expect(itinerary).to(beNil())
      }
    }
  }

  describe("dictionaryRepresentation()") {
    it("returns a dictionary representation of itself") {
      let itinerary = Itinerary(
        location1: Location(
          id: "1",
          name: "A",
          geolocation: CLLocation()
        ),
        location2: Location(
          id: "2",
          name: "B",
          geolocation: CLLocation()
        )
      )

      let dictionary = itinerary.dictionaryRepresentation()

      let location1Dictionary = dictionary["location1"] as? [String: Any]
      let location2Dictionary = dictionary["location2"] as? [String: Any]
      expect(location1Dictionary?["id"] as? String).to(equal("1"))
      expect(location2Dictionary?["id"] as? String).to(equal("2"))
    }
  }

  describe("==(lhs:rhs:)") {
    it("considers two identical itineraries equal") {
      let lhs = Itinerary(
        location1: Location(id: "1 ID", name: "1 name", geolocation: CLLocation()),
        location2: Location(id: "2 ID", name: "2 name", geolocation: CLLocation())
      )

      let rhs = Itinerary(
        location1: Location(id: "1 ID", name: "1 name", geolocation: CLLocation()),
        location2: Location(id: "2 ID", name: "2 name", geolocation: CLLocation())
      )

      expect(lhs == rhs).to(beTrue())
    }

    it("considers differing itineraries not equal") {
      let lhs = Itinerary(
        location1: Location(id: "1 ID", name: "1 name", geolocation: CLLocation()),
        location2: Location(id: "2 ID", name: "2 name", geolocation: CLLocation())
      )

      let rhs = Itinerary(
        location1: Location(id: "1 ID", name: "1 name", geolocation: CLLocation()),
        location2: Location(id: "3 ID", name: "3 name", geolocation: CLLocation())
      )

      expect(lhs == rhs).to(beFalse())
    }
  }
}

} }
