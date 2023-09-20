//
//  AttributionTableViewCell.swift
//  PrusaLink
//
//  Created by George Waters on 9/18/23.
//

import UIKit

class AttributionTableViewCell: UITableViewCell {
    
    let ghString = "https://github.com/dunkmann00/PrusaLinkiOS"
    
    @IBOutlet weak var topLabel: UILabel!
    @IBOutlet weak var bottomLabel: UILabel!
    @IBOutlet weak var linkButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        linkButton.setTitle(ghString, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func linkButtonPressed(_ sender: UIButton) {
        guard let url = URL(string: ghString) else { return }
        UIApplication.shared.open(url)
    }
}
