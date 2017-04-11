//
//  ViewController.swift
//  RSS
//
//  Created by Brandon Sanchez on 4/11/17.
//  Copyright © 2017 Brandon Sanchez. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireRSSParser

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var links = [String]()
    var articleLink: URL?

    @IBOutlet weak var articleTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        articleTableView.delegate = self
        articleTableView.dataSource = self
        
        RSSParser.getRSSFeedResponse(path: "https://swiftnews.curated.co/issues.rss") { (rssFeed: RSSFeed?, status: NetworkResponseStatus) in // it will be nil if status == .error
            for item in (rssFeed?.items)! {
                self.parseItem(description: (rssFeed?.items[0].description)!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parseItem(description: String) {
        let tokens = description.components(separatedBy: " ")
        var h4 = false
        var href = false
        for token in tokens {
            if token.contains("h4") {
                h4 = true
            }
            if token.contains("/h4") {
                h4 = false
            }
            if h4 == true {
                print("TOKEN: - \(token.components(separatedBy: " "))")
                if token.contains("href") {
                    let startRange = token.range(of: "ttp")
                    let endRange = token.range(of: "rss")
                    //let range = Range(uncheckedBounds(lowerBound: )startRange?.lowerBound, endRange?.upperBound)
                    let range = Range(uncheckedBounds: (lower: token.index(before: (startRange?.lowerBound)!), upper: token.index(before: (endRange?.upperBound)!)))
                    //print(token.substring(with: range))
                    links.append(token.substring(with: range))
                }
            }
            
        }
        
        for link in links {
            print("Link - \(link)")
        }
        
        articleTableView.reloadData()
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return links.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        
        cell.linkLabel.text = links[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        articleLink = URL(string: links[indexPath.row])
        self.performSegue(withIdentifier: "articleSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ArticleViewController
        
        destination.articleLink = articleLink
    }

}

public enum NetworkResponseStatus {
    case success
    case error(string: String?)
}
public class RSSParser {
    public static func getRSSFeedResponse(path: String, completionHandler: @escaping (_ response: RSSFeed?,_ status: NetworkResponseStatus) -> Void) {
        Alamofire.request(path).responseRSS() { response in
            if let rssFeedXML = response.result.value {
                // Successful response - process the feed in your completion handler
                completionHandler(rssFeedXML, .success)
            } else {
                // There was an error, so feel free to handle it in your completion handler
                completionHandler(nil, .error(string: response.result.error?.localizedDescription))
            }
        }
    }

}
