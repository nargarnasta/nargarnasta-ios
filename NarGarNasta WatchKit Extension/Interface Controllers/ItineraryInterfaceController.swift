import WatchKit
import Foundation

class ItineraryInterfaceController: WKInterfaceController {
  @IBOutlet var destinationLabel: WKInterfaceLabel!
  @IBOutlet var departureTimer: WKInterfaceTimer!
  @IBOutlet var departureTimerPlaceholderLabel: WKInterfaceLabel!
  @IBOutlet var arrivalTimeLabel: WKInterfaceLabel!

  var notificationCenter: NotificationCenter
  weak var preferencesStoreObserver: NSObjectProtocol?
  var preferencesStore: PreferencesStore
  var upcomingTrips: UpcomingTrips?
  var updateTimer: Timer?

  override init() {
    preferencesStore = ExtensionDelegate.shared.preferencesStore
    notificationCenter = NotificationCenter.default

    super.init()
  }

  func updateInterface() {
    NSLog("Updating!")

    guard let itinerary = preferencesStore.itinerary else {
      updateEmptyStateVisibility(empty: true)
      destinationLabel.setText("-")
      return
    }

    destinationLabel.setText("Till \(itinerary.location2.name)")

    guard
      let trips = upcomingTrips?.trips,
      let firstTrip = trips.first
    else {
      updateEmptyStateVisibility(empty: true)
      return
    }

    updateEmptyStateVisibility(empty: false)

    departureTimer.setDate(firstTrip.departureTime)

    let arrivalTime = ItineraryInterfaceController.timeDateFormatter.string(
      from: firstTrip.arrivalTime
    )
    arrivalTimeLabel.setText("Du är framme \(arrivalTime).")
  }

  private func updateEmptyStateVisibility(empty: Bool) {
    self.departureTimer.setHidden(empty)
    self.departureTimerPlaceholderLabel.setHidden(!empty)
  }

  static var timeDateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
  }

  private func updateItinerary(_ itinerary: Itinerary?) {
    if let itinerary = itinerary {
      upcomingTrips = UpcomingTrips(itinerary: itinerary) {
        DispatchQueue.main.async {
          self.updateInterface()
        }
      }
    } else {
      self.upcomingTrips = nil
    }
  }

  // MARK: - WKInterfaceController

  override func willActivate() {
    super.willActivate()

    if upcomingTrips?.itinerary != preferencesStore.itinerary {
      updateItinerary(preferencesStore.itinerary)
    }
    upcomingTrips?.removePassedTrips()
    updateInterface()

    updateTimer = Timer.scheduledTimer(
      withTimeInterval: 60, repeats: true
    ) { _ in
      self.upcomingTrips?.removePassedTrips()
      self.updateInterface()
    }

    preferencesStoreObserver = notificationCenter.addObserver(
      forName: PreferencesStore.itineraryUpdatedNotificationName,
      object: preferencesStore,
      queue: OperationQueue.main
    ) { _ in
      self.updateItinerary(self.preferencesStore.itinerary)
      self.updateInterface()
    }
  }

  override func didDeactivate() {
    updateTimer?.invalidate()
    updateTimer = nil

    if let preferencesStoreObserver = preferencesStoreObserver {
      notificationCenter.removeObserver(preferencesStoreObserver)
      self.preferencesStoreObserver = nil
    }

    super.didDeactivate()
  }
}
