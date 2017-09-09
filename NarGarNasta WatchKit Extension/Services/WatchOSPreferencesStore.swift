import WatchConnectivity

class WatchOSPreferencesStore: NSObject, WCSessionDelegate {
  static let itinerariesStoreKey = "itineraries"
  static let itineraryUpdatedNotificationName =
    Notification.Name("PreferencesStoreItineraryUpdatedNotification")

  private var watchSession: WCSession?
  private var notificationCenter: NotificationCenter
  private let keyValueStore: UserDefaults

  private(set) var itineraries: [Itinerary]

  override init() {
    notificationCenter = NotificationCenter.default
    keyValueStore = UserDefaults.standard

    self.itineraries = WatchOSPreferencesStore.itinerariesFromStore(keyValueStore: keyValueStore)

    super.init()

    let watchSession = WCSession.default
    watchSession.delegate = self
    watchSession.activate()
    self.watchSession = watchSession
  }

  private static func itinerariesFromStore(keyValueStore: UserDefaults) -> [Itinerary] {
    if let itineraryDictionaries = keyValueStore.array(
      forKey: WatchOSPreferencesStore.itinerariesStoreKey
    ) as? [[String: Any]] {
      return itineraryDictionaries.flatMap { dictionary in
        return Itinerary(dictionaryRepresentation: dictionary)
      }
    } else {
      return []
    }
  }

  // MARK: - WCSessionDelegate

  public func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  ) {
    NSLog("Activation did complete, error (if any): \(String(describing: error))")

    self.watchSession?.sendMessage(
      ["type": "itinerariesRequest"],
      replyHandler: nil,
      errorHandler: nil
    )
  }

  func session(
    _ session: WCSession,
    didReceiveApplicationContext applicationContext: [String : Any]
  ) {
    guard
      let dictionaries =
        applicationContext[WatchOSPreferencesStore.itinerariesStoreKey] as? [[String: Any]]
    else {
      return
    }

    keyValueStore.set(dictionaries, forKey: WatchOSPreferencesStore.itinerariesStoreKey)

    self.itineraries = dictionaries.flatMap { dictionary in
      return Itinerary(dictionaryRepresentation: dictionary)
    }

    notificationCenter.post(
      name: WatchOSPreferencesStore.itineraryUpdatedNotificationName,
      object: self
    )
  }
}
