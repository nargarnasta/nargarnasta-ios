import Foundation
import WatchConnectivity

class IOSPreferencesStore: NSObject, WCSessionDelegate {
  static let itinerariesStoreKey = "itineraries"
  static let itineraryUpdatedNotification =
    Notification.Name("PreferencesStoreItineraryUpdatedNotification")

  private let watchSession: WCSessionIOSProtocol
  private let notificationCenter: NotificationCenter
  private let keyValueStore: NSUbiquitousKeyValueStoreProtocol

  private(set) var itineraries: [Itinerary]

  init(
    notificationCenter: NotificationCenter = NotificationCenter.default,
    keyValueStore: NSUbiquitousKeyValueStoreProtocol =
      NSUbiquitousKeyValueStore.default(),
    watchSession: WCSessionIOSProtocol = WCSession.default()
  ) {
    self.notificationCenter = notificationCenter
    self.keyValueStore = keyValueStore
    self.watchSession = watchSession

    let _ = self.keyValueStore.synchronize()

    self.itineraries = IOSPreferencesStore.itinerariesFromStore(
      keyValueStore: keyValueStore
    )

    super.init()

    notificationCenter.addObserver(
      self,
      selector: #selector(keyValueStoreDidUpdate(notification:)),
      name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
      object: keyValueStore
    )

    if watchSession.isSupported {
      watchSession.delegate = self
      watchSession.activate()
    }
  }

  func updateItineraries(itineraries: [Itinerary]) {
    self.itineraries = itineraries

    keyValueStore.set(
      itineraries.map { $0.dictionaryRepresentation() },
      forKey: IOSPreferencesStore.itinerariesStoreKey
    )

    sendItinerariesToWatch()
  }

  private func sendItinerariesToWatch() {
    guard watchSession.isSupported && watchSession.isWatchAppInstalled else {
      return
    }

    do {
      try watchSession.updateApplicationContext(
        [
          IOSPreferencesStore.itinerariesStoreKey:
            itineraries.map { $0.dictionaryRepresentation() }
        ]
      )
    } catch {
      NSLog("Updating watch context failed: \(error)")
    }
  }

  private static func itinerariesFromStore(
    keyValueStore: NSUbiquitousKeyValueStoreProtocol
  ) -> [Itinerary] {
    if
      let itineraryDictionaries = keyValueStore.array(
        forKey: IOSPreferencesStore.itinerariesStoreKey
      ) as? [[String: Any]]
    {
      return itineraryDictionaries.flatMap { dictionary in
        return Itinerary(dictionaryRepresentation: dictionary)
      }
    } else {
      return []
    }
  }

  // MARK: - Notification observers

  func keyValueStoreDidUpdate(notification: NSNotification) {
    updateItineraries(
      itineraries: IOSPreferencesStore.itinerariesFromStore(
        keyValueStore: keyValueStore
      )
    )

    notificationCenter.post(
      name: IOSPreferencesStore.itineraryUpdatedNotification,
      object: self
    )
  }

  // MARK: - WCSessionDelegate

  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {}
  func sessionDidBecomeInactive(_ session: WCSession) {}
  func sessionDidDeactivate(_ session: WCSession) {}

  func sessionWatchStateDidChange(_ session: WCSession) {
    sendItinerariesToWatch()
  }
}
