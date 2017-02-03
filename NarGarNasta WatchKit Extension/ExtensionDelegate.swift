import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {
  let preferencesStore = PreferencesStore()

  static var shared: ExtensionDelegate {
    guard
      let delegate = WKExtension.shared().delegate as? ExtensionDelegate
    else {
      fatalError("Extension delegate not correctly in place.")
    }
    return delegate
  }

  // MARK: - WKExtensionDelegate

  func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
    for task in backgroundTasks {
      switch task {
      default:
        task.setTaskCompleted()
      }
    }
  }
}
