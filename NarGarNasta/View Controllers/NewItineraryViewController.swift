import UIKit

protocol NewItineraryViewControllerDelegate: class {
  func newItineraryViewController(
    _ viewController: NewItineraryViewController,
    didCreateItinerary itinerary: Itinerary
  )
}

class NewItineraryViewController: UIViewController,
LocationSuggestionViewControllerDelegate {
  weak var notificationCenter: NotificationCenter?
  weak var application: UIApplication?
  weak var delegate: NewItineraryViewControllerDelegate?
  let locationSearcher = LocationSearcher()

  var location1SuggestionsViewController: LocationSuggestionViewController!
  var location2SuggestionsViewController: LocationSuggestionViewController!
  var location1: Location?
  var location2: Location?

  @IBOutlet weak var introductionView: UIView!
  @IBOutlet weak var introductionViewTopSpaceConstraint: NSLayoutConstraint!
  @IBOutlet var location1Field: UITextField!
  @IBOutlet var location2Field: UITextField!
  @IBOutlet var location1SuggestionsView: UITableView!
  @IBOutlet var location2SuggestionsView: UITableView!
  @IBOutlet var location1SuggestionsHeightConstraint: NSLayoutConstraint!
  @IBOutlet var location2SuggestionsHeightConstraint: NSLayoutConstraint!
  @IBOutlet var bottomConstraint: NSLayoutConstraint!

  required init?(coder aDecoder: NSCoder) {
    notificationCenter = NotificationCenter.default
    application = UIApplication.shared

    super.init(coder: aDecoder)
  }

  func keyboardWillShow(notification: Notification) {
    guard
      let curveRawValue =
        notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Int,
      let curve = UIViewAnimationCurve(rawValue: curveRawValue),
      let keyboardFrame =
        (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?
          .cgRectValue,
      let duration =
        notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]
          as? TimeInterval
    else {
      return
    }

    UIView.beginAnimations(nil, context: nil)
    UIView.setAnimationDuration(duration)
    UIView.setAnimationCurve(curve)

    self.bottomConstraint.constant =
      -keyboardMargin(keyboardHeight: keyboardFrame.height)

    if !introductionView.isHidden {
      self.introductionView.alpha = 0
      self.introductionViewTopSpaceConstraint.constant
        = -self.introductionView.frame.height
    }

    self.view.layoutIfNeeded()

    UIView.commitAnimations()
  }

  @IBAction func locationValueChanged(_ sender: UITextField) {
    guard let query = sender.text, query.characters.count > 1 else {
      return
    }

    locationSearcher.search(query: query) { locations in
      DispatchQueue.main.async {
        UIView.animate(withDuration: 0.25) {
          switch sender {
          case self.location1Field:
            self.location1SuggestionsViewController.suggestions = locations
            self.location1SuggestionsHeightConstraint.isActive = false
          case self.location2Field:
            self.location2SuggestionsViewController.suggestions = locations
            self.location2SuggestionsHeightConstraint.isActive = false
          default: break
          }

          self.view.layoutIfNeeded()
        }
      }
    }
  }

  @IBAction func editingDidEnd(_ sender: UITextField) {
    UIView.animate(withDuration: 0.25) {
      switch sender {
      case self.location1Field:
        self.location1SuggestionsHeightConstraint.isActive = true
      case self.location2Field:
        self.location2SuggestionsHeightConstraint.isActive = true
      default: break
      }

      self.view.layoutIfNeeded()
    }
  }

  private func keyboardMargin(keyboardHeight: CGFloat) -> CGFloat {
    guard
      let rootView = application?.keyWindow?.rootViewController?.view
    else {
      fatalError("Can't calculate margin for keyboard without root view")
    }

    let localBottomPoint = CGPoint(x: view.frame.minX, y: view.frame.maxY)
    let bottomPointInWindow = view.convert(localBottomPoint, to: rootView)
    return keyboardHeight - (rootView.frame.size.height - bottomPointInWindow.y)
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    self.view.backgroundColor = UIColor.clear

    guard
      let location1SuggestionsView = location1SuggestionsView,
      let location2SuggestionsView = location2SuggestionsView
    else {
      fatalError("Interface not configured correctly")
    }

    location1SuggestionsViewController =
      LocationSuggestionViewController(tableView: location1SuggestionsView)
    location1SuggestionsViewController.delegate = self
    location2SuggestionsViewController =
      LocationSuggestionViewController(tableView: location2SuggestionsView)
    location2SuggestionsViewController.delegate = self
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    notificationCenter?.addObserver(
      self,
      selector: #selector(keyboardWillShow(notification:)),
      name: .UIKeyboardWillShow,
      object: nil
    )
  }

  override func viewWillDisappear(_ animated: Bool) {
    notificationCenter?.removeObserver(
      self,
      name: .UIKeyboardWillShow,
      object: nil
    )

    super.viewWillDisappear(animated)
  }

  // MARK: - LocationSuggestionViewControllerDelegate

  func locationSuggestionViewController(
    _ viewController: LocationSuggestionViewController,
    didSelectLocation location: Location
  ) {
    switch viewController {
    case location1SuggestionsViewController:
      location1 = location
      location1Field.text = location.name
    case location2SuggestionsViewController:
      location2 = location
      location2Field.text = location.name
    default:
      return
    }

    guard let location1 = location1 else {
      location1Field.becomeFirstResponder()
      return
    }

    guard let location2 = location2 else {
      location2Field.becomeFirstResponder()
      return
    }

    let itinerary = Itinerary(location1: location1, location2: location2)
    delegate?.newItineraryViewController(self, didCreateItinerary: itinerary)
  }
}
