import Quick
import Nimble
@testable import NarGarNasta

class ItinerarySpec: QuickSpec { override func spec() {

describe("Itinerary") {
  describe("init?(dictionaryRepresentation:)") {
    it("initializes from dictionary") {
      let dictionary = [
        "location1ID": "1 ID",
        "location1Name": "1 name",
        "location2ID": "2 ID",
        "location2Name": "2 name"
      ]

      let itinerary = Itinerary(dictionaryRepresentation: dictionary)

      expect(itinerary?.location1.id).to(equal("1 ID"))
      expect(itinerary?.location1.name).to(equal("1 name"))
      expect(itinerary?.location2.id).to(equal("2 ID"))
      expect(itinerary?.location2.name).to(equal("2 name"))
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
        location1: Location(id: "1 ID", name: "1 name"),
        location2: Location(id: "2 ID", name: "2 name")
      )

      let dictionary = itinerary.dictionaryRepresentation()

      expect(dictionary["location1ID"] as? String).to(equal("1 ID"))
      expect(dictionary["location1Name"] as? String).to(equal("1 name"))
      expect(dictionary["location2ID"] as? String).to(equal("2 ID"))
      expect(dictionary["location2Name"] as? String).to(equal("2 name"))
    }
  }

  describe("==(lhs:rhs:)") {
    it("considers two identical itineraries equal") {
      let lhs = Itinerary(
        location1: Location(id: "1 ID", name: "1 name"),
        location2: Location(id: "2 ID", name: "2 name")
      )

      let rhs = Itinerary(
        location1: Location(id: "1 ID", name: "1 name"),
        location2: Location(id: "2 ID", name: "2 name")
      )

      expect(lhs == rhs).to(beTrue())
    }

    it("considers differing itineraries not equal") {
      let lhs = Itinerary(
        location1: Location(id: "1 ID", name: "1 name"),
        location2: Location(id: "2 ID", name: "2 name")
      )

      let rhs = Itinerary(
        location1: Location(id: "1 ID", name: "1 name"),
        location2: Location(id: "3 ID", name: "3 name")
      )

      expect(lhs == rhs).to(beFalse())
    }
  }
}

} }
