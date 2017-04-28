//
//  MainViewController.swift
//  RSS
//
//  Created by Brandon Sanchez on 4/13/17.
//  Copyright © 2017 Brandon Sanchez. All rights reserved.
//

import UIKit
import FeedlyKit
import AlamofireImage

class MainViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, FeedDelegate {


    @IBOutlet var feedlyTableView: UITableView!
    
    // Set via User Defaults
    fileprivate var feedCase = FeedURL.AppCoda
    fileprivate var entries = [Entry]()
    fileprivate let apiClient = CloudAPIClient(target: .production)
    fileprivate var pagination = PaginationParams()
    fileprivate let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    fileprivate enum State {
        case `init`
        case fetching
        case normal
        case complete
        case error
    }
    fileprivate var state: State = .init {
        didSet {
            //print("SET STATE: - \(state)")
        }
    }
    
    var articles = [NSDictionary]() {
        didSet {
            
        }
    }
    
    var feedButton: UIButton!
    var atributionLink: String?
    var width: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        feedlyTableView.delegate = self
        feedlyTableView.dataSource = self
        
        let nib = UINib(nibName: "ArticleCell", bundle: nil)
        let nib2 = UINib(nibName: "ArticleImageCell", bundle: nil)
        feedlyTableView.register(nib, forCellReuseIdentifier: "ArticleCell")
        feedlyTableView.rowHeight = UITableViewAutomaticDimension
        feedlyTableView.estimatedRowHeight = 100
        feedlyTableView.register(nib2, forCellReuseIdentifier: "ArticleImageCell")
        //feedlyTableView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "activityIndicator")
        //self.feedlyCollectionView.insertSubview(indicator, at: 0)
        //indicator.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - indicator.frame.height / 2)
        
        fetchFeed()
        
        width = feedlyTableView.frame.width - 8
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
//        print(state)
//        print(feedCase)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = entries.count != 0 ? entries.count : 0
    
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let articleCell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        let articleImageCell = tableView.dequeueReusableCell(withIdentifier: "ArticleImageCell", for: indexPath) as! ArticleImageCell
        if entries.count > 0 {
            let entry = entries[indexPath.row]
            
            if let imageUrl = entry.visual?.url, feedCase == FeedURL.CocoaControls || feedCase == FeedURL.ManiacDev {
                articleImageCell.titleLabel?.text = entry.title
                articleImageCell.linkLabel?.text = entry.alternate?[0].href
                print(imageUrl)
                //articleImageCell.articleImageView.af_setImage(withURL: URL(string: imageUrl)!)
                
                return articleImageCell
            }
//
//            
//            //articleCell.cellBackgroundWidth?.constant = width
//            //articleCell.layoutIfNeeded()
//            
//            if UIScreen.main.bounds.width > 375 {
//                articleCell.cellBackgroundWidth?.constant = 406
//            } else {
//                articleCell.cellBackgroundWidth?.constant = 367
//            }
            
            return articleCell.bind(entry)
            
        }
        
        //return articleImageCell
        return articleCell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = feedlyTableView.cellForRow(at: indexPath)
        cell?.tag = indexPath.row
        
        performSegue(withIdentifier: "articleSegue", sender: cell)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tv = feedlyTableView
        if (tv?.contentOffset.y)! >= (tv?.contentSize.height)! - (tv?.bounds.size.height)! - 200 && state == .normal {
            fetchFeedWithPagination()
        }
    }
    
    func fetchFeed() {
        
        let paginationNil = PaginationParams()
        let feedUrl = grabUrl(for: feedCase)
        
        if state == .fetching { print(state); return }
        indicator.startAnimating()
        state = .fetching
        let _ = apiClient.fetchContents(feedUrl, paginationParams: paginationNil) {
            if let es = $0.result.value {
                self.entries.append(contentsOf: es.items)
//                print(self.entries)
//                print(feedUrl)
//                print("Pagination: - \(self.pagination.toParameters())")
                
                
                self.feedlyTableView.reloadData() {
                    self.feedlyTableView.fadeIn()
                }
                
                //self.feedlyTableView.collectionViewLayout.invalidateLayout()
                
                self.indicator.stopAnimating()
                if let c = es.continuation {
                    print(c)
                    self.pagination.continuation = c
                    self.state = .normal
                } else {
                    self.state = .complete
                }
            }
        }
        
        self.timeout(10, closure: {
            // Should have a 'error' state
            self.state = .normal
            if self.entries.count == 0 {
                self.fetchFeed()
            }
            return
        })
        
    }
    
    func fetchFeedWithPagination() {
        
        let feedUrl = grabUrl(for: feedCase)
        
        if state == .fetching { return }
        indicator.startAnimating()
        state = .fetching
        let _ = apiClient.fetchContents(feedUrl, paginationParams: pagination) {
            if let es = $0.result.value {
                self.entries.append(contentsOf: es.items)
//                print(self.entries)
//                print(feedUrl)
//                print("Pagination: - \(self.pagination.toParameters())")
                
                self.feedlyTableView.reloadData() {
                }
                
                self.indicator.stopAnimating()
                if let c = es.continuation {
                    self.pagination.continuation = c
                    self.state = .normal
                } else {
                    self.state = .complete
                }
            }
        }
        
        self.timeout(10, closure: {
            // Should have a 'error' state
            self.state = self.state == .complete ? .complete : .normal
            return
        })
    }
    
    func timeout(_ delay: Int, closure: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(delay), execute: closure)
    }
    
    fileprivate func grabUrl(for selected: FeedURL) -> String {
        switch selected {
        case .AppCoda:
            return "feed/http://feeds.feedburner.com/appcoda"
        case .BitesOfCocoa:
            return "feed/http://littlebitesofcocoa.com/rss"
        case .iOSDevWeekly:
            return "feed/http://iosdevweekly.com/issues.rss"
        case .WeekInSwift:
            return "feed/https://swiftnews.curated.co/issues.rss"
        case .CocoaControls:
            return "feed/http://feeds.feedburner.com/cocoacontrols"
        case .EricaSadun:
            return "feed/http://ericasadun.com/feed/"
        case .ManiacDev:
            return "feed/http://feeds.feedburner.com/maniacdev"
        case .iOSDevMedium:
            return "feed/https://medium.com/feed/tag/ios-app-development"
        case .BobTheDeveloper:
            return "feed/https://medium.com/feed/ios-geek-community"
        case .OleBegemann:
            return "feed/http://oleb.net/blog/atom.xml"
        case .RayWenderlich:
            return "feed/http://feeds.feedburner.com/RayWenderlich"
        case .UseYourLoaf:
            return "feed/http://useyourloaf.com/blog/rss.xml"
        }
    }
    
    internal func feedDidChange(to feed: FeedURL, completion: () -> Void) {
        feedlyTableView.alpha = 0 // prepare fade in
        feedlyTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        feedCase = feed
        entries = [Entry]()
        fetchFeed()
        completion()
    }
    
    func lineCount(_ yourLabel: UILabel) {
        var lineCount: Int = 0
        let textSize = CGSize(width: CGFloat(yourLabel.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(yourLabel.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(yourLabel.font.lineHeight))
        print(yourLabel.font.leading)
        lineCount = rHeight / charSize
        print("No of lines: \(lineCount)")
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "articleSegue" {
            let cell = sender as! UITableViewCell
            let linkString = entries[cell.tag].alternate?[0].href
            let destination = segue.destination as! ArticleViewController
            if linkString != nil, let url = URL(string: linkString!) {
                destination.articleLink = url
            }
        }
    }
 

}

// Fade Animation Extensions

extension UIView {
    func fadeOut() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        }
    }
    
    func fadeIn() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
}







