//
//  EpisodesTableViewCell.swift
//  Podcast-Player
//
//  Created by Seb Tota on 4/10/21.
//

import UIKit

enum primaryButtonAction {
    case download
    case delete
}

class EpisodesTableViewCell: UITableViewCell {
    let actionButtonConf = UIImage.SymbolConfiguration(pointSize: 25.0)
    var episode: Episode?
    var action: primaryButtonAction?

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var episodeActionButton: UIButton!
    
    func setup(episode: Episode) {
        self.episode = episode
        titleLabel.text = episode.getTitle()
        descriptionLabel.text = episode.getDescription()
        
        if episode.episodeIsDownloaded() == false {
            episodeActionButton.setImage(UIImage(systemName: "arrow.down.circle", withConfiguration: actionButtonConf), for: .normal)
            action = primaryButtonAction.download
        } else {
            episodeActionButton.setImage(UIImage(systemName: "trash.circle", withConfiguration: actionButtonConf), for: .normal)
            action = primaryButtonAction.download
        }
    }
    
    @IBAction func actionButtonPrimaryActionTriggered(_ sender: Any) {
        
    }
}
