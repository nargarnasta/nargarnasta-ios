import UIKit
import WatchConnectivity

protocol NewItineraryViewControllerDelegate {
    func newItineraryViewController(_ viewController: NewItineraryViewController, didCreateItinerary itinerary: Itinerary)
}

class NewItineraryViewController: UIViewController, LocationSuggestionViewControllerDelegate, WCSessionDelegate {
    var delegate: NewItineraryViewControllerDelegate?
    let locationSearcher = LocationSearcher()
    @IBOutlet var location1Field: UITextField?
    @IBOutlet var location2Field: UITextField?
    @IBOutlet var location1SuggestionsView: UITableView?
    @IBOutlet var location2SuggestionsView: UITableView?
    var location1SuggestionsViewController: LocationSuggestionViewController!
    var location2SuggestionsViewController: LocationSuggestionViewController!
    var location1: Location?
    var location2: Location?
    var watchSession: WCSession?
    
    override func awakeFromNib() {
        if WCSession.isSupported() {
            watchSession = WCSession.default()
            watchSession?.delegate = self
            watchSession?.activate()
        }
    }
    
    public func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        NSLog("Activation did complete, error (if any): \(error)")
    }
    
    public func sessionDidBecomeInactive(_ session: WCSession) {
        
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let location1SuggestionsView = location1SuggestionsView, let location2SuggestionsView = location2SuggestionsView else {
            fatalError("Interface not configured correctly")
        }
        
        location1SuggestionsViewController = LocationSuggestionViewController(tableView: location1SuggestionsView)
        location1SuggestionsViewController.delegate = self
        location2SuggestionsViewController = LocationSuggestionViewController(tableView: location2SuggestionsView)
        location2SuggestionsViewController.delegate = self
        
        //[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"foo.bar"]]];
        self.view.backgroundColor = UIColor.init(patternImage: UIImage.init(named: "Background")!)
        
//        UIView.transition(with: location1SuggestionsView, duration: 0.4, options: .curveEaseInOut, animations: { 
//            location1SuggestionsView.isHidden = true
//        }) { completed in
//            
//        }
    }
    
    func locationSuggestionViewController(_ viewController: LocationSuggestionViewController, didSelectLocation location: Location) {
        switch viewController {
        case location1SuggestionsViewController:
            location1 = location
            location1Field?.text = location.name
        case location2SuggestionsViewController:
            location2 = location
            location2Field?.text = location.name
        default:
            return
        }
        
        guard let location1 = location1 else {
            location1Field?.becomeFirstResponder()
            return
        }
        
        guard let location2 = location2 else {
            location2Field?.becomeFirstResponder()
            return
        }
        
        let itinerary = Itinerary(location1: location1, location2: location2)
        do {
            NSLog("Setting app context")
            try watchSession?.updateApplicationContext([ "Itinerary": itinerary.dictionaryRepresentation() ])
        } catch {
            NSLog("Updating watch context failed: \(error)")
        }
        delegate?.newItineraryViewController(self, didCreateItinerary: itinerary)
    }
    
    @IBAction func locationValueChanged(_ sender: UITextField) {
        guard let query = sender.text, query.characters.count > 1 else {
            NSLog("No query")
            return
        }
        
        locationSearcher.search(query: query) { locations in
            DispatchQueue.main.async {
                switch sender {
                case self.location1Field!:
                    self.location1SuggestionsViewController.suggestions = locations
                case self.location2Field!:
                    self.location2SuggestionsViewController.suggestions = locations
                default: break
                }
            }
        }
    }
}
