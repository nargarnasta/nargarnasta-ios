// swiftlint:disable force_unwrapping
import Quick
import Nimble
@testable import NarGarNasta

class ResrobotLocationSpec: QuickSpec { override func spec() {

describe("ResrobotLocation") {
  describe("Decodable") {
    it("decodes from JSON") {
      let jsonData = """
        {
          "id" : "740020749",
          "name" : "T-Centralen T-bana  (Stockholm kn)",
          "lon" : 18.059266,
          "lat" : 59.330945
        }
      """.data(using: .utf8)!

      var location: ResrobotLocation?
      expect {
        location = try JSONDecoder().decode(ResrobotLocation.self, from: jsonData)
      }.toNot(throwError())

      expect(location?.id).to(equal("740020749"))
      expect(location?.name).to(equal("T-Centralen T-bana  (Stockholm kn)"))
      expect(location?.latitude).to(equal(59.330_945))
      expect(location?.longitude).to(equal(18.059_266))
    }
  }
}

} }
