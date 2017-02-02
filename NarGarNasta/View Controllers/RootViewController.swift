import UIKit

class RootViewController: UIPageViewController, UIPageViewControllerDataSource,
NewItineraryViewControllerDelegate {
  let preferencesStore: PreferencesStore
  var pageViewControllers: [UIViewController] = []

  required init?(coder: NSCoder) {
    preferencesStore = AppDelegate.shared.preferencesStore

    super.init(coder: coder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    dataSource = self
    populateViewControllers()

    if let backgroundImage = UIImage(named: "Background") {
      self.view.backgroundColor = UIColor(patternImage: backgroundImage)
    } else {
      NSLog("Could not find background image")
    }
  }

  private func populateViewControllers() {
    for itinerary in preferencesStore.itineraries {
      pageViewControllers.append(
        createItineraryViewController(itinerary: itinerary)
      )
    }

    guard
      let newItineraryViewController = UIStoryboard(name: "Main", bundle: nil)
        .instantiateViewController(withIdentifier: "newItinerary")
        as? NewItineraryViewController
      else {
        fatalError()
    }
    newItineraryViewController.delegate = self

    pageViewControllers.append(newItineraryViewController)

    guard let firstViewController = pageViewControllers.first else {
      fatalError()
    }

    setViewControllers(
      [firstViewController], direction: .forward, animated: false
    ) { _ in }
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

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  // MARK: - UIPageViewControllerDataSource

  func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerBefore viewController: UIViewController
  ) -> UIViewController? {
    guard let activeIndex = pageViewControllers.index(of: viewController) else {
      return nil
    }

    let index = activeIndex - 1
    guard index >= 0 else { return nil }

    return pageViewControllers[index]
  }

  func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerAfter viewController: UIViewController
  ) -> UIViewController? {
    guard let activeIndex = pageViewControllers.index(of: viewController) else {
      return nil
    }

    let index = activeIndex + 1
    guard index < pageViewControllers.count else { return nil }

    return pageViewControllers[index]
  }

  func presentationCount(for pageViewController: UIPageViewController) -> Int {
    return pageViewControllers.count
  }

  func presentationIndex(for pageViewController: UIPageViewController) -> Int {
    guard
      let activeViewController = pageViewController.viewControllers?.first,
      let activeIndex = pageViewControllers.index(of: activeViewController)
    else {
      return 0
    }

    return activeIndex
  }

  // MARK: - NewItineraryViewControllerDelegate

  func newItineraryViewController(
    _ viewController: NewItineraryViewController,
    didCreateItinerary itinerary: Itinerary
    ) {
    preferencesStore.itineraries.append(itinerary)

    let newViewController = createItineraryViewController(itinerary: itinerary)
    pageViewControllers.insert(
      newViewController,
      at: pageViewControllers.count - 1
    )

    setViewControllers(
      [newViewController], direction: .reverse, animated: true
    ) { _ in }
  }
}
