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
    
    var closeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        setupCloseButton()
        self.view.backgroundColor = UIColor.yellow
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func feedSelected(_ sender: AnyObject) {
        guard let button = sender as? UIButton else {
            return
        }
        
        // Consider moving to protocol; Reference: http://stackoverflow.com/questions/35439041/how-to-send-values-to-a-parent-view-controller-in-swift
        let tabVC = self.presentingViewController as! TabBarController
        let navControllerMainVC = tabVC.viewControllers?[1] as! UINavigationController
        let mainVC = navControllerMainVC.viewControllers[0] as! MainViewController
        mainVC.entries = [Entry]()
        tabVC.selectedIndex = 1
        mainVC.feedlyCollectionView.reloadData()
    
        dismissMenu()
        switch button.tag {
        case 1:
            // App Coda
            mainVC.feedUrl = "feed/http://feeds.feedburner.com/appcoda"
        case 2:
            // This Week in Swift
            mainVC.feedUrl = "feed/https://swiftnews.curated.co/issues.rss"
        case 3: break
            // Change to French, etc
        default:
            print("Unknown language")
            return
        }
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
