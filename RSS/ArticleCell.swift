//
//  ArticleCell.swift
//  RSS
//
//  Created by Brandon Sanchez on 4/13/17.
//  Copyright © 2017 Brandon Sanchez. All rights reserved.
//

import UIKit

class ArticleCell: UICollectionViewCell {

    @IBOutlet var cellBackground: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var linkLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleLabel.preferredMaxLayoutWidth = cellBackground.frame.width - 20
        descriptionLabel.preferredMaxLayoutWidth = cellBackground.frame.width - 20
        linkLabel.preferredMaxLayoutWidth = cellBackground.frame.width - 200
    }

}
