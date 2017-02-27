import Quick
import Nimble
import WatchConnectivity
@testable import NarGarNasta

class IOSPreferencesStoreSpec: QuickSpec { override func spec() {

describe("IOSPreferencesStore") {
  describe("init") {
    it("initializes with empty itineraries when nothing is set in iCloud") {
      let preferencesStore = IOSPreferencesStore(
        notificationCenter: NotificationCenter.default,
        keyValueStore: NSUbiquitousKeyValueStoreDouble(),
        watchSession: IOSWCSessionDouble()
      )

      expect(preferencesStore.itineraries).to(beEmpty())
    }

    it("synchronizes iCloud key-value store to pickup changes") {
      let keyValueStore = NSUbiquitousKeyValueStoreDouble()
      keyValueStore.valueDictionary = [
        "itineraries": [
          Itinerary(
            location1: Location.testLocationA,
            location2: Location.testLocationB
          ).dictionaryRepresentation()
        ]
      ]
      let updatedItinerary = Itinerary(
        location1: Location.testLocationB,
        location2: Location.testLocationC
      )
      keyValueStore.nextValueDictionary = [
        "itineraries": [
          updatedItinerary.dictionaryRepresentation()
        ]
      ]

      let preferencesStore = IOSPreferencesStore(
        notificationCenter: NotificationCenter.default,
        keyValueStore: keyValueStore,
        watchSession: IOSWCSessionDouble()
      )

      expect(preferencesStore.itineraries.first).to(equal(updatedItinerary))
    }
  }

  describe("updateItineraries(itineraries:)") {
    let keyValueStore = NSUbiquitousKeyValueStoreDouble()
    let watchSession = IOSWCSessionDouble()
    let preferencesStore = IOSPreferencesStore(
      notificationCenter: NotificationCenter.default,
      keyValueStore: keyValueStore,
      watchSession: watchSession
    )
    let itineraries = [
      Itinerary(
        location1: Location.testLocationA,
        location2: Location.testLocationB
      )
    ]

    it("updates itineraries property to provided value") {
      preferencesStore.updateItineraries(itineraries: itineraries)

      expect(preferencesStore.itineraries).to(equal(itineraries))
    }

    it("updates iCloud key-value storage") {
      preferencesStore.updateItineraries(itineraries: itineraries)

      let dictionaries = keyValueStore.array(forKey: "itineraries")
        as? [[String: Any]]
      let keyValueStoreItineraries = dictionaries?.map { dictionary in
        return Itinerary(dictionaryRepresentation: dictionary)
      }
      expect(keyValueStoreItineraries).to(equal(itineraries))
    }

    it("updates watch application context") {
      preferencesStore.updateItineraries(itineraries: itineraries)

      let dictionaries = watchSession.applicationContext?["itineraries"]
        as? [[String: Any]]
      let contextItineraries = dictionaries?.map { dictionary in
        return Itinerary(dictionaryRepresentation: dictionary)
      }
      expect(contextItineraries).to(equal(itineraries))
    }

    context("when Apple Watch is not supported") {
      let watchSession = IOSWCSessionDouble(isSupported: false)
      let _ = IOSPreferencesStore(
        notificationCenter: NotificationCenter.default,
        keyValueStore: keyValueStore,
        watchSession: watchSession
      )

      it("does not update watch application context") {
        preferencesStore.updateItineraries(itineraries: itineraries)

        expect(watchSession.updateApplicationContextWasCalled).to(beFalse())
      }
    }

    context("when watch app is not installed") {
      let watchSession = IOSWCSessionDouble(
        isSupported: true,
        isWatchAppInstalled: false
      )
      let _ = IOSPreferencesStore(
        notificationCenter: NotificationCenter.default,
        keyValueStore: keyValueStore,
        watchSession: watchSession
      )

      it("does not update watch application context") {
        preferencesStore.updateItineraries(itineraries: itineraries)

        expect(watchSession.updateApplicationContextWasCalled).to(beFalse())
      }
    }
  }

  describe("Notification observers") {
    describe("keyValueStoreDidUpdate(notification:)") {
      let notificationCenter = NotificationCenter.default
      let keyValueStore = NSUbiquitousKeyValueStoreDouble()
      let watchSession = IOSWCSessionDouble()
      let preferencesStore = IOSPreferencesStore(
        notificationCenter: notificationCenter,
        keyValueStore: keyValueStore,
        watchSession: watchSession
      )
      let itineraries = [
        Itinerary(
          location1: Location.testLocationA,
          location2: Location.testLocationB
        )
      ]

      beforeEach {
        keyValueStore.valueDictionary = [
          "itineraries": itineraries.map { $0.dictionaryRepresentation() }
        ]
      }

      it("updates itineraries property to provided value") {
        notificationCenter.post(
          name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
          object: keyValueStore
        )

        expect(preferencesStore.itineraries).to(equal(itineraries))
      }

      it("updates watch application context") {
        notificationCenter.post(
          name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
          object: keyValueStore
        )

        let dictionaries = watchSession.applicationContext?["itineraries"]
          as? [[String: Any]]
        let contextItineraries = dictionaries?.map { dictionary in
          return Itinerary(dictionaryRepresentation: dictionary)
        }
        expect(contextItineraries).to(equal(itineraries))
      }

      it("posts itineraryUpdatedNotification") {
        var notificationReceived = false

        waitUntil { done in
          notificationCenter.addObserver(
            forName: IOSPreferencesStore.itineraryUpdatedNotification,
            object: preferencesStore,
            queue: OperationQueue.main
          ) { _ in
            guard !notificationReceived else { return }
            notificationReceived = true
            done()
          }

          notificationCenter.post(
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: keyValueStore
          )

          expect(notificationReceived).to(beTrue())
        }
      }

      context("when Apple Watch is not supported") {
        let watchSession = IOSWCSessionDouble(isSupported: false)
        let _ = IOSPreferencesStore(
          notificationCenter: notificationCenter,
          keyValueStore: keyValueStore,
          watchSession: watchSession
        )

        it("does not update watch application context") {
          notificationCenter.post(
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: keyValueStore
          )

          expect(watchSession.updateApplicationContextWasCalled).to(beFalse())
        }
      }

      context("when watch app is not installed") {
        let watchSession = IOSWCSessionDouble(
          isSupported: true,
          isWatchAppInstalled: false
        )
        let _ = IOSPreferencesStore(
          notificationCenter: notificationCenter,
          keyValueStore: keyValueStore,
          watchSession: watchSession
        )

        it("does not update watch application context") {
          notificationCenter.post(
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: keyValueStore
          )

          expect(watchSession.updateApplicationContextWasCalled).to(beFalse())
        }
      }
    }
  }

  describe("WCSessionDelegate") {
    describe("sessionWatchStateDidChange(:)") {
      it("updates watch application context from current itineraries") {
        let keyValueStore = NSUbiquitousKeyValueStoreDouble()
        let itineraries = [
          Itinerary(
            location1: Location.testLocationA,
            location2: Location.testLocationB
          )
        ]
        keyValueStore.valueDictionary = [
          "itineraries": itineraries.map { $0.dictionaryRepresentation() }
        ]
        let watchSession = IOSWCSessionDouble()
        let preferencesStore = IOSPreferencesStore(
          notificationCenter: NotificationCenter.default,
          keyValueStore: keyValueStore,
          watchSession: watchSession
        )

        preferencesStore.sessionWatchStateDidChange(WCSession.default())

        let dictionaries = watchSession.applicationContext?["itineraries"]
          as? [[String: Any]]
        let contextItineraries = dictionaries?.map { dictionary in
          return Itinerary(dictionaryRepresentation: dictionary)
        }
        expect(contextItineraries).to(equal(itineraries))
      }
    }

    describe("session(:didReceiveMessage:)") {
      context("when message type is itinerariesRequest") {
        it("updates watch application context from current itineraries") {
          let keyValueStore = NSUbiquitousKeyValueStoreDouble()
          let itineraries = [
            Itinerary(
              location1: Location.testLocationA,
              location2: Location.testLocationB
            )
          ]
          keyValueStore.valueDictionary = [
            "itineraries": itineraries.map { $0.dictionaryRepresentation() }
          ]
          let watchSession = IOSWCSessionDouble()
          let preferencesStore = IOSPreferencesStore(
            notificationCenter: NotificationCenter.default,
            keyValueStore: keyValueStore,
            watchSession: watchSession
          )

          preferencesStore.session(
            WCSession.default(),
            didReceiveMessage: ["type": "itinerariesRequest"]
          )

          let dictionaries = watchSession.applicationContext?["itineraries"]
            as? [[String: Any]]
          let contextItineraries = dictionaries?.map { dictionary in
            return Itinerary(dictionaryRepresentation: dictionary)
          }
          expect(contextItineraries).to(equal(itineraries))
        }
      }
    }
  }
}

} }
