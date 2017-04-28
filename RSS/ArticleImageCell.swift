//
//  ArticleImageCell.swift
//  RSS
//
//  Created by Brandon Sanchez on 4/19/17.
//  Copyright © 2017 Brandon Sanchez. All rights reserved.
//

import UIKit

class ArticleImageCell: UITableViewCell {

    @IBOutlet var cellBackground: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var linkLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //titleLabel.preferredMaxLayoutWidth = cellBackground.frame.width - 20
        //linkLabel.preferredMaxLayoutWidth = cellBackground.frame.width - 200
    }

}
