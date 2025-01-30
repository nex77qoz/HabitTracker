import UIKit

final class TabBarViewController: UITabBarController {

    let trackerVC = TrackerViewController()
    let statsVC = StatsViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }

    func setupTabBar() {
        let trackersNavController = UINavigationController(rootViewController: trackerVC)
        let statisticsNavController = UINavigationController(rootViewController: statsVC)
        
        trackersNavController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabTrackers", comment: ""),
            image: UIImage(named: "trackers"),
            tag: 0
        )
        statisticsNavController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabStatistics", comment: ""),
            image: UIImage(named: "stats"),
            tag: 1
        )

        viewControllers = [trackersNavController, statisticsNavController]
    }

    func showTabBar() {
        self.selectedIndex = 0
    }
}
