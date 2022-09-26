//
//  QuickStartPageViewController.swift
//  SocialCAM
//
//  Created by Jasmin Patel on 26/09/22.
//  Copyright © 2022 Viraj Patel. All rights reserved.
//

import UIKit

class QuickStartPageContainerViewController: UIViewController {
    
    @IBOutlet weak var headerTitleLabel: UILabel!

    var titleText = ""
    var viewcontrollersList: [UIViewController] = []
    var startIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        headerTitleLabel.text = titleText
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "pageContainer",
           let quickStartPageViewController = segue.destination as? QuickStartPageViewController {
            quickStartPageViewController.viewcontrollersList = viewcontrollersList
            quickStartPageViewController.startIndex = startIndex
        }
    }
    
    @IBAction func didTapOnBack(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
}

class QuickStartPageViewController: UIPageViewController {
    
    var viewcontrollersList: [UIViewController] = []
    var startIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.dataSource = self
        self.delegate = self
        if viewcontrollersList.count > 0 {
            let firstVC = viewcontrollersList[startIndex]
            setViewControllers([firstVC], direction: .forward, animated: false)
        }
    }

}

extension QuickStartPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = self.viewcontrollersList.firstIndex(of: viewController),
           index > 0 {
            return self.viewcontrollersList[index - 1]
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = self.viewcontrollersList.firstIndex(of: viewController),
           index < (self.viewcontrollersList.count - 1) {
            return self.viewcontrollersList[index + 1]
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewcontrollersList.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return startIndex
    }

}
