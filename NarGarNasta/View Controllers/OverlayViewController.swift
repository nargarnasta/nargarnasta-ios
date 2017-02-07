import UIKit

class OverlayViewController: UIViewController {
  var rootViewController: RootViewController?

  @IBAction func addButtonPressed(_ sender: UIButton) {
    rootViewController?.showNewItineraryViewController()
  }

  // MARK: - UIViewController

  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    switch segue.identifier {
    case "embedRootViewController"?:
      rootViewController = segue.destination as? RootViewController
    default: break
    }
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
}
