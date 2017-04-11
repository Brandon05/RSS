//
//  ArticleViewController.swift
//  RSS
//
//  Created by Brandon Sanchez on 4/11/17.
//  Copyright © 2017 Brandon Sanchez. All rights reserved.
//

import UIKit

class ArticleViewController: UIViewController {

    @IBOutlet weak var articleWebView: UIWebView!
    var articleLink: URL?
    override func viewDidLoad() {
        super.viewDidLoad()
        articleWebView.loadRequest(URLRequest(url: articleLink!))
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
