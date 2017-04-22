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

class MainViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FeedDelegate {


    @IBOutlet var feedlyCollectionView: UICollectionView!
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        feedlyCollectionView.delegate = self
        feedlyCollectionView.dataSource = self
        
        let nib = UINib(nibName: "ArticleCell", bundle: nil)
        let nib2 = UINib(nibName: "ArticleImageCell", bundle: nil)
        feedlyCollectionView.register(nib, forCellWithReuseIdentifier: "ArticleCell")
        feedlyCollectionView.register(nib2, forCellWithReuseIdentifier: "ArticleImageCell")
        feedlyCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "activityIndicator")
        //self.feedlyCollectionView.insertSubview(indicator, at: 0)
        //indicator.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - indicator.frame.height / 2)
        
        if let flowLayout = feedlyCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
        
        fetchFeed()
        
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = entries.count != 0 ? entries.count : 0
//        print("Count: \(count)")
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let articleCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        let articleImageCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArticleImageCell", for: indexPath) as! ArticleImageCell
        if entries.count > 0 {
            let entry = entries[indexPath.row]
            
            if let imageUrl = entry.visual?.url, feedCase == FeedURL.CocoaControls {
                articleImageCell.titleLabel?.text = entry.title
                articleImageCell.linkLabel?.text = entry.alternate?[0].href
                print(imageUrl)
                articleImageCell.articleImageView.af_setImage(withURL: URL(string: imageUrl)!)

                return articleImageCell
            }
            
            articleCell.cellBackgroundWidth?.constant = feedlyCollectionView.frame.width - 8
            return articleCell.bind(entry)
            
        }
        
        //return articleImageCell
        return articleCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = feedlyCollectionView.cellForItem(at: indexPath)
        cell?.tag = indexPath.row
        
        performSegue(withIdentifier: "articleSegue", sender: cell)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tv = feedlyCollectionView
        if (tv?.contentOffset.y)! >= (tv?.contentSize.height)! - (tv?.bounds.size.height)! && state == .normal {
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
                
                
                self.feedlyCollectionView.reloadData() {
                    self.feedlyCollectionView.fadeIn()
                }
                
                self.feedlyCollectionView.collectionViewLayout.invalidateLayout()
                
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
                
                self.feedlyCollectionView.reloadData() {
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
        feedlyCollectionView.alpha = 0 // prepare fade in
        feedCase = feed
        entries = [Entry]()
        fetchFeed()
        completion()
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "articleSegue" {
            let cell = sender as! UICollectionViewCell
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







