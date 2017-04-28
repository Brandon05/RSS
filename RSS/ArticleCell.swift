//
//  ArticleCell.swift
//  RSS
//
//  Created by Brandon Sanchez on 4/13/17.
//  Copyright © 2017 Brandon Sanchez. All rights reserved.
//

import UIKit
import FeedlyKit

class ArticleCell: UICollectionViewCell {

    @IBOutlet var cellBackground: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var linkLabel: UILabel!
    @IBOutlet var cellBackgroundWidth: NSLayoutConstraint!
    @IBOutlet weak var titleLabelHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.preferredMaxLayoutWidth = cellBackground.frame.width - 20
        linkLabel.preferredMaxLayoutWidth = cellBackground.frame.width - 200
//        if UIScreen.main.bounds.width > 375 {
//            cellBackgroundWidth.constant = 367
//        } else {
//            cellBackgroundWidth.constant = 367
//        }
        //let width = UIScreen.main.bounds.width - 8
        //cellBackgroundWidth.constant = 200//UIScreen.main.bounds.width - 8
        //print(UIScreen.main.bounds.width)
    }
    
    func bind(_ entry: Entry) -> Self {
        
        titleLabel?.text = entry.title
        linkLabel?.text = entry.alternate?[0].href
        

        
        return self
    }
    
    override func layoutSubviews() {
        contentView.frame = bounds
        super.layoutSubviews()
    }
    
//    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//        
//    }
    
    /**
     Allows you to generate a cell without dequeueing one from a table view.
     - Returns: The cell loaded from its nib file.
     */
    class func fromNib() -> ArticleCell?
    {
        var cell: ArticleCell?
        let nibViews = Bundle.main.loadNibNamed("ArticleCell", owner: nil, options: nil)
        for nibView in nibViews! {
            if let cellView = nibView as? ArticleCell {
                cell = cellView
            }
        }
        return cell
    }

}
