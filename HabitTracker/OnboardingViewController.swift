import UIKit

final class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // MARK: - Инициализаторы
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Свойства
    
    private lazy var pages: [UIViewController] = {
        let first = OnboardingPageViewController(
            imageName: "OnboardingBackground_1",
            text: "Отслеживайте только то, что хотите"
        )
        let second = OnboardingPageViewController(
            imageName: "OnboardingBackground_2",
            text: "Даже если это не литры воды и йога"
        )
        return [first, second]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.3)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var okButton = UIButton.roundedButton(
        title: "Вот это технологии!",
        backgroundColor: .black,
        titleColor: .white,
        selector: #selector(okButtonTapped), target: self
    )
    
    // MARK: - Жизненный цикл
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        view.addSubview(pageControl)
        view.addSubview(okButton)
        
        okButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: okButton.topAnchor, constant: -40),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            okButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            okButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            okButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return pages.last
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return pages.first
        }
        
        return pages[nextIndex]
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
    
    // MARK: - Действия
    
    @objc private func okButtonTapped() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        let tabBarController = TabBarViewController()
        tabBarController.modalPresentationStyle = .fullScreen
        present(tabBarController, animated: true, completion: nil)
    }
}
