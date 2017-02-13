import UIKit

class RootViewController: UIPageViewController, UIPageViewControllerDataSource,
ItineraryCardViewControllerDelegate {
  let preferencesStore: IOSPreferencesStore
  var pageViewControllers: [ItineraryCardViewController] = []

  required init?(coder: NSCoder) {
    preferencesStore = AppDelegate.shared.preferencesStore

    super.init(coder: coder)
  }

  func showNewItineraryViewController() {
    if
      pageViewControllers.contains(where: { $0.itinerary == nil })
    {
      return
    }

    let viewController = createItineraryCardViewController(itinerary: nil)
    pageViewControllers.append(viewController)

    setViewControllers(
      [viewController], direction: .forward, animated: true
    ) { _ in }
  }

  private func populateViewControllers() {
    for itinerary in preferencesStore.itineraries {
      pageViewControllers.append(
        createItineraryCardViewController(itinerary: itinerary)
      )
    }

    if pageViewControllers.isEmpty {
      pageViewControllers.append(
        createItineraryCardViewController(itinerary: nil)
      )
    }

    guard let firstViewController = pageViewControllers.first else {
      fatalError()
    }

    setViewControllers(
      [firstViewController], direction: .forward, animated: false
    ) { _ in }
  }

  private func createItineraryCardViewController(itinerary: Itinerary?)
    -> ItineraryCardViewController {
    guard
      let viewController = UIStoryboard(name: "Main", bundle: nil)
        .instantiateViewController(withIdentifier: "itineraryCard")
        as? ItineraryCardViewController
    else {
      fatalError()
    }

    viewController.itinerary = itinerary
    viewController.delegate = self
    return viewController
  }

  // MARK: - UIViewController

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

  // MARK: - UIPageViewControllerDataSource

  func pageViewController(
    _ pageViewController: UIPageViewController,
    viewControllerBefore viewController: UIViewController
  ) -> UIViewController? {
    guard
      let viewController = viewController as? ItineraryCardViewController,
      let activeIndex = pageViewControllers.index(of: viewController)
    else {
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
    guard
      let viewController = viewController as? ItineraryCardViewController,
      let activeIndex = pageViewControllers.index(of: viewController)
    else {
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
      let activeViewController = pageViewController.viewControllers?.first
        as? ItineraryCardViewController,
      let activeIndex = pageViewControllers.index(of: activeViewController)
    else {
      return 0
    }

    return activeIndex
  }

  // MARK: - ItineraryCardViewControllerDelegate

  func itineraryCardViewController(
    _ viewController: ItineraryCardViewController,
    didCreateItinerary itinerary: Itinerary
  ) {
    var itineraries = preferencesStore.itineraries
    itineraries.append(itinerary)

    preferencesStore.updateItineraries(itineraries: itineraries)
  }
}
