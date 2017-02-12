import UIKit

protocol ItineraryCardViewControllerDelegate: class {
  func itineraryCardViewController(
    _ viewController: ItineraryCardViewController,
    didCreateItinerary itinerary: Itinerary
  )
}

class ItineraryCardViewController: UIViewController,
NewItineraryViewControllerDelegate {
  weak var delegate: ItineraryCardViewControllerDelegate?
  var itinerary: Itinerary?

  private func transitionToItinerary(itinerary: Itinerary) {
    self.itinerary = itinerary

    guard let newItineraryViewController = childViewControllers.first else {
      fatalError("Can't transition from nothing.")
    }

    let itineraryViewController = createItineraryViewController(
      itinerary: itinerary
    )

    newItineraryViewController.willMove(toParentViewController: nil)
    addChildViewController(itineraryViewController)

    transition(
      from: newItineraryViewController,
      to: itineraryViewController,
      duration: 0.4,
      options: [.transitionFlipFromLeft, .curveLinear],
      animations: { },
      completion: { _ in
        newItineraryViewController.removeFromParentViewController()
        itineraryViewController.didMove(toParentViewController: self)
      }
    )
  }

  private func createNewItineraryViewController()
    -> NewItineraryViewController {
      guard
        let newItineraryViewController = UIStoryboard(name: "Main", bundle: nil)
          .instantiateViewController(withIdentifier: "newItinerary")
          as? NewItineraryViewController
      else {
        fatalError()
      }
      newItineraryViewController.delegate = self
      return newItineraryViewController
  }

  private func createItineraryViewController(itinerary: Itinerary)
    -> ItineraryViewController {
      guard
        let viewController = UIStoryboard(name: "Main", bundle: nil)
          .instantiateViewController(withIdentifier: "itinerary")
          as? ItineraryViewController
      else {
        fatalError()
      }

      viewController.itinerary = itinerary
      return viewController
  }

  // MARK: - UIViewController

  override func awakeFromNib() {
    let viewController: UIViewController
    if let itinerary = itinerary {
      viewController = createItineraryViewController(itinerary: itinerary)
    } else {
      viewController = createNewItineraryViewController()
    }

    addChildViewController(viewController)
    view.addSubview(viewController.view)
    viewController.didMove(toParentViewController: self)

    super.awakeFromNib()
  }

  // MARK: - NewItineraryViewControllerDelegate

  func newItineraryViewController(
    _ viewController: NewItineraryViewController,
    didCreateItinerary itinerary: Itinerary
  ) {
    transitionToItinerary(itinerary: itinerary)

    delegate?.itineraryCardViewController(self, didCreateItinerary: itinerary)
  }
}
