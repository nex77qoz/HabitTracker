//
//  OnboardingViewController.swift
//  HabitTracker
//
//  Created by Максим Бабкин on 17.01.2025.
//

import UIKit

class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    
    lazy var pages: [UIViewController] = {
        let red = UIViewController()
        red.view.backgroundColor = .red

        let green = UIViewController()
        green.view.backgroundColor = .green

        let blue = UIViewController()
        blue.view.backgroundColor = .blue

        return [red, green, blue]
    }()

    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0

        pageControl.currentPageIndicatorTintColor = .brown
        pageControl.pageIndicatorTintColor = .orange

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()


    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }

        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // MARK: - UIPageViewControllerDataSource

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }

        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return pages.last
        }

        return pages[previousIndex]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
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

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
