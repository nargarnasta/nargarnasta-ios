import WatchConnectivity

class PreferencesStore: NSObject, WCSessionDelegate {
  var watchSession: WCSession?
  var itineraries: [Itinerary] {
    didSet {
      synchronize()
    }
  }

  override init() {
    self.itineraries = []

    super.init()

    if WCSession.isSupported() {
      watchSession = WCSession.default()
      watchSession?.delegate = self
      watchSession?.activate()
    }
  }

  func synchronize() {
    // TODO: Sync all itineraries to the watch app
    guard let itinerary = itineraries.last else {
      return
    }

    do {
      NSLog("Setting app context")
      try watchSession?.updateApplicationContext(
        [ "Itinerary": itinerary.dictionaryRepresentation() ]
      )
    } catch {
      NSLog("Updating watch context failed: \(error)")
    }
  }

  // MARK: - WCSessionDelegate

  func session(
    _ session: WCSession,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
    ) {
    NSLog("Activation did complete, error (if any): \(error)")
  }

  func sessionDidBecomeInactive(_ session: WCSession) { }
  func sessionDidDeactivate(_ session: WCSession) { }
}
