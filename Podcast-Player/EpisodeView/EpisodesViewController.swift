//
//  EpisodesViewController.swift
//  Podcast-Player
//
//  Created by Seb Tota on 4/10/21.
//

import UIKit

class EpisodesViewController: UIViewController {
    @IBOutlet weak var episodesTableView: UITableView!
    
    let episodesTableViewCellName: String = "EpisodesTableViewCell"
    let episodesTableViewCellReusableIdentifier: String = "EpisodesTableViewCell"
    let episodeToPlayerSegueIdentifier: String = "EpisodeToPlayerSegueIdentifier"
    
    var show: Show!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initEpisodeTableView()
    }
    
    private func initEpisodeTableView() {
        episodesTableView.rowHeight = 130.0
        episodesTableView.delegate = self
        episodesTableView.dataSource = self
    }
    
}

extension EpisodesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return show.getNumEpisodes()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = episodesTableView.dequeueReusableCell(withIdentifier: episodesTableViewCellReusableIdentifier, for: indexPath) as! EpisodesTableViewCell
        
        let episode = show.getEpisode(index: indexPath.item)
        row.titleLabel.text = episode.getTitle()
        row.descriptionLabel.text = episode.getDescription()
        return row
    }
    
    /*
    * Segue action prepare statements. Helps send data between view controllers upon a new segue
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == episodeToPlayerSegueIdentifier {
            if let viewController = segue.destination as? AudioPlayerViewController {
                viewController.episode = (sender as! Episode)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode: Episode = show.getEpisode(index: indexPath.item)
        
        dispatch_queue_main_t.main.async() {
            self.performSegue(withIdentifier: self.episodeToPlayerSegueIdentifier, sender: episode)
        }
    }
}
