import Foundation
import WatchConnectivity

class IOSPreferencesStore: NSObject, WCSessionDelegate {
  static let itinerariesStoreKey = "itineraries"
  static let itineraryUpdatedNotificationName =
    Notification.Name("PreferencesStoreItineraryUpdatedNotification")

  private var watchSession: WCSession?
  private let notificationCenter: NotificationCenter
  private let keyValueStore: NSUbiquitousKeyValueStore

  private(set) var itineraries: [Itinerary]

  override init() {
    notificationCenter = NotificationCenter.default
    keyValueStore = NSUbiquitousKeyValueStore.default()

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

    if WCSession.isSupported() {
      let watchSession = WCSession.default()
      watchSession.delegate = self
      watchSession.activate()
      self.watchSession = watchSession
    }
  }

  func updateItineraries(itineraries: [Itinerary]) {
    self.itineraries = itineraries

    synchronize()
  }

  func synchronize() {
    keyValueStore.set(
      itineraries.map { $0.dictionaryRepresentation() },
      forKey: IOSPreferencesStore.itinerariesStoreKey
    )
    keyValueStore.synchronize()

    synchronizeWatch()
  }

  func synchronizeWatch() {
    guard watchSession?.isWatchAppInstalled ?? false else {
      return
    }

    do {
      try watchSession?.updateApplicationContext(
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
    keyValueStore: NSUbiquitousKeyValueStore
    ) -> [Itinerary] {
    if let itineraryDictionaries = keyValueStore.array(
      forKey: IOSPreferencesStore.itinerariesStoreKey
      ) as? [[String: Any]] {
      return itineraryDictionaries.flatMap { dictionary in
        return Itinerary(dictionaryRepresentation: dictionary)
      }
    } else {
      return []
    }
  }

  // MARK: - Notification observers

  func keyValueStoreDidUpdate(notification: NSNotification) {
    itineraries = IOSPreferencesStore.itinerariesFromStore(
      keyValueStore: keyValueStore
    )

    notificationCenter.post(
      name: IOSPreferencesStore.itineraryUpdatedNotificationName,
      object: self
    )
  }

  // MARK: - WCSessionDelegate

  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    synchronizeWatch()
  }

  func sessionDidBecomeInactive(_ session: WCSession) { }
  func sessionDidDeactivate(_ session: WCSession) { }
}
