import Quick
import Nimble
import CoreLocation
@testable import NarGarNasta

class ItineraryDirectionDeterminerSpec: QuickSpec { override func spec() {

describe("ItineraryDirectionDeterminer") {
  describe("determineBestDirection(completion:error:)") {
    let location1 = Location(
      id: "1",
      name: "A",
      geolocation: CLLocation(
        latitude: 59.356,
        longitude: 18.019
      )
    )
    let location2 = Location(
      id: "2",
      name: "B",
      geolocation: CLLocation(
        latitude: 59.366,
        longitude: 18.033
      )
    )
    let itinerary = Itinerary(
      destinationA: location1,
      destinationB: location2
    )
    let locationManager = CLLocationManagerDouble()

    it("determines location 1 as origin when closest to the current location") {
      locationManager.nextLocation = CLLocation( // Point closer to A
        latitude: 59.356,
        longitude: 18.019
      )

      let determiner = ItineraryDirectionDeterminer(
        itinerary: itinerary,
        locationManager: locationManager
      )
      var determinedOrigin: Location?
      var determinedDestination: Location?
      waitUntil { done in
        determiner.determineBestDirection(
          completion: { origin, destination in
            determinedOrigin = origin
            determinedDestination = destination
            done()
          },
          error: { _ in
            fail("Error handler was unexpectedly called")
          }
        )
      }

      expect(determinedOrigin).to(equal(location1))
      expect(determinedDestination).to(equal(location2))
    }

    it("determines location 2 as origin when closest to the current location") {
      locationManager.nextLocation = CLLocation( // Point closer to B
        latitude: 59.367,
        longitude: 18.028
      )

      let determiner = ItineraryDirectionDeterminer(
        itinerary: itinerary,
        locationManager: locationManager
      )
      var determinedOrigin: Location?
      var determinedDestination: Location?
      waitUntil { done in
        determiner.determineBestDirection(
          completion: { origin, destination in
            determinedOrigin = origin
            determinedDestination = destination
            done()
          },
          error: { _ in }
        )
      }

      expect(determinedOrigin).to(equal(location2))
      expect(determinedDestination).to(equal(location1))
    }

    it("sets accuracy to kilometer") {
      locationManager.nextLocation = CLLocation( // Point closer to B
        latitude: 59.367,
        longitude: 18.028
      )
      let determiner = ItineraryDirectionDeterminer(
        itinerary: itinerary,
        locationManager: locationManager
      )

      waitUntil { done in
        determiner.determineBestDirection(
          completion: { _, _ in
            done()
        },
          error: { _ in
            fail("Error handler was unexpectedly called")
        }
        )
      }

      expect(locationManager.desiredAccuracy).to(
        equal(kCLLocationAccuracyKilometer)
      )
    }

    context("when location can't be determined") {
      beforeEach {
        locationManager.nextLocation = nil
      }

      it("returns locationUnknown error") {
        let determiner = ItineraryDirectionDeterminer(
          itinerary: itinerary,
          locationManager: locationManager
        )

        var error: ItineraryDirectionDeterminerError?
        waitUntil { done in
          determiner.determineBestDirection(
            completion: { _, _ in
              fail("Completion handler was unexpectedly called")
          },
            error: { returnedError in
              error = returnedError
              done()
          }
          )
        }

        expect(error).to(
          equal(ItineraryDirectionDeterminerError.locationUnknown)
        )
      }
    }

    context("when CoreLocation authorization is undetermined") {
      beforeEach {
        locationManager.authorizationStatus = .notDetermined
        locationManager.nextLocation = CLLocation(
          latitude: 59.356,
          longitude: 18.019
        )
      }

      context("and user will authorize location usage") {
        it("requests authorization and proceeds with direction determination") {
          locationManager.willAuthorizeForWhenInUseUsage = true
          let determiner = ItineraryDirectionDeterminer(
            itinerary: itinerary,
            locationManager: locationManager
          )
          var didDetermineLocations = false

          waitUntil { done in
            determiner.determineBestDirection(
              completion: { _, _ in
                didDetermineLocations = true
                done()
              },
              error: { _ in
                fail("Error handler was unexpectedly called")
              }
            )
          }

          expect(locationManager.didRequestLocationWhenNotAuthorized).to(
            beFalse()
          )
          expect(didDetermineLocations).to(beTrue())
        }
      }

      context("and user will reject location usage") {
        it("requests authorization and returns locationUsageDenied error") {
          locationManager.willAuthorizeForWhenInUseUsage = false
          let determiner = ItineraryDirectionDeterminer(
            itinerary: itinerary,
            locationManager: locationManager
          )

          var error: ItineraryDirectionDeterminerError?
          waitUntil { done in
            determiner.determineBestDirection(
              completion: { _, _ in
                fail("Completion handler was unexpectedly called")
              },
              error: { returnedError in
                error = returnedError
                done()
              }
            )
          }

          expect(locationManager.didRequestLocationWhenNotAuthorized).to(
            beFalse()
          )
          expect(error).to(
            equal(ItineraryDirectionDeterminerError.locationUsageDenied)
          )
        }
      }
    }

    context("when CoreLocation access is denied by user") {
      beforeEach {
        locationManager.authorizationStatus = .denied
      }

      it("does no requests and returns locationUsageDenied error") {
        let determiner = ItineraryDirectionDeterminer(
          itinerary: itinerary,
          locationManager: locationManager
        )

        var error: ItineraryDirectionDeterminerError?
        waitUntil { done in
          determiner.determineBestDirection(
            completion: { _, _ in
              fail("Completion handler was unexpectedly called")
          },
            error: { returnedError in
              error = returnedError
              done()
          }
          )
        }

        expect(locationManager.didRequestLocationWhenNotAuthorized).to(
          beFalse()
        )
        expect(error).to(
          equal(ItineraryDirectionDeterminerError.locationUsageDenied)
        )
      }
    }
  }
}

} }
