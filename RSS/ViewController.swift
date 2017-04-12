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
import Kanna

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var links = [String]()
    var articles = [[String : String]]()
    var articleLink: URL?

    @IBOutlet weak var articleTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        articleTableView.delegate = self
        articleTableView.dataSource = self
        
        let html = getHTML("https://swiftnews.curated.co/")
        let startRange = html.range(of: "<article")
        let endRange = html.range(of: "</article")
        print(startRange?.lowerBound)
        let range = Range(uncheckedBounds: (lower: html.index((startRange?.lowerBound)!, offsetBy: 0), upper: html.index((endRange?.upperBound)!, offsetBy: 0)))
        let htmlSubstring = html.substring(with: range)
        //print(htmlSubstring)
        parseHTML(htmlSubstring)
        
        RSSParser.getRSSFeedResponse(path: "https://swiftnews.curated.co/issues.rss") { (rssFeed: RSSFeed?, status: NetworkResponseStatus) in // it will be nil if status == .error
            if let xml = try? String(contentsOfFile: (rssFeed?.description)!, encoding: .utf8) {
                if let doc = Kanna.XML(xml: xml, encoding: .utf8) {
                //print(doc)
//                let namespaces = [
//                    "o":  "urn:schemas-microsoft-com:office:office",
//                    "ss": "urn:schemas-microsoft-com:office:spreadsheet"
//                ]
//                if let author = doc.at_xpath("//o:Author", namespaces: namespaces) {
//                    print(author.text)
//                }
            }
            }
            
            //print(rssFeed)
            for item in (rssFeed?.items)! {
                self.parseItem(description: (rssFeed?.items[0].description)!)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parseHTML(_ html: String) {
        if let doc = HTML(html: html, encoding: .utf8) {
            //print(doc.css(""))
            //print("DOC TITLE:- \(doc.title)")
            
            let htmlArray = [String]()
            
            // Search for nodes by CSS
            for link in doc.css("h3[class^='item__title']") {
//                htmlArray.append(link.toHTML)
//                print("LINK TEXT:- \(link.text)")
//                print("LINK HREF:- \(link["a"])")
            }
            
            var contentArray = [[String : String]]()
            var count = 0
            // Search for nodes by XPath
            for link in doc.xpath("//h3/a | //h3/following-sibling::p[1]") {
                //print(count)
                //print("LINK TEXT:- \(link.text)")
                //print("LINK HREF:- \(link["href"])")
                
                if link["href"] != nil {
                    var dict = [String : String]()
                    dict["title"] = link.text
                    dict["link"] = link["href"]
                    contentArray.append(dict)
                    
                } else {
                    
                    contentArray[count]["description"] = link.text
                    count += 1
                }
                
            }
            
            articles = contentArray
            articleTableView.reloadData()
            for dict in contentArray {
                print("[title: \(dict["title"])]")
                print("[description: \(dict["description"])]")
                print("[link: \(dict["link"])]")
                print("")
            }
            
        }
    }
    
    func getHTML(_ myURLString: String) -> String {
        //let myURLString = urlString
        guard let myURL = URL(string: myURLString) else {
            print("Error: \(myURLString) doesn't seem to be a valid URL")
            return ""
        }
        
        do {
            let myHTMLString = try String(contentsOf: myURL)
            //print("HTML : \(myHTMLString)")
            return myHTMLString
        } catch let error as NSError {
            print("Error: \(error)")
        }
        
        return ""
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
                //print("TOKEN: - \(token.components(separatedBy: " "))")
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
            //print("Link - \(link)")
        }
        
        articleTableView.reloadData()
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        
        cell.linkLabel.text = articles[indexPath.row]["link"]
        cell.titleLabel.text = articles[indexPath.row]["title"]
        cell.descriptionLabel.text = articles[indexPath.row]["description"]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ArticleCell
        articleLink = URL(string: cell.linkLabel.text!)
        self.performSegue(withIdentifier: "articleSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! ArticleViewController
        
        destination.articleLink = articleLink
    }
    
    private func getHtmlLabel(text: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.attributedText = stringFromHtml(string: text)
        return label
    }
    
    private func stringFromHtml(string: String) -> NSAttributedString? {
        do {
            let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
            if let d = data {
                let str = try NSAttributedString(data: d,
                                                 options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType],
                                                 documentAttributes: nil)
                return str
            }
        } catch {
        }
        return nil
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
