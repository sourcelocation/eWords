import UIKit
class PageViewController: UIPageViewController, UIScrollViewDelegate {
    var index = 0
    fileprivate lazy var pages: [UIViewController] = {
        return [
            self.getViewController(withIdentifier: "Page2"),
            self.getViewController(withIdentifier: "Page3"),
            self.getViewController(withIdentifier: "Page4"),
            self.getViewController(withIdentifier: "Page5"),
            self.getViewController(withIdentifier: "Page6"),
            self.getViewController(withIdentifier: "Page7"),
            self.getViewController(withIdentifier: "Page8"),
            self.getViewController(withIdentifier: "Page9"),
            self.getViewController(withIdentifier: "Page10"),
            self.getViewController(withIdentifier: "Page11"),
            self.getViewController(withIdentifier: "Page12")
        ]
    }()
    fileprivate func getViewController(withIdentifier identifier: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: identifier)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate   = self
        if let firstVC = pages.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        self.view.backgroundColor = .white
    }
    private func setupPageControl() {
        let appearance = UIPageControl.appearance()
        appearance.pageIndicatorTintColor = UIColor.gray
        appearance.currentPageIndicatorTintColor = UIColor.black
        appearance.backgroundColor = UIColor.white
    }

    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        setupPageControl()
        return self.pages.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    func resetPageViewController() {
        if let firstVC = pages.first {
            setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
        }
    }
}

extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0          else { return pages.last }
        
        guard pages.count > previousIndex else { return nil        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.index(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return pages.first }
        
        guard pages.count > nextIndex else { return nil         }
        
        return pages[nextIndex]
    }
}

extension PageViewController: UIPageViewControllerDelegate { }

   
