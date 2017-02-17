import WatchConnectivity

protocol WCSessionDelegateIOSProtocol: class {
  func session(
    _ session: WCSessionIOSProtocol,
    activationDidCompleteWith activationState: WCSessionActivationState,
    error: Error?
  )
  func sessionDidBecomeInactive(_ session: WCSessionIOSProtocol)
  func sessionDidDeactivate(_ session: WCSessionIOSProtocol)
}

protocol WCSessionIOSProtocol: class {
  var isSupported: Bool { get }
  weak var delegate: WCSessionDelegate? { get set }
  var isWatchAppInstalled: Bool { get }
  func activate()
  func updateApplicationContext(_ applicationContext: [String : Any]) throws
}

extension WCSession: WCSessionIOSProtocol {
  var isSupported: Bool {
    return WCSession.isSupported()
  }
}
