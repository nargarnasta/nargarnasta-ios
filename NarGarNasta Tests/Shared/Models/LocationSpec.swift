import Quick
import Nimble
@testable import NarGarNasta

class LocationSpec: QuickSpec { override func spec() {

describe("Location") {
  describe("init(jsonObject:)") {
    it("initializes location from JSON object") {
      let jsonObject = [
        "id": "1",
        "name": "A"
      ]

      var location: Location?
      expect {
        location = try Location(jsonObject: jsonObject)
      }.toNot(throwError())

      expect(location?.id).to(equal("1"))
      expect(location?.name).to(equal("A"))
    }

    context("with missing properties") {
      it("throws .parametersMissing error") {
        expect {
          try Location(jsonObject: [:])
        }.to(throwError(LocationError.parametersMissing))
      }
    }
  }

  describe("==(lhs:rhs:)") {
    it("considers two identical locations equal") {
      let lhs = Location(id: "1", name: "A")
      let rhs = Location(id: "1", name: "A")

      expect(lhs == rhs).to(beTrue())
    }

    it("considers two different locations not equal") {
      let lhs = Location(id: "1", name: "A")
      let rhs = Location(id: "2", name: "B")

      expect(lhs == rhs).to(beFalse())
    }

    it("considers two locations with same ID but different names equal") {
      let lhs = Location(id: "1", name: "A")
      let rhs = Location(id: "1", name: "AA")

      expect(lhs == rhs).to(beTrue())
    }
  }
}

} }
