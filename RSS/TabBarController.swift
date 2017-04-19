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
        print("load")
        self.selectedIndex = 1
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("appear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupFeedButton() {
        feedButton = UIButton(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
        feedButton.layer.cornerRadius = feedButton.frame.size.height / 2
        feedButton.backgroundColor = UIColor.yellow
        feedButton.addTarget(self, action: #selector(openFeedController), for: .touchUpInside)
        
        feedButton.frame.origin.y = view.bounds.height - feedButton.frame.height
        feedButton.frame.origin.x = view.bounds.width/2 - feedButton.frame.size.width/2
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(segueToMenu))
        longPress.minimumPressDuration = 0.35
        feedButton.addGestureRecognizer(longPress)
        
        self.view.addSubview(feedButton)
        
    }
    
    func openFeedController() {
        if self.selectedIndex != 1 {
            self.selectedIndex = 1
        }
    }
    
    func segueToMenu(_ sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .began:
            let menuVC = storyboard?.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
            menuVC.transitioningDelegate = self
            menuVC.modalPresentationStyle = .custom
            self.present(menuVC, animated: true, completion: nil)
        default:
            break
        }
        
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let menuVC = segue.destination as! MenuViewController
        menuVC.transitioningDelegate = self
        menuVC.modalPresentationStyle = .custom
    }
 

}

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

