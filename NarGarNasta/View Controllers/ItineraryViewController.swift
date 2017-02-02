import UIKit

class ItineraryViewController: UIViewController, UITableViewDataSource {
  var itinerary: Itinerary!
  let tripSearcher = TripSearcher()
  var trips: [Trip]?
  var timer: Timer?
  @IBOutlet weak var nextDepartureMinutesRemainingLabel: UILabel!
  @IBOutlet weak var nextDepartureArrivalTime: UILabel!
  @IBOutlet weak var subsequentTripsTableView: UITableView!
  @IBOutlet weak var departureLocation: UILabel!
  @IBOutlet weak var arrivalLocation: UILabel!
  @IBOutlet weak var minutesLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.nextDepartureMinutesRemainingLabel.text = "-"
    self.nextDepartureArrivalTime.text = ""
    subsequentTripsTableView.backgroundColor = UIColor.clear
    subsequentTripsTableView.tableFooterView = UIView()

    if let backgroundImage = UIImage(named: "Background") {
      self.view.backgroundColor = UIColor(patternImage: backgroundImage)
    } else {
      NSLog("Could not find background image")
    }

    departureLocation.text = itinerary.location1.name
    arrivalLocation.text = itinerary.location2.name

    tripSearcher.search(
      origin: itinerary.location1,
      destination: itinerary.location2
    ) { trips in
      self.trips = trips

      DispatchQueue.main.async {
        self.updateLabels()
      }
    }
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    timer = Timer.scheduledTimer(
      withTimeInterval: 60.0, repeats: true
    ) { _ in
      DispatchQueue.main.async {
        let firstUpcomingIndex: Int
        if
          let index = self.trips?.index(where: { $0.departureTime >= Date() })
        {
          firstUpcomingIndex = index
        } else {
          firstUpcomingIndex = 0
        }
        if let trips = self.trips {
          self.trips = Array(trips.suffix(from: firstUpcomingIndex))
        }
        self.updateLabels()
      }
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    timer?.invalidate()
    timer = nil
  }

  func updateLabels() {
    if let trips = trips, let firstTrip = trips.first {
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

  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }

  func tableView(
    _ tableView: UITableView, numberOfRowsInSection section: Int
  ) -> Int {
    guard let trips = trips else { return 0 }
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

    guard let trips = trips else { return cell }

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
