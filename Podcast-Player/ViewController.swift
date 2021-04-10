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

    var showRssFeeds = ["https://feeds.megaphone.fm/stufftheydontwantyoutoknow", "https://feeds.megaphone.fm/stuffyoushouldknow", "https://feeds.megaphone.fm/replyall", "https://feeds.feedburner.com/WaveformWithMkbhd?format=xml"]
    var shows: [Show] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initShowsTableView()
        createShows()
    }
    
    private func initShowsTableView() {
        showsTableView.rowHeight = 80.0
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
        // row.titleLabel.text = show.getTitle()

        row.title.text = show.getTitle()
        row.descriptionLabel.text = show.getDescription()
        return row
    }
}
