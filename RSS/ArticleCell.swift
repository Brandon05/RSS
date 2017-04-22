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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.preferredMaxLayoutWidth = cellBackground.frame.width - 20
        linkLabel.preferredMaxLayoutWidth = cellBackground.frame.width - 200
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

}
