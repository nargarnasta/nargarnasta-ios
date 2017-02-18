import Quick
import Nimble
import CoreLocation
@testable import NarGarNasta

class LocationSpec: QuickSpec { override func spec() {

describe("Location") {
  describe("init?(dictionaryRepresentation:)") {
    it("initializes from dictionary") {
      let location = Location(dictionaryRepresentation: [
        "id": "1",
        "name": "A",
        "latitude": NSNumber(value: 58.745),
        "longitude": NSNumber(value: 59.125)
      ])

      expect(location?.id).to(equal("1"))
      expect(location?.name).to(equal("A"))
      expect(location?.geolocation.coordinate.latitude).to(equal(58.745))
      expect(location?.geolocation.coordinate.longitude).to(equal(59.125))
    }

    context("with missing parameters") {
      it("returns nil") {
        let location = Location(dictionaryRepresentation: [:])

        expect(location).to(beNil())
      }
    }
  }

  describe("init(jsonObject:)") {
    it("initializes location from JSON object") {
      let jsonObject: [String: Any] = [
        "id": "1",
        "name": "A",
        "lat": NSNumber(value: 58.745),
        "lon": NSNumber(value: 59.125)
      ]

      var location: Location?
      expect {
        location = try Location(jsonObject: jsonObject)
      }.toNot(throwError())

      expect(location?.id).to(equal("1"))
      expect(location?.name).to(equal("A"))
      expect(location?.geolocation.coordinate.latitude).to(equal(58.745))
      expect(location?.geolocation.coordinate.longitude).to(equal(59.125))
    }

    context("with missing properties") {
      it("throws .parametersMissing error") {
        expect {
          try Location(jsonObject: [:])
        }.to(throwError(LocationError.parametersMissing))
      }
    }
  }

  describe("dictionaryRepresentation()") {
    it("returns a dictionary representation of itself") {
      let location = Location(
        id: "1",
        name: "A",
        geolocation: CLLocation(latitude: 58.745, longitude: 59.125)
      )

      let dictionary = location.dictionaryRepresentation()

      expect(dictionary["id"] as? String).to(equal("1"))
      expect(dictionary["name"] as? String).to(equal("A"))
      expect(dictionary["latitude"] as? NSNumber).to(equal(58.745))
      expect(dictionary["longitude"] as? NSNumber).to(equal(59.125))
    }
  }

  describe("==(lhs:rhs:)") {
    it("considers two identical locations equal") {
      let lhs = Location(id: "1", name: "A", geolocation: CLLocation())
      let rhs = Location(id: "1", name: "A", geolocation: CLLocation())

      expect(lhs == rhs).to(beTrue())
    }

    it("considers two different locations not equal") {
      let lhs = Location(id: "1", name: "A", geolocation: CLLocation())
      let rhs = Location(id: "2", name: "B", geolocation: CLLocation())

      expect(lhs == rhs).to(beFalse())
    }

    it("considers two locations with same ID but different names equal") {
      let lhs = Location(id: "1", name: "A", geolocation: CLLocation())
      let rhs = Location(id: "1", name: "AA", geolocation: CLLocation())

      expect(lhs == rhs).to(beTrue())
    }
  }
}

} }
