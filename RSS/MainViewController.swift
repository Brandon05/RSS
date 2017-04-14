//
//  MainViewController.swift
//  RSS
//
//  Created by Brandon Sanchez on 4/13/17.
//  Copyright © 2017 Brandon Sanchez. All rights reserved.
//

import UIKit
import FeedlyKit

class MainViewController: UIViewController, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var feedlyCollectionView: UICollectionView!
    
                var feedUrl         = "feed/http://feeds.feedburner.com/appcoda"
    fileprivate let apiClient       = CloudAPIClient(target: .production)
                var entries         = [Entry]()
    fileprivate var pagination      = PaginationParams()
    fileprivate let indicator       = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    fileprivate enum State {
        case `init`
        case fetching
        case normal
        case complete
    }
    fileprivate var state: State = .init
    
    var articles = [NSDictionary]() {
        didSet {
            
        }
    }
    
    var feedButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        feedlyCollectionView.delegate = self
        feedlyCollectionView.dataSource = self
        
        let nib = UINib(nibName: "ArticleCell", bundle: nil)
        feedlyCollectionView.register(nib, forCellWithReuseIdentifier: "ArticleCell")
        feedlyCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "activityIndicator")
        self.feedlyCollectionView.insertSubview(indicator, at: 0)
        indicator.center = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - indicator.frame.height / 2)
        
        if let flowLayout = feedlyCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 1, height: 1)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        fetchFeed()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return entries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        let entry = entries[indexPath.row]
//        print(cell)
//        print(entry.title)
//        print(entry.summary?.content)
//        print(entry.summary?.toParameters())
        cell.titleLabel?.text = entry.title
        cell.descriptionLabel?.text = entry.content?.content
        cell.linkLabel?.text = entry.alternate?[0].href
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = feedlyCollectionView.cellForItem(at: indexPath) as! ArticleCell
        cell.tag = indexPath.row
        
        performSegue(withIdentifier: "articleSegue", sender: cell)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tv = feedlyCollectionView
        if (tv?.contentOffset.y)! >= (tv?.contentSize.height)! - (tv?.bounds.size.height)! && state == .normal {
            fetchFeed()
        }
    }
    
    func fetchFeed() {
        
        if state == .fetching { return }
        indicator.startAnimating()
        state = .fetching
        let _ = apiClient.fetchContents(feedUrl, paginationParams: pagination) {
            if let es = $0.result.value {
                self.entries.append(contentsOf: es.items)
                print(self.entries)
                
                self.feedlyCollectionView.reloadData()
                self.indicator.stopAnimating()
                if let c = es.continuation {
                    self.pagination.continuation = c
                    self.state = .normal
                } else {
                    self.state = .complete
                }
            }
        }
    }
    
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "articleSegue" {
            let cell = sender as! ArticleCell
            let linkString = cell.linkLabel.text
            let destination = segue.destination as! ArticleViewController
            if linkString != nil, let url = URL(string: linkString!) {
                destination.articleLink = url
            }
        }
    }
 

}
