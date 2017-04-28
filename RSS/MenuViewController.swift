//
//  MenuViewController.swift
//  RSS
//
//  Created by Brandon Sanchez on 4/14/17.
//  Copyright © 2017 Brandon Sanchez. All rights reserved.
//

import UIKit
import FeedlyKit

class MenuViewController: UIViewController {

    @IBOutlet weak var AppCodaButton: UIButton!
    @IBOutlet weak var weekInSwiftButton: UIButton!
    @IBOutlet var iosDevWeeklyButton: UIButton!
    @IBOutlet var bitesOfCocoaButton: UIButton!
    @IBOutlet var bobTheDevButton: UIButton!
    @IBOutlet var ericaButton: UIButton!
    @IBOutlet var oleButton: UIButton!
    @IBOutlet var loafButton: UIButton!
    @IBOutlet var iosAppDevButton: UIButton!
    @IBOutlet var wenderlichButton: UIButton!
    @IBOutlet var cocoaButton: UIButton!
    @IBOutlet var maniacButton: UIButton!
    
    var closeButton: UIButton!
    
    var delegate: FeedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setupCloseButton()
        self.view.alpha = 0
        self.view.backgroundColor = UIColor(white: 0, alpha: 0.0) // same color as menu button
        self.view.fadeIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupCloseButton() {
        closeButton = UIButton(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
        closeButton.layer.cornerRadius = closeButton.frame.size.height / 2
        closeButton.backgroundColor = UIColor.white
        closeButton.addTarget(self, action: #selector(dismissMenu), for: .touchUpInside)
        
        closeButton.frame.origin.y = view.bounds.height - closeButton.frame.height
        closeButton.frame.origin.x = view.bounds.width/2 - closeButton.frame.size.width/2
        
        
        self.view.addSubview(closeButton)
        
    }
    
    func dismissMenu() {
        self.dismiss(animated: true) {
            //change feed if neccessary & set index
            
        }
    }
    
    @IBAction func feedSelected(_ sender: AnyObject) {
        guard let button = sender as? UIButton, let del = delegate else {
            return
        }
        
        var feedCase: FeedURL!
        
        // view controller casting
        // Consider moving to protocol; Reference: http://stackoverflow.com/questions/35439041/how-to-send-values-to-a-parent-view-controller-in-swift
        let tabVC = self.presentingViewController as! TabBarController
        let navControllerMainVC = tabVC.viewControllers?[1] as! UINavigationController
        let mainVC = navControllerMainVC.viewControllers[0] as! MainViewController
        
        // Segue to proper tab & controller
        navControllerMainVC.popToRootViewController(animated: true)
        tabVC.selectedIndex = 1
        
        
        // Handle feed cases
        switch button.tag {
        case 1:
            // App Coda
            feedCase = FeedURL.AppCoda
        case 2:
            // This Week in Swift
            feedCase = FeedURL.WeekInSwift
        case 3:
            // iOS Dev Weekly
            feedCase = FeedURL.iOSDevWeekly
        case 4:
            // Little Bites of Cocoa
            feedCase = FeedURL.BitesOfCocoa
        case 5:
            // Ray Wenderlich
            feedCase = FeedURL.RayWenderlich
        case 6:
            // Bob the Developer
            feedCase = FeedURL.BobTheDeveloper
        case 7:
            // Cocoa Controls
            feedCase = FeedURL.CocoaControls
        case 8:
            // iOS App Development on Medium
            feedCase = FeedURL.iOSDevMedium
        case 9:
            // Maniac Dev
            feedCase = FeedURL.ManiacDev
        case 10:
            // Ole Begemann Blog
            feedCase = FeedURL.OleBegemann
        case 11:
            // Erica Sadun Blog
            feedCase = FeedURL.EricaSadun
        case 12:
            // Use your Loaf
            feedCase = FeedURL.UseYourLoaf
        default:
            return
        }
        
        del.feedDidChange(to: feedCase) {
        }
        
        dismissMenu()
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UITableView {
    func reloadData(completion: @escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}

protocol FeedDelegate {
    func feedDidChange(to feed: FeedURL, completion: () -> Void)
}
