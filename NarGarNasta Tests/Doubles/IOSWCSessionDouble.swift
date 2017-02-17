import WatchConnectivity
@testable import NarGarNasta

enum IOSWCSessionDoubleError: Error {
  case usedWithoutFirstActivated
}

class IOSWCSessionDouble: WCSessionIOSProtocol {
  let isSupported: Bool
  let isWatchAppInstalled: Bool
  weak var delegate: WCSessionDelegate?

  private(set) var wasActivated = false
  private(set) var updateApplicationContextWasCalled = false
  private(set) var applicationContext: [String: Any]?

  init(isSupported: Bool = true, isWatchAppInstalled: Bool = true) {
    self.isSupported = isSupported
    self.isWatchAppInstalled = isWatchAppInstalled
  }

  func activate() {
    wasActivated = true
  }

  func updateApplicationContext(_ applicationContext: [String: Any]) throws {
    updateApplicationContextWasCalled = true
    guard wasActivated else {
      throw IOSWCSessionDoubleError.usedWithoutFirstActivated
    }
    self.applicationContext = applicationContext
  }
}
