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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupFeedButton()
        // Do any additional setup after loading the view.
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
        
        self.view.addSubview(feedButton)
        
    }
    
    func openFeedController() {
        self.selectedIndex = 1
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
