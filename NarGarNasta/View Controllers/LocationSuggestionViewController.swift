import UIKit

protocol LocationSuggestionViewControllerDelegate {
    func locationSuggestionViewController(_ viewController: LocationSuggestionViewController, didSelectLocation location: Location)
}

class LocationSuggestionViewController: UITableViewController {
    var delegate: LocationSuggestionViewControllerDelegate?
    var suggestions: [Location] {
        didSet {
            tableView.reloadData()
        }
    }
    
    init(tableView: UITableView) {
        self.suggestions = []
        
        super.init(style: .plain)
        
        self.tableView = tableView
        tableView.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func awakeFromNib() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "suggestion") else {
            fatalError("Interface not configured")
        }
        cell.textLabel?.text = suggestions[indexPath.row].name
        cell.backgroundColor = UIColor.clear
        cell.backgroundView = UIView()
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.locationSuggestionViewController(self, didSelectLocation: suggestions[indexPath.row])
    }
}
