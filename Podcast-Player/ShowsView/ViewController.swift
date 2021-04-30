//
//  ViewController.swift
//  Podcast-Player
//
//  Created by Sebastian Tota on 4/10/21.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    @IBOutlet weak var showsTableView: UITableView!
    
    let showsTableViewCellName: String = "ShowsTableViewCell"
    let showsTableViewCellReusableIdentifier: String = "ShowsTableViewCell"
    let showToEpisodeSegueIdentifier: String = "ShowToEpisodeSegueIdentifier"

    var defaultShowRssFeeds: [String] = ["https://feeds.megaphone.fm/stufftheydontwantyoutoknow", "https://feeds.megaphone.fm/stuffyoushouldknow", "https://feeds.megaphone.fm/replyall", "https://feeds.feedburner.com/WaveformWithMkbhd?format=xml"]
    var showRssFeeds: [String] = []
    var shows: [Show] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initShowsTableView()
        
        if let feeds: [String] = UserDefaults.standard.value(forKey: "feeds") as? [String] {
            print("using saved data")
            showRssFeeds = feeds
        } else {
            print("saving data")
            UserDefaults.standard.setValue(defaultShowRssFeeds, forKey: "feeds")
            showRssFeeds = defaultShowRssFeeds
        }
        
        createShows()
    }
    
    private func initShowsTableView() {
        showsTableView.rowHeight = 100.0
        showsTableView.delegate = self
        showsTableView.dataSource = self
    }
    
    private func createShows() {
        for show in showRssFeeds {
            if let showUrl = URL(string: show) {
                let p = RssFeedParser(url: showUrl)
                p.parseFeed { (show: Show?) in
                    print("A show has been returned")
                    if let show = show {
                        self.shows.append(show)
                        DispatchQueue.main.async {
                            print("Done loading in a show")
                            self.showsTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shows.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = showsTableView.dequeueReusableCell(withIdentifier: showsTableViewCellReusableIdentifier, for: indexPath) as! ShowsTableViewCell
        

        let show = shows[indexPath.item]
        row.title.text = show.getTitle()
        row.descriptionLabel.text = show.getDescription()
        show.getImage { (image: UIImage) in
            DispatchQueue.main.async {
                row.showImage.image = image
            }
        }
        return row
    }
    
    /*
    * Segue action prepare statements. Helps send data between view controllers upon a new segue
    */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showToEpisodeSegueIdentifier {
            if let viewController = segue.destination as? EpisodesViewController {
                viewController.show = (sender as! Show)
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let show: Show = shows[indexPath.item]
        
        dispatch_queue_main_t.main.async() {
            self.performSegue(withIdentifier: self.showToEpisodeSegueIdentifier, sender: show)
        }
    }
}
