//
//  ArticleCell.swift
//  RSS
//
//  Created by Brandon Sanchez on 4/11/17.
//  Copyright © 2017 Brandon Sanchez. All rights reserved.
//

import UIKit

class ArticleCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet weak var linkLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
