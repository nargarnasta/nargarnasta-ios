import Quick
import Nimble
@testable import NarGarNasta

class IOSPreferencesStoreSpec: QuickSpec { override func spec() {

describe("IOSPreferencesStore") {
  describe("updateItineraries(itineraries:)") {
    it("updates itineraries property to provided value") {
      let preferencesStore = IOSPreferencesStore()
      let itineraries = [
        Itinerary(
          location1: Location(id: "1", name: "A"),
          location2: Location(id: "2", name: "B")
        )
      ]

      preferencesStore.updateItineraries(itineraries: itineraries)

      expect(preferencesStore.itineraries).to(equal(itineraries))
    }
  }

  // TODO: Test this thing properly
}

} }
