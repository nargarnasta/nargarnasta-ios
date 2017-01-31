import WatchKit
import Foundation
import WatchConnectivity

class ItineraryInterfaceController: WKInterfaceController, WCSessionDelegate {
    @IBOutlet var destinationLabel: WKInterfaceLabel!
    @IBOutlet var departureTimer: WKInterfaceTimer!
    @IBOutlet var departureTimerPlaceholderLabel: WKInterfaceLabel!
    @IBOutlet var arrivalTimeLabel: WKInterfaceLabel!
    
    var watchSession: WCSession?
    var itinerary: Itinerary?
    var upcomingTrips: UpcomingTrips?
    var updateTimer: Timer?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if WCSession.isSupported() {
            watchSession = WCSession.default()
            watchSession?.delegate = self
            watchSession?.activate()
        }
    }
    
    func updateInterface() {
        NSLog("Updating!")
        
        guard let itinerary = itinerary else {
            updateEmptyStateVisibility(empty: true)
            destinationLabel.setText("-")
            return
        }
        
        destinationLabel.setText("Till \(itinerary.location2.name)")
        
        guard let trips = upcomingTrips?.trips, trips.count > 0 else {
            updateEmptyStateVisibility(empty: true)
            return
        }
        
        updateEmptyStateVisibility(empty: false)
        
        departureTimer.setDate(trips.first!.departureTime)
        
        let arrivalTime = ItineraryInterfaceController.timeDateFormatter.string(from: trips.first!.arrivalTime)
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
    
    override func willActivate() {
        super.willActivate()
        
        self.upcomingTrips?.removePassedTrips()
        self.updateInterface()
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { timer in
            DispatchQueue.main.async {
                self.upcomingTrips?.removePassedTrips()
                self.updateInterface()
            }
        }
    }
    
    override func didDeactivate() {
        updateTimer?.invalidate()
        updateTimer = nil
        
        super.didDeactivate()
    }

    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        NSLog("Activation did complete, error (if any): \(error)")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        NSLog("Application context: \(applicationContext)")
        
        itinerary = Itinerary(dictionaryRepresentation: applicationContext["Itinerary"] as! [String: Any])
        
        upcomingTrips = UpcomingTrips(itinerary: itinerary!) {
            DispatchQueue.main.async {
                self.updateInterface()
            }
        }
        
        updateInterface()
    }
}
