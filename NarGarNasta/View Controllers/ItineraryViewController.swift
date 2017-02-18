import UIKit

class ItineraryViewController: UIViewController, UITableViewDataSource {
  var itinerary: Itinerary!
  var upcomingTrips: UpcomingTrips?
  var directionDeterminer: ItineraryDirectionDeterminer?
  var timer: Timer?
  @IBOutlet weak var nextDepartureMinutesRemainingLabel: UILabel!
  @IBOutlet weak var nextDepartureArrivalTime: UILabel!
  @IBOutlet weak var subsequentTripsTableView: UITableView!
  @IBOutlet weak var departureLocation: UILabel!
  @IBOutlet weak var arrivalLocation: UILabel!
  @IBOutlet weak var minutesLabel: UILabel!

  func updateLabels() {
    if let trips = upcomingTrips?.trips, let firstTrip = trips.first {
      self.nextDepartureMinutesRemainingLabel.text =
        minutesRemaining(to: firstTrip.departureTime)
      self.minutesLabel.isHidden =
        self.nextDepartureMinutesRemainingLabel.text == "Nu"
      self.nextDepartureArrivalTime.text =
        arrivalDescription(date: firstTrip.arrivalTime)
    }

    subsequentTripsTableView.reloadData()
  }

  private func minutesRemaining(to date: Date) -> String {
    let minutesRemaining = date.timeIntervalSinceNow / 60
    if minutesRemaining < 1 {
      return "Nu"
    } else {
      return "\(Int(minutesRemaining))"
    }
  }

  private func arrivalDescription(date: Date) -> String {
    let arrivalTime =
      ItineraryViewController.timeDateFormatter.string(from: date)
    return "Du är framme \(arrivalTime)."
  }

  static var timeDateFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
  }

  private func updateItinerary(origin: Location, destination: Location) {
    guard upcomingTrips?.origin != origin else {
      return
    }

    self.nextDepartureMinutesRemainingLabel.text = "-"
    self.nextDepartureArrivalTime.text = ""

    departureLocation.text = origin.name
    arrivalLocation.text = destination.name

    upcomingTrips = UpcomingTrips(
      origin: itinerary.location1,
      destination: itinerary.location2
    ) {
      DispatchQueue.main.async {
        self.updateLabels()
      }
    }

    subsequentTripsTableView.reloadData()
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    subsequentTripsTableView.backgroundColor = UIColor.clear
    subsequentTripsTableView.tableFooterView = UIView()
    self.view.backgroundColor = UIColor.clear

    updateItinerary(
      origin: itinerary.location1,
      destination: itinerary.location2
    )
    directionDeterminer = ItineraryDirectionDeterminer(itinerary: itinerary)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    timer = Timer.scheduledTimer(
      withTimeInterval: 60.0, repeats: true
    ) { _ in
      DispatchQueue.main.async {
        self.upcomingTrips?.removePassedTrips()
        self.updateLabels()
      }
    }

    directionDeterminer?.determineBestDirection(
      completion: { origin, destination in
        DispatchQueue.main.async {
          self.updateItinerary(origin: origin, destination: destination)
        }
      },
      error: { error in }
    )
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    timer?.invalidate()
    timer = nil
  }

  // MARK: - UITableViewDataSource

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(
    _ tableView: UITableView, numberOfRowsInSection section: Int
  ) -> Int {
    guard let trips = upcomingTrips?.trips else { return 0 }
    return trips.count - 1
  }

  func tableView(
    _ tableView: UITableView, cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    guard
      let cell = subsequentTripsTableView.dequeueReusableCell(
        withIdentifier: "trip"
      )
    else {
      fatalError(
        "Couldn't dequeue cell with identifier trip, interface is not " +
        "configured correctly"
      )
    }

    guard let trips = upcomingTrips?.trips else { return cell }

    let trip = trips[indexPath.row + 1]
    cell.textLabel?.text =
      "Avgång om \(minutesRemaining(to: trip.departureTime))"
    cell.detailTextLabel?.text = arrivalDescription(date: trip.arrivalTime)

    cell.backgroundColor = UIColor.clear
    cell.backgroundView = UIView()
    let backgroundView = UIView()
    backgroundView.backgroundColor = UIColor(
      red: 1, green: 1, blue: 1, alpha: 0.2
    )
    cell.selectedBackgroundView = backgroundView

    return cell
  }
}
