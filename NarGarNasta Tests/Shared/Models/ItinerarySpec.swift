import Quick
import Nimble
import CoreLocation
@testable import NarGarNasta

class ItinerarySpec: QuickSpec { override func spec() {

describe("Itinerary") {
  describe("dictionary coding") {
    describe("init?(dictionaryRepresentation:)") {
      it("initializes from dictionary") {
        let dictionary: [String: Any] = [
          "destinationA": [
            "id": "1",
            "name": "A",
            "latitude": NSNumber(value: 58.745),
            "longitude": NSNumber(value: 59.125)
          ],
          "destinationB": [
            "id": "2",
            "name": "B",
            "latitude": NSNumber(value: 57.745),
            "longitude": NSNumber(value: 58.125)
          ]
        ]

        let itinerary = Itinerary(dictionaryRepresentation: dictionary)

        expect(itinerary?.destinationA.id).to(equal("1"))
        expect(itinerary?.destinationB.id).to(equal("2"))
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
          destinationA: Location(
            id: "1",
            name: "A",
            geolocation: CLLocation()
          ),
          destinationB: Location(
            id: "2",
            name: "B",
            geolocation: CLLocation()
          )
        )

        let dictionary = itinerary.dictionaryRepresentation()

        let destinationADictionary = dictionary["destinationA"] as? [String: Any]
        let destinationBDictionary = dictionary["destinationB"] as? [String: Any]
        expect(destinationADictionary?["id"] as? String).to(equal("1"))
        expect(destinationBDictionary?["id"] as? String).to(equal("2"))
      }
    }
  }

  describe("Equatable") {
    describe("==(lhs:rhs:)") {
      it("considers two identical itineraries equal") {
        let lhs = Itinerary(
          destinationA: Location(id: "1 ID", name: "1 name", geolocation: CLLocation()),
          destinationB: Location(id: "2 ID", name: "2 name", geolocation: CLLocation())
        )

        let rhs = Itinerary(
          destinationA: Location(id: "1 ID", name: "1 name", geolocation: CLLocation()),
          destinationB: Location(id: "2 ID", name: "2 name", geolocation: CLLocation())
        )

        expect(lhs == rhs).to(beTrue())
      }

      it("considers differing itineraries not equal") {
        let lhs = Itinerary(
          destinationA: Location(id: "1 ID", name: "1 name", geolocation: CLLocation()),
          destinationB: Location(id: "2 ID", name: "2 name", geolocation: CLLocation())
        )

        let rhs = Itinerary(
          destinationA: Location(id: "1 ID", name: "1 name", geolocation: CLLocation()),
          destinationB: Location(id: "3 ID", name: "3 name", geolocation: CLLocation())
        )

        expect(lhs == rhs).to(beFalse())
      }
    }
  }
}

} }
