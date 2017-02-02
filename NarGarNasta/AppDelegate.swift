import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  let preferencesStore = PreferencesStore()

  static var shared: AppDelegate {
    guard let delegate = UIApplication.shared.delegate as? AppDelegate else {
      fatalError("App delegate not correctly in place.")
    }
    return delegate
  }
}
