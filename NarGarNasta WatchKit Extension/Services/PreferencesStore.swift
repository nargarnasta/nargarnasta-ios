import WatchConnectivity

class PreferencesStore: NSObject, WCSessionDelegate {
  var watchSession: WCSession?
  var notificationCenter: NotificationCenter
  private(set) var itinerary: Itinerary?

  static let itineraryUpdatedNotificationName =
    Notification.Name("PreferencesStoreItineraryUpdatedNotification")

  override init() {
    notificationCenter = NotificationCenter.default

    super.init()

    if WCSession.isSupported() {
      watchSession = WCSession.default()
      watchSession?.delegate = self
      watchSession?.activate()
    }
  }

  // MARK: - WCSessionDelegate

  public func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
    ) {
    NSLog("Activation did complete, error (if any): \(error)")
  }

  func session(
    _ session: WCSession,
    didReceiveApplicationContext applicationContext: [String : Any]
    ) {
    NSLog("Application context: \(applicationContext)")

    guard
      let itineraryDictioinary = applicationContext["Itinerary"]
        as? [String: Any],
      let itinerary = Itinerary(dictionaryRepresentation: itineraryDictioinary)
      else {
        return
    }

    self.itinerary = itinerary

    notificationCenter.post(
      name: PreferencesStore.itineraryUpdatedNotificationName,
      object: self
    )
  }
}
