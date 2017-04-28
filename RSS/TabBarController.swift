//
//  TabBarController.swift
//  RSS
//
//  Created by Brandon Sanchez on 4/14/17.
//  Copyright © 2017 Brandon Sanchez. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    public var feedButton: UIButton!
    let transition = CircularTransition()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupFeedButton()
        self.selectedIndex = 1 // news feed default tab

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        feedButton.fadeIn()
    }
    
    func setupFeedButton() {
        feedButton = UIButton(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
        feedButton.layer.cornerRadius = feedButton.frame.size.height / 2
        feedButton.backgroundColor = UIColor(white: 0, alpha: 1)
        feedButton.addTarget(self, action: #selector(openFeedController), for: .touchUpInside)
        
        feedButton.frame.origin.y = view.bounds.height - feedButton.frame.height
        feedButton.frame.origin.x = view.bounds.width/2 - feedButton.frame.size.width/2
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(segueToMenu))
        longPress.minimumPressDuration = 0.35
        feedButton.addGestureRecognizer(longPress)
        
        self.view.addSubview(feedButton)
        
    }
    
    // MARK: - Navigation
    
    func openFeedController() {
        
        if self.selectedIndex != 1 {
            self.selectedIndex = 1
        } else {
            let nav = self.viewControllers?[1] as! UINavigationController
            let mainVC = nav.viewControllers[0] as! MainViewController
            
            // Scroll to top of feed when pressed while tab is open
            mainVC.feedlyTableView.scrollToRow(at: IndexPath(row: 0, section: 0),
                                                                          at: .top,
                                                                          animated: true)
        }
    
    }
    
    func segueToMenu(_ sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .began:
            let nav = self.viewControllers?[1] as! UINavigationController
            let mainVC = nav.viewControllers[0] as! MainViewController
        
            let menuVC = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
            menuVC.delegate = mainVC
            menuVC.transitioningDelegate = self
            menuVC.modalPresentationStyle = .custom
            feedButton.fadeOut()
            self.present(menuVC, animated: true) {
                self.feedButton.fadeIn()
            }
        default:
            break
        }
        
    }


    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let menuVC = segue.destination as! MenuViewController
        menuVC.transitioningDelegate = self
        menuVC.modalPresentationStyle = .custom
    }
 

}

    // MARK: - Transition Delegate

extension TabBarController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = feedButton.center
        transition.circleColor = feedButton.backgroundColor!
        
        return transition
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = feedButton.center
        transition.circleColor = feedButton.backgroundColor!
        
        return transition
    }
    
}

