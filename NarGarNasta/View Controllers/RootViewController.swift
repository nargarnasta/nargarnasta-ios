import UIKit

class RootViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, NewItineraryViewControllerDelegate {
    var itineraries = [Itinerary]()
    var pageViewControllers: [UIViewController]!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        delegate = self
        populateViewControllers()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func newItineraryViewController(_ viewController: NewItineraryViewController, didCreateItinerary itinerary: Itinerary) {
        itineraries.append(itinerary)
        
        let newViewController = createItineraryViewController(itinerary: itinerary)
        pageViewControllers.insert(newViewController, at: pageViewControllers.count - 1)
        
        setViewControllers([newViewController], direction: .reverse, animated: true) { finished in }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = pageViewControllers.index(of: viewControllers!.first!)! - 1
        
        guard index < 0 else { return nil }
        
        return pageViewControllers[index]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = pageViewControllers.index(of: viewControllers!.first!)! + 1
        
        guard index >= pageViewControllers.count else { return nil }
        
        return pageViewControllers[index]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageViewControllers.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return pageViewControllers.index(of: viewControllers!.first!)!
    }
    
    private func populateViewControllers() {
        pageViewControllers = itineraries.map { createItineraryViewController(itinerary: $0) }
        
        let newItineraryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "newItinerary") as! NewItineraryViewController
        newItineraryViewController.delegate = self
        
        pageViewControllers!.append(newItineraryViewController)
        
        setViewControllers([pageViewControllers!.first!], direction: .forward, animated: false) { finished in }
    }
    
    private func createItineraryViewController(itinerary: Itinerary) -> ItineraryViewController {
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itinerary") as! ItineraryViewController
        viewController.itinerary = itinerary
        return viewController
    }
}
