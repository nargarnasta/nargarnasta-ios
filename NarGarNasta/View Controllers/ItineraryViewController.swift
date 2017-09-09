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

  static var timeFormatter: DateFormatter {
    let formatter = DateFormatter()
    formatter.dateStyle = .none
    formatter.timeStyle = .short
    return formatter
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    subsequentTripsTableView.backgroundColor = UIColor.clear
    subsequentTripsTableView.tableFooterView = UIView()
    self.view.backgroundColor = UIColor.clear

    setItinerary(origin: itinerary.destinationA, destination: itinerary.destinationB)
    directionDeterminer = ItineraryDirectionDeterminer(itinerary: itinerary)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    let timer = Timer(fire: nextMinute(), interval: 60.0, repeats: true) { _ in
      self.upcomingTrips?.update()
      self.updateTripLabels()
    }
    self.timer = timer
    RunLoop.main.add(timer, forMode: RunLoopMode.defaultRunLoopMode)

    directionDeterminer?.determineBestDirection(
      completion: { origin, destination in
        DispatchQueue.main.async {
          self.setItinerary(origin: origin, destination: destination)
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

  private func setItinerary(origin: Location, destination: Location) {
    guard upcomingTrips?.origin != origin else { return }

    departureLocation.text = origin.name
    arrivalLocation.text = destination.name

    upcomingTrips = UpcomingTrips(
      origin: itinerary.destinationA,
      destination: itinerary.destinationB
    ) {
      DispatchQueue.main.async {
        self.updateTripLabels()
      }
    }

    updateTripLabels()
  }

  private func updateTripLabels() {
    if let trips = upcomingTrips?.trips, let firstTrip = trips.first {
      self.nextDepartureMinutesRemainingLabel.text = minutesRemaining(to: firstTrip.departureTime)
      self.nextDepartureArrivalTime.text = arrivalDescription(date: firstTrip.arrivalTime)
    } else {
      self.nextDepartureMinutesRemainingLabel.text = "-"
      self.nextDepartureArrivalTime.text = ""
    }

    self.minutesLabel.isHidden = self.nextDepartureMinutesRemainingLabel.text == "Nu"

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
    let arrivalTime = ItineraryViewController.timeFormatter.string(from: date)
    return "Du är framme \(arrivalTime)."
  }

  private func nextMinute() -> Date {
    guard let nextMinute = Calendar.current.date(bySetting: .second, value: 0, of: Date()) else {
      fatalError()
    }

    return nextMinute
  }

  // MARK: - UITableViewDataSource

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let trips = upcomingTrips?.trips else { return 0 }
    return trips.count - 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = subsequentTripsTableView.dequeueReusableCell(withIdentifier: "trip") else {
      fatalError(
        "Couldn't dequeue cell with identifier trip, interface is not configured correctly"
      )
    }

    guard let trips = upcomingTrips?.trips else { return cell }

    let trip = trips[indexPath.row + 1]
    cell.textLabel?.text = "Avgång om \(minutesRemaining(to: trip.departureTime))"
    cell.detailTextLabel?.text = arrivalDescription(date: trip.arrivalTime)

    cell.backgroundColor = UIColor.clear
    cell.backgroundView = UIView()
    let backgroundView = UIView()
    backgroundView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
    cell.selectedBackgroundView = backgroundView

    return cell
  }
}
